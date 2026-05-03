import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/tools/grade_calc/speciality_model.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import '../../../common/bayan_advice_widget.dart';
import '../../../constants/strings.dart';
import 'state/grade_controller.dart';
import 'widgets/speciality_drop_down.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'subject_widget.dart';
import 'package:go_router/go_router.dart';

class GradeCalculatorScreen extends HookConsumerWidget {
  const GradeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const GradeCalculatorBody();
  }
}

class GradeCalculatorBody extends HookConsumerWidget {
  const GradeCalculatorBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialities = ref.watch(specialityProvider);
    final currentSpeciality = useState<SpecialityModel>(specialities.first);
    final state = ref.watch(gradeControllerProvider(currentSpeciality.value));
    final isSoundOn = ref.watch(isSoundEnabledProvider);
    final wasPassing = useRef<bool>(state.isPassing);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    useEffect(() {
      if (isSoundOn && state.isPassing && !wasPassing.value) {
        SoundService.playPoints();
      }
      wasPassing.value = state.isPassing;
      return null;
    }, [state.isPassing]);

    return AppScaffold(
      topSafeArea: true,
      includeBackButton: false,
      paddingB: 0,
      paddingX: 0,
      maxWidth: 1000,
      bodyBackgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.scaffoldColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.h),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title Area (Right Side in RTL)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "حساب التقدم 📖",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'SomarSans',
                            color: isDark ? Colors.white : AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    // Navigation Area (Left Side in RTL)
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                          color: isDark ? Colors.white : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Advice Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const BayanAdviceWidget(
                            text: AppStrings.calculateGrades,
                          ),
                        ),
                      ),

                      // Speciality Dropdown
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
                          child: SpecialityDropDown(
                            items: specialities,
                            onChanged: (speciality) {
                              if (isSoundOn) SoundService.playClickPremium();
                              if (speciality != null) currentSpeciality.value = speciality;
                            },
                            selectedItem: currentSpeciality.value,
                            hintText: "اختر الجزء أو السورة",
                          ),
                        ),
                      ),

                      // Subjects Grid
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth > 600 ? 3 : 2, // 3 on wider screens, 2 on phones
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            mainAxisExtent: 85.h, // Fixed height for subject cards
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final subject = state.subjects[index];
                              return SubjectWidget(
                                subjectName: state.getSubjectName(subject.subjectId),
                                subjectGrade: subject.grade,
                                subjectCoef: state.getCofficientOfSubject(subject.subjectId),
                                onGradeChange: (grade) {
                                  if (isSoundOn) SoundService.playClickPremium();
                                  ref.read(gradeControllerProvider(currentSpeciality.value).notifier)
                                     .updateGrade(subject.subjectId, grade);
                                },
                              ).animate().fadeIn(delay: (index * 30).ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
                            },
                            childCount: state.subjects.length,
                          ),
                        ),
                      ),

                      // Bottom Spacer for Results Card
                      SliverToBoxAdapter(child: 180.verticalSpace),
                    ],
                  ),

                  // Total Result Card (Floating at bottom)
                  Positioned(
                    bottom: 85.h,
                    left: 16.w,
                    right: 16.w,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600), // Slightly narrower than page max
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "مستوى الإنجاز المتوقع :",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: isDark ? Colors.white70 : AppColors.greyColor,
                                        fontFamily: 'SomarSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    4.verticalSpace,
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: (state.isPassing ? Colors.green : Colors.red).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        state.isPassing ? "أحسنت واصل الحفظ! 🌟" : "نحتاج لمزيد من الجهد! 📖",
                                        style: TextStyle(
                                          color: state.isPassing ? Colors.green : Colors.red,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'SomarSans',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: state.isPassing 
                                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                      : [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
                                  ),
                                  borderRadius: BorderRadius.circular(18.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (state.isPassing ? Colors.green : Colors.red).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.average.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontFamily: 'SomarSans',
                                      ),
                                    ),
                                    Text(
                                      "من 20",
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(target: state.average).shimmer(duration: 1.seconds),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
