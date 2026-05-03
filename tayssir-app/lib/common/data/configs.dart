// final configsProvider  = FutureProvider<ConfigsModel>

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/constants/end_points.dart';
import 'package:tayssir/providers/dio/dio.dart';

class ConfigModel {
  final bool cardsActive;
  final bool bacSolutionsActive;
  final bool resumesActive;
  final String appVersion;
  final String paymentName;
  final String paymentNumber;
  final bool isChargilyActive;
  final String tourMaterialGridImage;
  final String tourMaterialListImage;
  final String tourUnitImage;
  final String tourChapterImage;
  final bool refiqActive;
  final String refiqPersona;
  final String refiqWelcomeMessage;
  final String refiqApiKey;
  final List<RefiqQA> refiqQaList;
  final String refiqAppGoal;
  final String refiqSubscriptionPrice;
  final String refiqAvailableMaterials;
  final String refiqSocialLinks;
  final bool refiqStrictMode;
  
  // Tool Images Overrides
  final String toolCardsGrid;
  final String toolCardsList;
  final String toolResumesGrid;
  final String toolResumesList;
  final String toolBacSolutionsGrid;
  final String toolBacSolutionsList;
  final String toolPomodoroGrid;
  final String toolPomodoroList;
  final String toolGradeCalcGrid;
  final String toolGradeCalcList;
  final String toolAiPlannerGrid;
  final String toolAiPlannerList;

  ConfigModel({
    required this.cardsActive,
    required this.bacSolutionsActive,
    required this.resumesActive,
    required this.appVersion,
    required this.paymentName,
    required this.paymentNumber,
    required this.isChargilyActive,
    required this.tourMaterialGridImage,
    required this.tourMaterialListImage,
    required this.tourUnitImage,
    required this.tourChapterImage,
    required this.refiqActive,
    required this.refiqPersona,
    required this.refiqWelcomeMessage,
    required this.refiqApiKey,
    required this.refiqQaList,
    required this.refiqAppGoal,
    required this.refiqSubscriptionPrice,
    required this.refiqAvailableMaterials,
    required this.refiqSocialLinks,
    required this.refiqStrictMode,
    // Tool Images
    required this.toolCardsGrid,
    required this.toolCardsList,
    required this.toolResumesGrid,
    required this.toolResumesList,
    required this.toolBacSolutionsGrid,
    required this.toolBacSolutionsList,
    required this.toolPomodoroGrid,
    required this.toolPomodoroList,
    required this.toolGradeCalcGrid,
    required this.toolGradeCalcList,
    required this.toolAiPlannerGrid,
    required this.toolAiPlannerList,
  });
  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      cardsActive: map['cards_tools_active'] ?? false,
      bacSolutionsActive: map['bac_solutions_active'] ?? false,
      resumesActive: map['resumes_active'] ?? false,
      appVersion: map['app_version'] ?? '',
      paymentName: map['payment_name'] ?? '',
      paymentNumber: map['payment_number'] ?? '',
      isChargilyActive: map['chargily_payment_active'] ?? true,
      tourMaterialGridImage: map['tour_material_grid_image'] ?? '',
      tourMaterialListImage: map['tour_material_list_image'] ?? '',
      tourUnitImage: map['tour_unit_image'] ?? '',
      tourChapterImage: map['tour_chapter_image'] ?? '',
      refiqActive: map['refiq_active'] ?? map['tito_active'] ?? true,
      refiqPersona: map['refiq_persona'] ?? map['tito_persona'] ?? '',
      refiqWelcomeMessage: map['refiq_welcome_message'] ?? map['tito_welcome_message'] ?? '',
      refiqApiKey: map['refiq_api_key'] ?? map['tito_api_key'] ?? '',
      refiqQaList: (map['refiq_qa_list'] as List?)?.map((e) => RefiqQA.fromMap(e)).toList() ?? 
                   (map['tito_qa_list'] as List?)?.map((e) => RefiqQA.fromMap(e)).toList() ?? [],
      refiqAppGoal: map['refiq_app_goal'] ?? map['tito_app_goal'] ?? '',
      refiqSubscriptionPrice: map['refiq_subscription_price'] ?? map['tito_subscription_price'] ?? '',
      refiqAvailableMaterials: map['refiq_available_materials'] ?? map['tito_available_materials'] ?? '',
      refiqSocialLinks: map['refiq_social_links'] ?? map['tito_social_links'] ?? '',
      refiqStrictMode: map['refiq_strict_mode'] ?? map['tito_strict_mode'] ?? true,
      
      // Tool Images
      toolCardsGrid: map['tool_cards_grid'] ?? '',
      toolCardsList: map['tool_cards_list'] ?? '',
      toolResumesGrid: map['tool_resumes_grid'] ?? '',
      toolResumesList: map['tool_resumes_list'] ?? '',
      toolBacSolutionsGrid: map['tool_bac_solutions_grid'] ?? '',
      toolBacSolutionsList: map['tool_bac_solutions_list'] ?? '',
      toolPomodoroGrid: map['tool_pomodoro_grid'] ?? '',
      toolPomodoroList: map['tool_pomodoro_list'] ?? '',
      toolGradeCalcGrid: map['tool_grade_calc_grid'] ?? '',
      toolGradeCalcList: map['tool_grade_calc_list'] ?? '',
      toolAiPlannerGrid: map['tool_ai_planner_grid'] ?? '',
      toolAiPlannerList: map['tool_ai_planner_list'] ?? '',
    );
  }
}

class RefiqQA {
  final String label;
  final String value;

  RefiqQA({required this.label, required this.value});

  factory RefiqQA.fromMap(Map<String, dynamic> map) {
    return RefiqQA(
      label: map['label'] ?? '',
      value: map['value'] ?? '',
    );
  }
}

final configsProvider = FutureProvider<ConfigModel>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(EndPoints.settings);
    final data = response.data['data'];
    return ConfigModel.fromMap(data);
  } catch (e) {
    return ConfigModel(
      cardsActive: false,
      bacSolutionsActive: false,
      resumesActive: false,
      appVersion: '1.2.6',
      paymentName: 'TAYSSIR E-LEARNING',
      paymentNumber: '0022500000000',
      isChargilyActive: true,
      tourMaterialGridImage: '',
      tourMaterialListImage: '',
      tourUnitImage: '',
      tourChapterImage: '',
      refiqActive: true,
      refiqWelcomeMessage: 'أهلاً بك يا صاحب القرآن! أنا رفيق بيان، كيف يمكنني مساعدتك اليوم بخصوص حفظك أو مراجعتك؟ 📖✨',
      refiqPersona: '''
أنت "رفيق بيان" (Refiq Bayan)، المساعد الذكي لتطبيق "بيان القرآن". هدفك هو مساعدة الحفاظ على تثبيت القرآن الكريم ومراجعته بطريقة تفاعلية وممتعة.
أنت هادئ، مشجع، وتستخدم لغة عربية فصحى وبسيطة تناسب جلال القرآن الكريم.
''',
      refiqApiKey: '',
      refiqQaList: [
        RefiqQA(label: "كيف أبدأ الحفظ؟", value: "اختر الرواية التي تناسبك من الصفحة الرئيسية وابدأ وردك اليومي."),
        RefiqQA(label: "ما هي الميزات المتاحة؟", value: "مراجعة تفاعلية، تتبع الحفظ، تحديات إيمانية، وحاسبة التقدم في الأجزاء."),
        RefiqQA(label: "ما هو هدف التطبيق؟", value: "تطبيق بيان القرآن يهدف لمساعدة المسلمين في حفظ وتثبيت كتاب الله بطرق تكنولوجية حديثة."),
        RefiqQA(label: "كيف أتواصل معكم؟", value: "عبر منصات التواصل الاجتماعي الخاصة بـ بيان القرآن."),
      ],
      refiqAppGoal: 'تطبيق بيان القرآن يهدف لمساعدة المسلمين في حفظ وتثبيت كتاب الله بطرق تكنولوجية حديثة.',
      refiqSubscriptionPrice: 'ساهم في وقف بيان القرآن لدعم استمرارية المشروع وفتح ميزات متقدمة.',
      refiqAvailableMaterials: 'رواية حفص عن عاصم، رواية ورش عن نافع، وبرامج الحفظ المكثف.',
      refiqSocialLinks: 'عبر صفحاتنا الرسمية "بيان القرآن"',
      refiqStrictMode: true,
      toolCardsGrid: '',
      toolCardsList: '',
      toolResumesGrid: '',
      toolResumesList: '',
      toolBacSolutionsGrid: '',
      toolBacSolutionsList: '',
      toolPomodoroGrid: '',
      toolPomodoroList: '',
      toolGradeCalcGrid: '',
      toolGradeCalcList: '',
      toolAiPlannerGrid: '',
      toolAiPlannerList: '',
    );
  }
});
