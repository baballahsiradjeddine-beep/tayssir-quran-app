import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/features/exercice/presentation/view/fill_in_the_blank/fill_in_the_blank_provider.dart';
import 'package:tayssir/providers/data/models/fill_in_the_blank_exercise.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'exercise_template.dart';
import 'package:tayssir/features/exercice/presentation/view/select_right_option/latext_text_widget.dart';

class FillInTheBlankExerciseView extends ConsumerWidget {
  const FillInTheBlankExerciseView({
    super.key,
    required this.exercise,
  });

  final FillInTheBlankExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fillInTheBlankProvider(exercise));
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    List<Widget> buildSentenceWidgets() {
      String raw = state.exercise.sentence
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();

      // Map position number → blank index (blanks ordered by appearance in text)
      final Map<int, int> positionToBlankIndex = {};
      for (int i = 0; i < state.exercise.blanks.length; i++) {
        positionToBlankIndex[state.exercise.blanks[i].position] = i;
      }

      final regExp = RegExp(r'\[(\d+)\]');
      final matches = regExp.allMatches(raw).toList();

      List<Widget> widgets = [];
      int lastEnd = 0;
      int visualOrder = 0;

      for (final match in matches) {
        // Text before this blank
        final textBefore = raw.substring(lastEnd, match.start).trim();
        if (textBefore.isNotEmpty) {
          // Split by spaces to allow word-level wrapping in RTL
          for (final word in textBefore.split(' ')) {
            if (word.isNotEmpty) {
              widgets.add(Text(
                '$word ',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  fontSize: MediaQuery.sizeOf(context).width > 800 ? 17.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SomarSans',
                  height: 2.0,
                ),
              ));
            }
          }
        }

        // Blank widget
        final markerNum = int.tryParse(match.group(1) ?? '') ?? (visualOrder + 1);
        final blankIndex = positionToBlankIndex[markerNum] ?? visualOrder;
        visualOrder++;
        final label = visualOrder;

        final isFilled = state.isAnswered(blankIndex);
        final answer = isFilled ? state.getBlankAnswer(blankIndex) : "";
        final isSelected = state.selectedBlankIndex == blankIndex;
        final isChecked = state.isChecked;
        final isCorrectAnswer = isChecked && state.isCorrectWord(blankIndex);
        final isWrongAnswer = isChecked && isFilled && !state.isCorrectWord(blankIndex);

        // Color scheme based on state
        final Color correctColor = const Color(0xFF10B981);
        final Color wrongColor = const Color(0xFFEF4444);
        final LinearGradient? fillGradient = isChecked
            ? null // use solid color instead when checked
            : (isFilled ? AppColors.primaryGradient : null);
        final Color? fillColor = isChecked && isFilled
            ? (isCorrectAnswer ? correctColor : wrongColor)
            : (isFilled ? null : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)));
        final Color borderColor = isChecked && isFilled
            ? Colors.transparent
            : (isFilled
                ? Colors.transparent
                : (isSelected
                    ? AppColors.primaryColor
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))));
        final List<BoxShadow> shadows = isChecked && isFilled
            ? [BoxShadow(
                color: (isCorrectAnswer ? correctColor : wrongColor).withOpacity(0.4),
                blurRadius: 14, offset: const Offset(0, 5))]
            : (isFilled
                ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]);

        widgets.add(GestureDetector(
          // Disable tap after checking
          onTap: isChecked
              ? null
              : (isFilled
                  ? () => ref.read(fillInTheBlankProvider(exercise).notifier).unselectWord(blankIndex)
                  : () => ref.read(fillInTheBlankProvider(exercise).notifier).setSelectedIndex(blankIndex)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width > 800 ? 14.w : 10.w,
              vertical: 6.h,
            ),
            alignment: Alignment.center,
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width > 800 ? 80.w : 60.w,
              maxWidth: MediaQuery.sizeOf(context).width > 800 ? 220.w : 170.w,
              minHeight: MediaQuery.sizeOf(context).width > 800 ? 42.h : 36.h,
            ),
            decoration: BoxDecoration(
              gradient: fillGradient,
              color: fillColor,
              borderRadius: BorderRadius.circular(99.r),
              border: Border.all(color: borderColor, width: isSelected ? 3.w : 2.w),
              boxShadow: shadows,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isChecked && isFilled) ...[
                  Icon(
                    isCorrectAnswer ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: MediaQuery.sizeOf(context).width > 800 ? 16.sp : 14.sp,
                  ),
                  SizedBox(width: 4.w),
                ],
                isFilled
                  ? Text(
                      answer,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.sizeOf(context).width > 800 ? 16.sp : 14.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                      ),
                    )
                  : Text(
                      "$label",
                      style: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontSize: MediaQuery.sizeOf(context).width > 800 ? 16.sp : 14.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                      ),
                    ),
              ],
            ),
          ).animate().scale(delay: (label * 100).ms, duration: 400.ms, curve: Curves.easeOutBack),
        ));

        lastEnd = match.end;

      }

      // Remaining text after last blank
      final remaining = raw.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        for (final word in remaining.split(' ')) {
          if (word.isNotEmpty) {
            widgets.add(Text(
              '$word ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                fontSize: MediaQuery.sizeOf(context).width > 800 ? 17.sp : 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'SomarSans',
                height: 2.0,
              ),
            ));
          }
        }
      }

      return widgets;
    }

    return ExerciseTemplate(
      questionType: exercise.question,
      remark: exercise.remark,
      imageUrl: exercise.image,
      remarkImage: exercise.hintImage,
      useSpacerAfterQuestion: false,
      questionWidget: Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.start,
          spacing: 0,
          runSpacing: 4.h,
          children: buildSentenceWidgets(),
        ),
      ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),
      choices: [
        32.verticalSpace,
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: MediaQuery.sizeOf(context).width > 800 ? 12.w : 8.w,
            runSpacing: MediaQuery.sizeOf(context).width > 800 ? 12.h : 8.h,
            children: state.exercise.suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            final isSelected = state.isWordSelected(index);

            return GestureDetector(
              onTap: isSelected 
                  ? null 
                  : () => ref.read(fillInTheBlankProvider(exercise).notifier).selectWord(index),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 0.3 : 1.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width > 800 ? 20.w : 14.w,
                    vertical: MediaQuery.sizeOf(context).width > 800 ? 10.h : 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: LatextTextWidget(
                    text: word,
                    isLatex: true, // Suggestions often have formulas
                    textStyle: TextStyle(
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      fontSize: MediaQuery.sizeOf(context).width > 800 ? 15.sp : 13.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SomarSans',
                    ),
                  ),
                ),
              ),
            );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
      onButtonPressed: state.canSubmit
          ? () => ref.read(fillInTheBlankProvider(exercise).notifier).checkAnswer(context)
          : null,
      buttonText: "تحقق",
    );
  }
}
