import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/common/data/configs.dart';
import 'package:tayssir/debug/app_logger.dart';

// User should replace this with their actual API key from Google AI Studio
const String _kGeminiApiKey = 'REPLACE_WITH_YOUR_API_KEY';

final aiServiceProvider = Provider((ref) {
  final configs = ref.watch(configsProvider).valueOrNull;

  // If no configs yet, use the default hardcoded key/persona as fallback
  final apiKey = configs?.refiqApiKey ?? _kGeminiApiKey;
  final persona = configs?.refiqPersona ?? AIService.systemPrompt;

  return AIService(
    apiKey: apiKey,
    persona: persona,
    appGoal: configs?.refiqAppGoal ?? '',
    subscriptionPrice: configs?.refiqSubscriptionPrice ?? '',
    availableMaterials: configs?.refiqAvailableMaterials ?? '',
    socialLinks: configs?.refiqSocialLinks ?? '',
    strictMode: configs?.refiqStrictMode ?? true,
  );
});

class AIService {
  final String apiKey;
  final String persona;
  final String appGoal;
  final String subscriptionPrice;
  final String availableMaterials;
  final String socialLinks;
  final bool strictMode;
  late final GenerativeModel model;

  AIService({
    required this.apiKey,
    required this.persona,
    this.appGoal = '',
    this.subscriptionPrice = '',
    this.availableMaterials = '',
    this.socialLinks = '',
    this.strictMode = true,
  }) {
    final strictRule = strictMode
        ? 'قاعدة صارمة: لا تجب على أي سؤال خارج نطاق حفظ القرآن الكريم أو تطبيق بيان القرآن. إذا سألك المستخدم عن الطقس أو الرياضة أو أي شيء آخر غير متعلق بالقرآن وعلومه، أخبره بلباقة أنك مخصص لمساعدته في رحلة الحفظ والارتقاء بكتاب الله فقط.'
        : '';

    final fullInstructions =
        '$persona\n\nمعلومات إضافية عن التطبيق:\n- هدف التطبيق: $appGoal\n- أسعار الاشتراك: $subscriptionPrice\n- المواد المتوفرة: $availableMaterials\n- حساباتنا: $socialLinks\n\n$strictRule';

    model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
      systemInstruction: Content.system(fullInstructions),
    );
  }

  // تعليمات شخصية "رفيق بيان" (Bayan AI)
  static const String systemPrompt =
      'أنت "رفيق بيان" (Bayan AI)، المساعد الذكي في تطبيق بيان القرآن الكريم.\n'
      'هدفك هو مرافقة الحفاظ في رحلتهم، تشجيعهم، والإجابة على تساؤلاتهم حول القرآن الكريم وعلومه بأسلوب لطيف ومحفز.\n\n'
      'قواعد التعامل:\n'
      '- استخدم لغة عربية فصحى بسيطة وهادئة تبعث على الطمأنينة.\n'
      '- كن مشجعاً جداً ومحفزاً للحفظ (مثال: "ما شاء الله، واصل فتح الله عليك").\n'
      '- عند السؤال عن معاني الآيات، قدم تفسيراً ميسراً ومختصراً.\n'
      '- في "رادار التجويد"، ركز على تشجيع المستخدم مع تنبيهه للأخطاء الواضحة بلطف.\n\n'
      'معلومات عن التطبيق:\n'
      '1. نظام "مستويات الولاية": يترقى المستخدم من مبتدئ إلى مجاز بناءً على حفظه.\n'
      '2. حماية الورد (Freeze Mode): ميزة تحمي الستريك عند الانشغال.\n'
      '3. مبارزات الحفظ: تحديات ودية بين الأصدقاء.';

  /// وظيفة [checkTajweed] لتحليل نطق المستخدم للآية
  Future<String> checkTajweed(List<int> audioBytes, String ayahText) async {
    try {
      final prompt =
          'هذا تسجيل صوتي لمستخدم يقرأ الآية التالية: "$ayahText". هل قراءته صحيحة؟ قدم ملاحظات مختصرة جداً عن التجويد والنطق.';
      final content = [
        Content.multi([
          DataPart('audio/mp3', Uint8List.fromList(audioBytes)),
          TextPart(prompt),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text ?? 'لم أتمكن من تحليل الصوت حالياً.';
    } catch (e) {
      AppLogger.logError('Tajweed AI Error: $e');
      return 'عذراً، واجهت مشكلة في تحليل الصوت. حاول القراءة مرة أخرى بوضوح.';
    }
  }

  Future<String> getResponse(String message, List<Content> history) async {
    try {
      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'عذراً، لم أستطع فهم ذلك. هل يمكنك إعادة السؤال؟';
    } catch (e) {
      AppLogger.logError('AI Error: $e');
      return 'رفيق بيان يواجه صعوبة في الاتصال حالياً. حاول مرة أخرى بعد قليل بارك الله فيك.';
    }
  }
}
