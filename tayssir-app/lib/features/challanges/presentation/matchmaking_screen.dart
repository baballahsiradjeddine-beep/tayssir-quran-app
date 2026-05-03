import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/app_buttons/app_button.dart';
import 'package:tayssir/features/challanges/data/matchmaking_service.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';

class MatchmakingScreen extends HookConsumerWidget {
  final int unitId;
  final String courseTitle;
  final String? initialSearchMode;
  final String? invitationCode;

  const MatchmakingScreen({
    super.key,
    required this.unitId,
    required this.courseTitle,
    this.initialSearchMode,
    this.invitationCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusText = useState<String>('');
    final error = useState<String?>(null);
    final isSoundOn = ref.watch(isSoundEnabledProvider);
    final searchMode = useState<String>(initialSearchMode ?? 'initial'); 
    final privateCode = useState<String?>(invitationCode);
    final codeController = useTextEditingController();

    void goToArena(String id) {
      if (!context.mounted) return;
      context.pushReplacementNamed(
        AppRoutes.challengeArena.name,
        extra: {
          'matchId': id,
          'unitId': unitId,
          'courseTitle': courseTitle,
        },
      );
    }

    useEffect(() {
      if (searchMode.value == 'create_private' && privateCode.value != null) {
        final db = FirebaseDatabase.instance.ref();
        db.child('challenges/private_codes/${privateCode.value}').get().then((snap) {
          if (snap.exists) {
            final mid = snap.value as String;
            final sub = db.child('challenges/matches/$mid/status').onValue.listen((event) {
              if (event.snapshot.value == 'starting') {
                if (isSoundOn) SoundService.playMatchFound();
                goToArena(mid);
              }
            });
            return sub.cancel;
          }
        });
      }
      return null;
    }, [searchMode.value, privateCode.value]);

    Future<void> startRandomSearch() async {
      searchMode.value = 'random';
      statusText.value = 'جاري البحث عن خصم قوي...';
      try {
        final service = ref.read(matchmakingServiceProvider);
        final id = await service.findMatchOrJoinQueue(unitId, courseTitle);
        if (id != null) {
          if (isSoundOn) SoundService.playMatchFound();
          statusText.value = 'تم العثور على خصم! ⚔️';
          await Future.delayed(const Duration(seconds: 1));
          goToArena(id);
        }
      } catch (e) {
        error.value = 'حدث خطأ أثناء البحث: $e';
      }
    }

    Future<void> handleCreatePrivate() async {
      searchMode.value = 'create_private';
      try {
        final service = ref.read(matchmakingServiceProvider);
        final code = await service.createPrivateMatch(unitId, courseTitle);
        privateCode.value = code;
      } catch (e) {
        error.value = 'خطأ في إنشاء الغرفة: $e';
      }
    }

    Future<void> handleJoinPrivate() async {
      if (codeController.text.length < 4) return;
      try {
        statusText.value = 'جاري الانضمام للغرفة...';
        final service = ref.read(matchmakingServiceProvider);
        final id = await service.joinPrivateMatch(codeController.text);
        if (id != null) {
           if (isSoundOn) SoundService.playMatchFound();
           goToArena(id);
        }
      } catch (e) {
        String message = e.toString().contains('Exception: ') 
            ? e.toString().replaceAll('Exception: ', '') 
            : e.toString();
            
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
                    color: const Color(0xFFF43F5E), // Red state color
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
                            message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SomarSans',
                            ),
                            overflow: TextOverflow.visible,
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
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: AppScaffold(
        bodyBackgroundColor: isDark ? const Color(0xFF0B1120) : Colors.white,
        includeBackButton: false, // Using custom header below
        paddingX: 0, // Using internal padding below
        topSafeArea: true,
        onPopScope: () {
          if (searchMode.value == 'initial') {
            context.pop();
          } else {
            ref.read(matchmakingServiceProvider).cancelSearch();
            searchMode.value = 'initial';
          }
        },
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final bool isDesktop = availableWidth > 800;
            const double targetContentWidth = 700; // Focused width for matchmaking

            final double horizontalPadding = isDesktop 
                ? (availableWidth > targetContentWidth ? (availableWidth - targetContentWidth) / 2 : 40.0)
                : 25.w;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    // --- Custom Header Row ---
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              courseTitle,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white60 : AppColors.greyColor,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20.sp,
                                    color: isDark ? Colors.white : AppColors.primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  if (searchMode.value == 'initial') {
                                    context.pop();
                                  } else {
                                    ref.read(matchmakingServiceProvider).cancelSearch();
                                    searchMode.value = 'initial';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    20.verticalSpace,
                    _buildVisualHeader(isDark),
                    40.verticalSpace,
                    if (error.value != null)
                      _buildErrorState(context, error.value!, isDark)
                    else if (searchMode.value == 'initial')
                      _buildInitialState(startRandomSearch, handleCreatePrivate,
                          () => searchMode.value = 'join_private', isDark)
                    else if (searchMode.value == 'random')
                      _buildLoadingState(statusText.value, isDark)
                    else if (searchMode.value == 'create_private')
                      _buildPrivateCreatedState(privateCode.value, isDark)
                    else if (searchMode.value == 'join_private')
                      _buildJoinPrivateState(codeController, handleJoinPrivate,
                          () => searchMode.value = 'initial', isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisualHeader(bool isDark) {
    return Column(
      children: [
        SvgPicture.asset(SVGs.refiqBoarding, height: 180.h)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut),
        25.verticalSpace,
        Text(
          "الاستعداد للمعركة ⚔️",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textBlack,
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'SomarSans',
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState(VoidCallback onRandom, VoidCallback onCreate, VoidCallback onJoin, bool isDark) {
    return Column(
      children: [
        Text(
          "اختر كيف تريد مواجهة منافسك اليوم",
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black45,
            fontSize: 15.sp,
            fontFamily: 'SomarSans',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        40.verticalSpace,
        _buildPremiumMenuButton(
          "بحث عشوائي (1 ضد 1) 🚀",
          [const Color(0xFF10B981), const Color(0xFF059669)],
          onRandom,
        ),
        20.verticalSpace,
        _buildPremiumMenuButton(
          "تحدي صديق مقرب 🤝",
          [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          onCreate,
        ),
        25.verticalSpace,
        TextButton(
          onPressed: onJoin,
          child: Text(
            "لديك كود تحدي؟ انضم هنا 🔑",
            style: TextStyle(
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w900,
              fontFamily: 'SomarSans',
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPremiumMenuButton(String label, List<Color> gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shine effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'SomarSans',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(begin: const Offset(1, 1), end: const Offset(0.98, 0.98), duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildLoadingState(String text, bool isDark) {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFF10B981)),
        25.verticalSpace,
        Text(text, style: TextStyle(color: isDark ? Colors.white : AppColors.textBlack, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPrivateCreatedState(String? code, bool isDark) {
    return Column(
      children: [
        Text(
          "كود الغرفة الخاص بك 🗝️",
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black45,
            fontSize: 16.sp,
            fontFamily: 'SomarSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        20.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Text(
            code ?? "....",
            style: TextStyle(
              color: const Color(0xFF10B981),
              fontSize: 52.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 12,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
        30.verticalSpace,
        Text(
          "أرسل هذا الكود لمنافسك وانتظره هنا...",
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black26,
            fontStyle: FontStyle.italic,
            fontFamily: 'SomarSans',
            fontSize: 13.sp,
          ),
          textAlign: TextAlign.center,
        ),
        40.verticalSpace,
        const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFF59E0B))
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2000.ms),
      ],
    );
  }

  Widget _buildJoinPrivateState(TextEditingController controller, VoidCallback onJoin, VoidCallback onBack, bool isDark) {
    return Column(
      children: [
        Text(
          "أدخل كود التحدي",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textBlack,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'SomarSans',
          ),
        ),
        10.verticalSpace,
        Text(
          "المكون من 4 أرقام",
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 14.sp, fontFamily: 'SomarSans'),
        ),
        30.verticalSpace,
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF10B981),
            fontSize: 40.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 15,
            fontFamily: 'SomarSans',
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: "0000",
            hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            counterText: "",
            contentPadding: EdgeInsets.symmetric(vertical: 20.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
        ),
        35.verticalSpace,
        _buildPremiumMenuButton(
          "انطلاق! ⚔️",
          [const Color(0xFF10B981), const Color(0xFF059669)],
          onJoin,
        ),
        20.verticalSpace,
        TextButton(
          onPressed: onBack,
          child: Text(
            "تراجع",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black26,
              fontSize: 14.sp,
              fontFamily: 'SomarSans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String msg, bool isDark) {
    final isCapacityError = msg.contains('ممتلئ') || msg.contains('متاح') || 
                            msg.contains('مشغول') || msg.contains('انقطع');
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isCapacityError 
                  ? const Color(0xFFF59E0B).withOpacity(0.4)
                  : const Color(0xFFF43F5E).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                isCapacityError ? '⚠️' : '❌',
                style: TextStyle(fontSize: 48.sp),
              ),
              16.verticalSpace,
              Text(
                isCapacityError ? 'السيرفر مشغول' : 'حدث خطأ',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'SomarSans',
                ),
              ),
              12.verticalSpace,
              Text(
                msg.replaceAll('Exception: ', ''),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontFamily: 'SomarSans',
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        30.verticalSpace,
        _buildPremiumMenuButton(
          isCapacityError ? 'حاول مجدداً 🔄' : 'إعادة المحاولة',
          isCapacityError 
              ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
          () => context.pop(),
        ),
        12.verticalSpace,
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'العودة للقائمة',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14.sp,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

