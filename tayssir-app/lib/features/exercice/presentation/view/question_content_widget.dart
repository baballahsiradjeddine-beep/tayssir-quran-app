import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/features/exercice/presentation/view/execise_number_widget.dart';
import 'package:tayssir/features/exercice/presentation/view/select_right_option/latext_text_widget.dart';
import 'package:tayssir/providers/data/models/latex_field.dart';

import '../state/exercice_controller.dart';

class QuestionContentWidget extends HookConsumerWidget {
  const QuestionContentWidget({
    super.key,
    required this.question,
  });

  final LatexField question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: question.isLatex
          ? LatexContentWidget(question: question)
          : PlainTextContentWidget(question: question),
    );
  }
}

class LatexContentWidget extends ConsumerStatefulWidget {
  const LatexContentWidget({
    super.key,
    required this.question,
  });

  final LatexField question;

  @override
  ConsumerState<LatexContentWidget> createState() => _LatexContentWidgetState();
}

class _LatexContentWidgetState extends ConsumerState<LatexContentWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (kIsWeb) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.warmAccent.withOpacity(0.1) 
              : AppColors.warmAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark 
                ? AppColors.warmAccent.withOpacity(0.4) 
                : AppColors.warmAccent.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ExeciseNumberWidget(),
            12.verticalSpace,
            LatextTextWidget(
              text: widget.question.cleanText,
              isLatex: true,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                color: isDark ? AppColors.warmAccentLight : AppColors.warmAccent,
                fontSize: MediaQuery.sizeOf(context).width > 800 ? 22.sp : 20.sp,
                fontFamily: "SomarSans",
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ExeciseNumberWidget(),
        12.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: TeXView(
            child: TeXViewDocument(
              widget.question.cleanText,
              style: TeXViewStyle.fromCSS(
                isDark
                    ? 'padding: 8px; color: #F8FAFC; direction: rtl; background: transparent; width: 100%; text-align: center;'
                    : 'padding: 8px; color: #1E293B; direction: rtl; width: 100%; text-align: center;',
              ),
            ),
            style: TeXViewStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        )
      ],
    );
  }
}

class PlainTextContentWidget extends HookConsumerWidget {
  const PlainTextContentWidget({
    super.key,
    required this.question,
  });

  final LatexField question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.warmAccent.withOpacity(0.1) 
            : AppColors.warmAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark 
              ? AppColors.warmAccent.withOpacity(0.4) 
              : AppColors.warmAccent.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: RichText(
        textDirection:
            ref.watch(exercicesProvider).currentExercise.currentDirection,
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  right: 8.w,
                  bottom: 2.h,
                ),
                child: const ExeciseNumberWidget(),
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text: question.text.toString(),
              style: TextStyle(
                color: isDark ? AppColors.warmAccentLight : AppColors.warmAccent,
                fontSize: MediaQuery.sizeOf(context).width > 800 ? 22.sp : 20.sp,
                fontFamily: "SomarSans",
                fontWeight: FontWeight.w900,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
