import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
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
      statusText.value = 'جاري البحث عن رفيق في طريق العلم...';
      try {
        final service = ref.read(matchmakingServiceProvider);
        final id = await service.findMatchOrJoinQueue(unitId, courseTitle);
        if (id != null) {
          if (isSoundOn) SoundService.playMatchFound();
          statusText.value = 'تم العثور على منافس! 🕊️';
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
        error.value = 'خطأ في إنشاء المجلس: $e';
      }
    }

    Future<void> handleJoinPrivate() async {
      if (codeController.text.length < 4) return;
      try {
        statusText.value = 'جاري الانضمام للمجلس...';
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
        bodyBackgroundColor: isDark ? null : AppColors.warmBackground,
        includeBackButton: false,
        paddingX: 0,
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
            const double targetContentWidth = 700;

            final double horizontalPadding = isDesktop 
                ? (availableWidth > targetContentWidth ? (availableWidth - targetContentWidth) / 2 : 40.0)
                : 25.w;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    5.verticalSpace,
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
                                color: isDark ? Colors.white60 : AppColors.warmTitle,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            PositionedDirectional(
                              start: 0,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                                    borderRadius: BorderRadius.circular(14.r),
                                    boxShadow: isDark ? null : [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18.sp,
                                    color: isDark ? Colors.white : AppColors.warmTitle,
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
        Container(
          width: 140.r,
          height: 140.r,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.emerald600.withOpacity(0.2), width: 2),
          ),
          child: Center(
            child: Text("🤝", style: TextStyle(fontSize: 60.sp)),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
        25.verticalSpace,
        Text(
          "المسارعة للخيرات 🌿",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.warmTitle,
            fontSize: 24.sp,
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
          "اختر كيف تريد بدء المنافسة اليوم",
          style: TextStyle(
            color: isDark ? Colors.white60 : AppColors.warmSubtitle,
            fontSize: 15.sp,
            fontFamily: 'SomarSans',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        40.verticalSpace,
        _buildPremiumMenuButton(
          "منافسة عفوية (1 ضد 1) 🚀",
          [AppColors.emerald600, const Color(0xFF10B981)],
          onRandom,
        ),
        20.verticalSpace,
        _buildPremiumMenuButton(
          "استدعاء صديق للمجلس 🤝",
          [const Color(0xFFD97706), const Color(0xFFF59E0B)],
          onCreate,
        ),
        25.verticalSpace,
        TextButton(
          onPressed: onJoin,
          child: Text(
            "لديك مفتاح المجلس؟ انضم هنا 🔑",
            style: TextStyle(
              color: AppColors.emerald600,
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
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
      ),
    ).animate().scale(begin: const Offset(1, 1), end: const Offset(0.98, 0.98), duration: 200.ms);
  }

  Widget _buildLoadingState(String text, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80.r,
              height: 80.r,
              child: const CircularProgressIndicator(
                color: AppColors.emerald600,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text("🔍", style: TextStyle(fontSize: 30.sp)),
          ],
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
        30.verticalSpace,
        Text(
          text, 
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.warmTitle, 
            fontSize: 17.sp, 
            fontWeight: FontWeight.w900,
            fontFamily: 'SomarSans',
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateCreatedState(String? code, bool isDark) {
    return Column(
      children: [
        Text(
          "مفتاح المجلس الخاص بك 🗝️",
          style: TextStyle(
            color: isDark ? Colors.white60 : AppColors.warmSubtitle,
            fontSize: 16.sp,
            fontFamily: 'SomarSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        20.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.emerald600.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald600.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Text(
            code ?? "....",
            style: TextStyle(
              color: AppColors.emerald600,
              fontSize: 52.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 12,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
        30.verticalSpace,
        Text(
          "أرسل هذا المفتاح لمنافسك وانتظره هنا...",
          style: TextStyle(
            color: isDark ? Colors.white38 : AppColors.warmSubtitle.withOpacity(0.5),
            fontStyle: FontStyle.italic,
            fontFamily: 'SomarSans',
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
        40.verticalSpace,
        const CircularProgressIndicator(strokeWidth: 3, color: AppColors.emerald600)
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2.seconds),
      ],
    );
  }

  Widget _buildJoinPrivateState(TextEditingController controller, VoidCallback onJoin, VoidCallback onBack, bool isDark) {
    return Column(
      children: [
        Text(
          "أدخل مفتاح المجلس",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.warmTitle,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'SomarSans',
          ),
        ),
        30.verticalSpace,
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.emerald600,
            fontSize: 40.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 15,
            fontFamily: 'SomarSans',
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: "0000",
            hintStyle: TextStyle(color: isDark ? Colors.white10 : Colors.black12),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            counterText: "",
            contentPadding: EdgeInsets.symmetric(vertical: 20.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: AppColors.emerald600.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.emerald600, width: 2),
            ),
          ),
        ),
        35.verticalSpace,
        _buildPremiumMenuButton(
          "دخول المجلس 🌿",
          [AppColors.emerald600, const Color(0xFF10B981)],
          onJoin,
        ),
        20.verticalSpace,
        TextButton(
          onPressed: onBack,
          child: Text(
            "تراجع",
            style: TextStyle(
              color: isDark ? Colors.white38 : AppColors.warmSubtitle,
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Text("❌", style: TextStyle(fontSize: 48.sp)),
              16.verticalSpace,
              Text(
                "حدث خطأ",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp, fontFamily: 'SomarSans'),
              ),
              12.verticalSpace,
              Text(
                msg.replaceAll('Exception: ', ''),
                style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'SomarSans'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        30.verticalSpace,
        _buildPremiumMenuButton(
          "إعادة المحاولة",
          [Colors.grey.shade700, Colors.grey.shade800],
          () => context.pop(),
        ),
      ],
    );
  }
}

