import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/features/exercice/presentation/view/question_content_widget.dart';
import 'package:tayssir/features/exercice/presentation/view/select_right_option/latext_text_widget.dart';
import 'package:tayssir/features/exercice/presentation/view/select_right_option/select_right_option_controller.dart';
import 'package:tayssir/providers/data/models/select_multiple_option_exercise.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import '../fill_in_the_blank/exercise_template.dart';

class SelectRightOptionExerciseView extends HookConsumerWidget {
  const SelectRightOptionExerciseView({
    super.key,
    required this.exercise,
  });

  final SelectMultipleOptionExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(selectRightOptionNotifierProvider(exercise));
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    void onSelectionChange(String option) {
      ref
          .read(selectRightOptionNotifierProvider(exercise).notifier)
          .selectAnswer(option);
    }

    return ExerciseTemplate(
      questionType: 'اختر الإجابة الصحيحة',
      remark: exercise.remark,
      imageUrl: exercise.image,
      remarkImage: exercise.hintImage,
      questionWidget: QuestionContentWidget(question: exercise.question),
      choices: exercise.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = state.selectedAnswers.contains(option.text);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.sizeOf(context).width > 800 ? 8.h : 4.h),
          child: GestureDetector(
            onTap: () => onSelectionChange(option.text),
            child: AnimatedScale(
              scale: isSelected ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: MediaQuery.sizeOf(context).width > 800 ? 16.h : 10.h,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: isDark 
                            ? [const Color(0xFF065F46).withOpacity(0.4), const Color(0xFF064E3B).withOpacity(0.6)] 
                            : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        )
                      : null,
                  color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : AppColors.surfaceWhite),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2.5.w : 1.5.w,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: LatextTextWidget(
                        text: option.cleanText,
                        isLatex: option.isLatex,
                        onLatexTap: (text) => onSelectionChange(option.text),
                        textAlign: TextAlign.right,
                        textStyle: TextStyle(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF064E3B))
                              : (isDark ? Colors.blueGrey.shade200 : const Color(0xFF334155)),
                          fontSize: MediaQuery.sizeOf(context).width > 800 ? 18.sp : 15.sp,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                    ),
                    12.horizontalSpace,
                    Container(
                      width: 22.sp,
                      height: 22.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF10B981) : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          width: 2.5,
                        ),
                        color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10.sp,
                                height: 10.sp,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ).animate().scale(duration: 200.ms),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: 0.1, end: 0);
      }).toList(),
      buttonText: 'تحقق',
      useGridOnDesktop: true,
      onButtonPressed: state.canSubmit
          ? () {
              ref
                  .read(selectRightOptionNotifierProvider(exercise).notifier)
                  .submitAnswer(context);
            }
          : null,
    );
  }
}
