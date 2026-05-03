import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/features/challanges/data/challenge_repository.dart';
import 'package:tayssir/environment_config.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/common/core/shield_badge.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'dart:ui';

class ArenaScreen extends HookConsumerWidget {
  final String matchId;
  final int unitId;
  final String courseTitle;

  const ArenaScreen({
    super.key,
    required this.matchId,
    required this.unitId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider).value;
    final myUid = user?.id.toString();
    final isSoundOn = ref.watch(isSoundEnabledProvider);

    final matchRef = FirebaseDatabase.instance.ref('challenges/matches/$matchId');
    final matchData = useState<Map<dynamic, dynamic>?>(null);
    final isConnected = useState<bool>(true);
    final isSubmitting = useState<bool>(false);
    final confettiController = useMemoized(() => ConfettiController(duration: const Duration(seconds: 5)));

    useEffect(() => confettiController.dispose, []);

    useEffect(() {
      final connectedSub = FirebaseDatabase.instance.ref('.info/connected').onValue.listen((event) {
        isConnected.value = event.snapshot.value == true;
      });
      return connectedSub.cancel;
    }, []);

    useEffect(() {
      final statusRef = matchRef.child('players/$myUid/status');
      statusRef.onDisconnect().set('disconnected');
      statusRef.set('playing');

      final sub = matchRef.onValue.listen((event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          matchData.value = event.snapshot.value as Map<dynamic, dynamic>;
        }
      });

      return () {
        sub.cancel();
        Future.microtask(() async {
          await statusRef.onDisconnect().cancel();
          final snap = await matchRef.get();
          if (snap.exists) {
            final map = snap.value as Map<dynamic, dynamic>;
            if (map['isBotMatch'] == true) {
              await matchRef.remove();
            } else {
              await statusRef.set('disconnected');
              final p = map['players'] as Map<dynamic, dynamic>? ?? {};
              bool allDoneOrGone = true;
              for (var val in p.values) {
                if (val['uid'] != myUid && val['status'] == 'playing') allDoneOrGone = false;
              }
              if (allDoneOrGone) await matchRef.remove();
            }
          }
        });
      };
    }, []);

    if (matchData.value == null || myUid == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1120) : Colors.white,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
      );
    }

    final data = matchData.value!;
    final players = (data['players'] as Map<dynamic, dynamic>?) ?? {};
    final questions = (data['questions'] as List<dynamic>?) ?? [];
    final currentIndex = (data['currentQuestionIndex'] as int?) ?? 0;

    Map? myInfo, opInfo;
    players.forEach((k, v) => k == myUid ? myInfo = v : opInfo = v);

    if (myInfo == null || opInfo == null) {
      return const Scaffold(body: Center(child: Text('خطأ في تحميل المتنافسين')));
    }

    final isFinished = (questions.isNotEmpty && currentIndex >= questions.length) || data['status'] == 'finished' || opInfo!['status'] == 'disconnected';
    final isWinner = (myInfo!['score'] ?? 0) > (opInfo!['score'] ?? 0);

    useEffect(() {
      if (isFinished && isWinner) {
        confettiController.play();
        if (isSoundOn) {
          SoundService.playLevelComplete();
        }
      }
      return null;
    }, [isFinished]);

    final selectedOptions = useState<List<dynamic>>([]);
    final isOptionCorrect = useState<bool?>(null);
    final isCheckingAnswer = useState<bool>(false);

    useEffect(() {
      selectedOptions.value = [];
      isOptionCorrect.value = null;
      isCheckingAnswer.value = false;
      return null;
    }, [currentIndex]);

    void handleAnswer(Map q) async {
      if (isCheckingAnswer.value || selectedOptions.value.isEmpty) return;
      isCheckingAnswer.value = true;
      
      // Basic evaluation: for now, if it's multiple choice, we check if the selected exists in correct ones
      // In professional Edu games, we usually compare the whole set.
      bool isCorrect = false;
      
      if (q['question_type'] == 'multiple_choices') {
        final optionsData = q['options'];
        List<dynamic> choices = [];
        if (optionsData is List) choices = optionsData;
        else if (optionsData is Map && optionsData['choices'] is List) choices = optionsData['choices'];
        
        final correctIds = choices
            .where((opt) => opt['is_correct'] == true || opt['is_correct'] == 1)
            .map((opt) => opt['id']?.toString() ?? choices.indexOf(opt).toString())
            .toList();
            
        // Check if all selected are in correctIds AND we have at least one correct (or all correct if formal)
        // For simplicity: if the first selected matches any correct one (if single correct)
        // or compare lists if multi-correct.
        if (correctIds.length == 1) {
          isCorrect = selectedOptions.value.contains(correctIds.first);
        } else {
          // Compare as sets
          final selectedSet = selectedOptions.value.toSet();
          final correctSet = correctIds.toSet();
          isCorrect = selectedSet.isNotEmpty && selectedSet.difference(correctSet).isEmpty && correctSet.difference(selectedSet).isEmpty;
        }
      } else {
        // True/False
        bool correctIsTrue = q['correct_answer'] == 1 || q['correct_answer'] == true;
        if (q['options'] is Map && q['options']['correct'] != null) {
          correctIsTrue = q['options']['correct'] == true || q['options']['correct'] == 1;
        }
        final ans = selectedOptions.value.first == 'true';
        isCorrect = ans == correctIsTrue;
      }

      isOptionCorrect.value = isCorrect;
      
      if (isSoundOn) {
        isCorrect ? SoundService.playSuccess() : SoundService.playError();
      }
      isCorrect ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();

      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (!context.mounted) return;
        final snap = await matchRef.child('currentQuestionIndex').get();
        if (snap.value == currentIndex) {
          if (isCorrect) await matchRef.child('players/$myUid/score').set((myInfo!['score'] ?? 0) + 10);
          await matchRef.child('currentQuestionIndex').set(currentIndex + 1);
        }
      });
    }
    final isPopped = useRef(false);

    void submitResult(int score, bool winner) async {
      if (isSubmitting.value || isPopped.value) return;
      isSubmitting.value = true;
      try {
        await ref
            .read(challengeRepositoryProvider)
            .submitResult(unitId: unitId, isWinner: winner, pointsGained: score);

        await ref.read(userNotifierProvider.notifier).getUser();
        
        // Update match status before popping
        try {
          await matchRef.child('status').set('finished');
        } catch (_) {}

        if (context.mounted && !isPopped.value) {
          isPopped.value = true;
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 26),
                        12.horizontalSpace,
                        Flexible(
                          child: Text(
                            'حدث خطأ أثناء حفظ النتيجة: $e',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SomarSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } finally {
        // Safe update of state
        Future.microtask(() {
          if (context.mounted) {
             isSubmitting.value = false;
          }
        });
      }
    }

    final isPrivate = data['isPrivate'] ?? false;
    final messagesMap = (data['messages'] as Map<dynamic, dynamic>?) ?? {};
    final messages = messagesMap.values.toList()
      ..sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

    // Play sound when new message arrives (not from self)
    useEffect(() {
      if (messages.isNotEmpty && messages.last['uid'] != myUid && isSoundOn) {
        SoundService.playChatPop();
      }
      return null;
    }, [messages.length]);

    void sendMessage(String text) {
      if (text.trim().isEmpty) return;
      if (isSoundOn) SoundService.playClickPremium();
      final msgRef = matchRef.child('messages').push();
      msgRef.set({
        'uid': myUid,
        'name': user?.name ?? 'Guest',
        'text': text,
        'timestamp': ServerValue.timestamp,
      });
      matchRef.child('players/$myUid/lastMessage').set(text);
      Future.delayed(const Duration(seconds: 4), () {
        matchRef.child('players/$myUid/lastMessage').set('');
      });
    }

    void showChat() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => _ChallengeChatSheet(
          messages: messages,
          myUid: myUid,
          onSend: sendMessage,
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 800 ? (constraints.maxWidth - 700) / 2 : 20.w;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Dynamic Background
              Positioned(
                top: -50.h,
                right: -50.w,
                child: Container(
                  width: 250.r,
                  height: 250.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withOpacity(isDark ? 0.08 : 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 100.h,
                left: -80.w,
                child: Container(
                  width: 300.r,
                  height: 300.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7209B7).withOpacity(isDark ? 0.05 : 0.03),
                  ),
                ),
              ),

              Column(
                children: [
                  _buildBattleHeader(myInfo!, opInfo!, horizontalPadding, isDark),
                  if (!isFinished) _buildTimer(currentIndex, questions[currentIndex], horizontalPadding, (q) => handleAnswer(q), isDark),
                  Expanded(
                    child: isFinished
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: _buildFinishedState(isWinner, opInfo!['status'] == 'disconnected',
                                myInfo!['score'] ?? 0, ref, matchRef, isSubmitting.value, submitResult, isDark),
                          )
                        : SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Column(
                                children: [
                                  40.verticalSpace,
                                  _buildQuestionArea(
                                    questions[currentIndex], 
                                    currentIndex, 
                                    questions.length,
                                    (id) {
                                      if (isCheckingAnswer.value) return;
                                      if (selectedOptions.value.contains(id)) {
                                        selectedOptions.value = List.from(selectedOptions.value)..remove(id);
                                      } else {
                                        selectedOptions.value = List.from(selectedOptions.value)..add(id);
                                      }
                                    }, 
                                    selectedOptions.value, 
                                    isOptionCorrect.value, 
                                    isDark
                                  ),
                                  40.verticalSpace,
                                  if (!isCheckingAnswer.value && selectedOptions.value.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      height: 52.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.r),
                                        gradient: const LinearGradient(colors: [AppColors.primaryColor, Color(0xFF059669)]),
                                        boxShadow: [
                                          BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () => handleAnswer(questions[currentIndex]),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                        ),
                                        child: Text(
                                          "التحقق",
                                          style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
                                        ),
                                      ),
                                    ).animate().fadeIn().scale(),
                                  40.verticalSpace,
                                ],
                              ),
                            ),
                          ),
                  ),
                  if (!isFinished) 
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 10.h,
                        left: horizontalPadding,
                        right: horizontalPadding,
                      ),
                      child: Opacity(
                        opacity: selectedOptions.value.isEmpty ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: selectedOptions.value.isNotEmpty,
                          child: _buildEmojiPicker(matchRef, myUid, isPrivate, isSoundOn, showChat, isDark),
                        ),
                      ),
                    ),
                ],
              ),
              if (!isFinished && isCheckingAnswer.value)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFeedbackPanel(isOptionCorrect.value ?? false, isDark),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildFeedbackPanel(bool isCorrect, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.primaryColor : const Color(0xFFF43F5E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppColors.primaryColor : const Color(0xFFF43F5E)).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25.w, 15.h, 25.w, 40.h),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: Icon(isCorrect ? Icons.check_circle : Icons.error, color: Colors.white, size: 28.sp),
              ),
              20.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect ? "إجابة عبقرية! ✨" : "مرة أخرى ستنجح! 💪",
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
                    ),
                    Text(
                      isCorrect ? "+10 نقاط لرصيدك" : "لا بأس، استعن بالله وراجعها ثانية",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp, fontFamily: 'SomarSans'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
                child: Text(
                  "تابع التحدي",
                  style: TextStyle(color: isCorrect ? AppColors.primaryColor : const Color(0xFFF43F5E), fontWeight: FontWeight.bold, fontSize: 13.sp, fontFamily: 'SomarSans'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildBattleHeader(Map my, Map op, double horizontalPadding, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 15.h, horizontalPadding, 15.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayerProfile(my, AppColors.primaryColor, true),
          _buildBattleBadge(isDark),
          _buildPlayerProfile(op, const Color(0xFFF43F5E), false),
        ],
      ),
    );
  }

  Widget _buildPlayerProfile(Map info, Color color, bool isLeft) {
    final score = info['score'] ?? 0;
    final name = info['name'] ?? 'لاعب';
    final pic = info['pic'] ?? '';
    final themeColor = isLeft ? AppColors.primaryColor : const Color(0xFFF43F5E);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildHexagonAvatar(pic, color),
            Positioned(
              bottom: -4.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.r), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)]),
                child: Center(
                  child: Text(
                    name.toString().split(' ').first,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
        8.verticalSpace,
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(
              "$score",
              key: ValueKey('score_$score'),
              style: TextStyle(
                color: themeColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'SomarSans',
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).shake(duration: 400.ms),
            if (score > 0)
              Positioned(
                top: -25.h,
                child: Text(
                  "+10 💎",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                )
                .animate(key: ValueKey('points_$score'))
                .fadeIn()
                .slideY(begin: 0, end: -0.5)
                .then(delay: 500.ms)
                .fadeOut(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHexagonAvatar(dynamic pic, Color color) {
    return Container(
      width: 55.w,
      height: 60.h,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shape: const HexagonShapeBorder(),
        shadows: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const ShapeDecoration(
          color: Color(0xFF1E293B),
          shape: HexagonShapeBorder(),
        ),
        child: ClipPath(
          clipper: _HexagonClipper(),
          child: CustomCachedImage(
            imageUrl: pic?.toString() ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildBattleBadge(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Text("⚡", style: TextStyle(fontSize: 14)),
          4.horizontalSpace,
          Text(
            "تحدي",
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(int index, Map q, double horizontalPadding, Function(Map) handleAnswer, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.h),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(index),
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(seconds: 15),
        onEnd: () => handleAnswer(q),
        builder: (context, value, _) => Container(
          height: 10.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: value.clamp(0.01, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor, 
                            const Color(0xFF059669),
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Progress Glow
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: (1 - value) * MediaQuery.of(context).size.width,
                    width: 40.w,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionArea(Map q, int current, int total, Function(dynamic) toggleOption, List<dynamic> selected, bool? isCorrect, bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "سؤال ${current + 1} من $total",
                          style: TextStyle(
                            color: const Color(0xFF10B981),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                        6.horizontalSpace,
                        const Text("✨", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    2.verticalSpace,
                    Text(
                      q['question_type'] == 'multiple_choices' ? 'اختر الإجابة' : 'أجب بصحيح أو خطأ',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textBlack,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                      ),
                    ),
                  ],
                ),
              ),
              const Text("📖", style: TextStyle(fontSize: 32)),
            ],
          ).animate(key: ValueKey('header_$current')).fadeIn(duration: 400.ms),
          
          15.verticalSpace,
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withOpacity(0.6) : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              q['question'] ?? '',
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textBlack.withOpacity(0.8),
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'SomarSans',
              ),
              textAlign: TextAlign.start,
            ),
          ).animate(key: ValueKey('qcard_$current')).fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),
          
          20.verticalSpace,
          
          ..._buildOptions(q, toggleOption, selected, isCorrect, isDark),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(Map q, Function(dynamic) toggleOption, List<dynamic> selected, bool? isCorrect, bool isDark) {
    if (q['question_type'] == 'multiple_choices') {
      final optionsData = q['options'];
      List<dynamic> choices = [];
      if (optionsData is List) choices = optionsData;
      else if (optionsData is Map && optionsData['choices'] is List) choices = optionsData['choices'];

      int idx = 0;
      return choices.map<Widget>((opt) {
        final currentIdx = idx++;
        final String text = opt['option'] ?? opt['text'] ?? '';
        final bool isProper = opt['is_correct'] == true || opt['is_correct'] == 1;
        final dynamic optId = opt['id']?.toString() ?? currentIdx.toString();

        bool isSelected = selected.contains(optId);
        bool isRightAnswer = isCorrect != null && isProper && isSelected;
        bool isWrongAnswer = isCorrect != null && !isProper && isSelected;
        bool shouldShowGreen = isCorrect != null && isProper;

        return _buildOptionButton(
          text, isSelected, isRightAnswer, isWrongAnswer, shouldShowGreen, 
          () => toggleOption(optId), isDark
        );
      }).toList();
    } else {
      bool correctIsTrue = q['correct_answer'] == 1 || q['correct_answer'] == true;
      if (q['options'] is Map && q['options']['correct'] != null) {
        correctIsTrue = q['options']['correct'] == true || q['options']['correct'] == 1;
      }

      return [
        Row(
          children: [
            _buildTrueFalseOption('صحيح', 'true', selected, isCorrect, correctIsTrue, toggleOption, const Color(0xFF10B981), isDark),
            12.horizontalSpace,
            _buildTrueFalseOption('خطأ', 'false', selected, isCorrect, !correctIsTrue, toggleOption, const Color(0xFFF43F5E), isDark),
          ]
        )
      ];
    }
  }

  Widget _buildOptionButton(
      String text, bool isSelected, bool isRightAnswer, bool isWrongAnswer, bool shouldShowGreen, VoidCallback onTap, bool isDark) {
      
    Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    
    if (isRightAnswer || shouldShowGreen) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(0.12); 
        textColor = const Color(0xFF10B981);
    } else if (isWrongAnswer) {
        borderColor = const Color(0xFFF43F5E);
        bgColor = const Color(0xFFF43F5E).withOpacity(0.12);
        textColor = const Color(0xFFF43F5E);
    } else if (isSelected) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(isDark ? 0.15 : 0.08);
        textColor = const Color(0xFF10B981);
    }
    
    Widget indicator;
    if (isRightAnswer || shouldShowGreen) {
       indicator = Container(
         width: 18.sp, height: 18.sp,
         decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
         child: Icon(Icons.check, size: 12.sp, color: Colors.white),
       );
    } else if (isWrongAnswer) {
       indicator = Container(
         width: 18.sp, height: 18.sp,
         decoration: const BoxDecoration(color: Color(0xFFF43F5E), shape: BoxShape.circle),
         child: Icon(Icons.close, size: 12.sp, color: Colors.white),
       );
    } else if (isSelected) {
       indicator = Container(
         width: 18.sp, height: 18.sp,
         decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF10B981), width: 2), color: const Color(0xFF10B981)),
         child: Center(child: Container(width: 6.sp, height: 6.sp, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
       );
    } else {
       indicator = Container(
         width: 18.sp, height: 18.sp,
         decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF475569), width: 1.5)),
       );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
        gradient: isSelected ? LinearGradient(
          colors: [
            isDark ? const Color(0xFF0C4A6E).withOpacity(0.4) : const Color(0xFFBAE6FD).withOpacity(0.3), 
            isDark ? const Color(0xFF1E293B) : Colors.white
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ) : null,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor,
          width: isSelected || isRightAnswer || isWrongAnswer || shouldShowGreen ? 1.8 : 1,
        ),
        boxShadow: [
          if (isSelected || isRightAnswer || isWrongAnswer || shouldShowGreen)
            BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
          else
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15.sp,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      fontFamily: 'SomarSans',
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                10.horizontalSpace,
                indicator,
              ],
            ),
          ),
        ),
      ),
    ).animate(target: isSelected || isRightAnswer || isWrongAnswer || shouldShowGreen ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.01, 1.01));
  }

  Widget _buildTrueFalseOption(String text, String id, List<dynamic> selected, bool? isCorrect,
      bool isProperAns, Function(dynamic) toggleOption, Color themeColor, bool isDark) {
    bool isSelected = selected.contains(id);
    bool isRightAnswer = isCorrect != null && isProperAns && isSelected;
    bool isWrongAnswer = isCorrect != null && !isProperAns && isSelected;
    bool shouldShowGreen = isCorrect != null && isProperAns;

    Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    
    if (isRightAnswer || shouldShowGreen) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(0.12); 
        textColor = const Color(0xFF10B981);
    } else if (isWrongAnswer) {
        borderColor = const Color(0xFFF43F5E);
        bgColor = const Color(0xFFF43F5E).withOpacity(0.12);
        textColor = const Color(0xFFF43F5E);
    } else if (isSelected) {
        borderColor = themeColor;
        bgColor = themeColor.withOpacity(isDark ? 0.15 : 0.08);
        textColor = themeColor;
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
          gradient: isSelected ? LinearGradient(
            colors: [
              themeColor.withOpacity(isDark ? 0.2 : 0.1), 
              isDark ? const Color(0xFF1E293B) : Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ) : null,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: isSelected || isRightAnswer || isWrongAnswer || shouldShowGreen ? 1.8 : 1,
          ),
          boxShadow: [
            if (isSelected || isRightAnswer || isWrongAnswer || shouldShowGreen)
              BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
            else
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => toggleOption(id),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18.sp,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    fontFamily: 'SomarSans',
                  ),
                ),
              ),
            ),
          ),
        ),
      ).animate(target: isSelected || isRightAnswer || isWrongAnswer || shouldShowGreen ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
    );
  }

  Widget _buildFinishedState(bool winner, bool ranAway, int score, WidgetRef ref,
      DatabaseReference matchRef, bool loading, Function(int, bool) onSubmit, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          ranAway ? "🏆 المنافس انسحب!" : (winner ? "تهانينا! أنت الصاحب القرآن 🏆" : "حظ ممتع المرة القادمة ⚔️"),
          style: TextStyle(
            fontSize: 28.sp,
            color: winner || ranAway ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
            fontWeight: FontWeight.w900,
            fontFamily: 'SomarSans',
            shadows: [
              Shadow(
                color: (winner || ranAway ? const Color(0xFF10B981) : const Color(0xFFF43F5E)).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
        
        20.verticalSpace,
        
        DynamicAppAsset(
          assetKey: winner || ranAway ? 'refiq_perfect' : 'refiq_angry',
          fallbackAssetPath: winner || ranAway ? SVGs.refiqPerfect : SVGs.refiqAngry,
          type: AppAssetType.svg,
          height: 180.h,
        ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut, duration: 1200.ms),
        
        30.verticalSpace,
        
        Row(
          children: [
            Expanded(
              child: _buildFinishedStatCard(
                title: 'نقاطك 💎',
                value: score.toString(),
                icon: Icons.flash_on_rounded,
                startColor: const Color(0xFF10B981),
                isDark: isDark,
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ),
            12.horizontalSpace,
            Expanded(
              child: _buildFinishedStatCard(
                title: 'النتيجة 🏆',
                value: winner || ranAway ? 'فوز' : 'خسارة',
                icon: winner || ranAway ? Icons.emoji_events : Icons.close_rounded,
                startColor: winner || ranAway ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                isDark: isDark,
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ),
          ],
        ),
        
        40.verticalSpace,
        
        if (loading)
          const CircularProgressIndicator(color: Color(0xFF10B981))
        else
          Container(
            width: double.infinity,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22.r),
                onTap: () => onSubmit(score, winner),
                child: Center(
                  child: Text(
                    "حفظ النتيجة والعودة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'SomarSans',
                    ),
                  ),
                ),
              ),
            ),
          ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0),
      ],
    ).animate().fadeIn();
  }

  Widget _buildFinishedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color startColor,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.8) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: startColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 18.sp, color: startColor),
              ),
              8.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SomarSans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontFamily: 'SomarSans',
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEmojiPicker(DatabaseReference matchRef, String uid, bool isPrivate, bool isSoundOn, VoidCallback onChat, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h, left: 30.w, right: 30.w),
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isPrivate)
            IconButton(
              onPressed: onChat,
              icon: Icon(Icons.chat_bubble_outline, color: isDark ? Colors.white : const Color(0xFF1E293B), size: 22.sp),
              padding: EdgeInsets.zero,
            ),
          if (isPrivate) Container(width: 1, height: 20, color: isDark ? Colors.white10 : Colors.black12),
          ...['😂', '🔥', '💪', '😱', '🥳'].map((e) {
            return InkWell(
              onTap: () {
                if (isSoundOn) SoundService.playClickPremium();
                matchRef.child('players/$uid/emoji').set(e);
                Future.delayed(const Duration(seconds: 3), () => matchRef.child('players/$uid/emoji').set(''));
              },
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(e, style: TextStyle(fontSize: 24.sp))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 2.seconds),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChallengeChatSheet extends HookWidget {
  final List<dynamic> messages;
  final String myUid;
  final Function(String) onSend;

  const _ChallengeChatSheet({required this.messages, required this.myUid, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final scrollController = useScrollController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (scrollController.hasClients) {
           scrollController.jumpTo(scrollController.position.maxScrollExtent);
         }
      });
      return null;
    }, [messages.length]);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 0.7.sh,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          15.verticalSpace,
          Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text("دردشة الأصدقاء 💬", style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans')),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final m = messages[i];
                final isMe = m['uid'] == myUid;
                return Align(
                  alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF10B981).withOpacity(isDark ? 0.2 : 0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: isMe ? const Color(0xFF10B981).withOpacity(0.3) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        if (!isMe) Text(m['name'] ?? '', style: TextStyle(color: const Color(0xFFF43F5E), fontSize: 10.sp, fontWeight: FontWeight.bold)),
                        Text(m['text'] ?? '', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 13.sp, fontFamily: 'SomarSans')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: "اكتب رسالة...",
                      hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 14.sp),
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.r), 
                        borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05))
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.r), 
                        borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05))
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    ),
                    onSubmitted: (val) {
                      onSend(val);
                      controller.clear();
                    },
                  ),
                ),
                10.horizontalSpace,
                IconButton(
                  onPressed: () {
                    onSend(controller.text);
                    controller.clear();
                  },
                  icon: const Icon(Icons.send_rounded, color: Color(0xFFF59E0B)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonShapeBorder extends ShapeBorder {
  const HexagonShapeBorder();
  @override EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);
  @override Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.right, rect.top + rect.height * 0.25);
    path.lineTo(rect.right, rect.bottom - rect.height * 0.25);
    path.lineTo(rect.center.dx, rect.bottom);
    path.lineTo(rect.left, rect.bottom - rect.height * 0.25);
    path.lineTo(rect.left, rect.top + rect.height * 0.25);
    path.close();
    return path;
  }
  @override void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
  @override ShapeBorder scale(double t) => this;
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();
    return path;
  }
  @override bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
