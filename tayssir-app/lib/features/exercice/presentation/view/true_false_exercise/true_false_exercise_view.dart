import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/exercice/presentation/view/question_content_widget.dart';
import 'package:tayssir/providers/data/models/true_false_exercise.dart';
import 'package:tayssir/features/exercice/presentation/view/true_false_exercise/true_false_exercise_controller.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import '../fill_in_the_blank/exercise_template.dart';

class TrueFalseExerciseView extends ConsumerWidget {
  const TrueFalseExerciseView({
    super.key,
    required this.exercise,
  });

  final TrueFalseExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trueFalseNotifierProvider(exercise));
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    void setSelection(bool value) {
      ref
          .read(trueFalseNotifierProvider(exercise).notifier)
          .selectAnswer(value);
    }

    return ExerciseTemplate(
      questionType: AppStrings.trueOrFalse,
      questionWidget: QuestionContentWidget(question: exercise.question),
      remark: exercise.remark,
      imageUrl: exercise.image,
      remarkImage: exercise.hintImage,
      choices: [
        32.verticalSpace,
        
        // Constrain the buttons to match the question width
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTrueFalseButton(
                  context: context,
                  text: 'صحيح',
                  isSelected: state.isTruePicked,
                  onTap: () => setSelection(true),
                  color: AppColors.warmAccent,
                  isDark: isDark,
                  index: 0,
                ),
                20.horizontalSpace,
                _buildTrueFalseButton(
                  context: context,
                  text: 'خطأ',
                  isSelected: state.isFalsePicked,
                  onTap: () => setSelection(false),
                  color: const Color(0xFFF43F5E),
                  isDark: isDark,
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ],
      onButtonPressed: state.canSubmit
          ? () {
              ref
                  .read(trueFalseNotifierProvider(exercise).notifier)
                  .submitAnswer(context);
            }
          : null,
      useSpacerAfterQuestion: false,
    );
  }

  Widget _buildTrueFalseButton({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    required bool isDark,
    required int index,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: MediaQuery.sizeOf(context).width > 800 ? 64.h : 50.h,
            decoration: BoxDecoration(
              color: isSelected 
                  ? color.withOpacity(isDark ? 0.2 : 0.1) 
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: isSelected ? 2.5.w : 1.5.w,
              ),
              boxShadow: isSelected 
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? color : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                  fontSize: MediaQuery.sizeOf(context).width > 800 ? 20.sp : 16.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'SomarSans',
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (400 + index * 100).ms).slideY(begin: 0.1, end: 0);
  }
}
