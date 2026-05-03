import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/features/exercice/presentation/view/question_type_widget.dart';
import 'package:tayssir/features/exercice/presentation/view/select_right_option/use_remark_dialog.dart';
import 'package:tayssir/providers/data/models/latex_field.dart';
import 'question_section.dart';

class ExerciseTemplate extends HookConsumerWidget {
  const ExerciseTemplate({
    super.key,
    required this.choices,
    required this.questionType,
    this.questionWidget,
    this.remark,
    this.buttonText = "تحقق من الإجابة",
    this.onButtonPressed,
    this.imageUrl,
    this.useSpacerAfterQuestion = true,
    this.useSpacerBeforeButton = true,
    this.remarkImage,
    this.useGridOnDesktop = false,
  });

  final List<Widget> choices;
  final String questionType;
  final Widget? questionWidget;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool useSpacerAfterQuestion;
  final bool useSpacerBeforeButton;
  final List<LatexField<String>>? remark;
  final String? imageUrl;
  final String? remarkImage;
  final bool useGridOnDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldDelay = ref.watch(exercicesProvider).currentExerciceIndex == 0;
    useRemarkDialog(context, remark, remarkImage, shouldDelay: shouldDelay);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double maxWidth = isDesktop ? 1150.0 : double.infinity;
        final double horizontalPadding = isDesktop ? 40.0 : 16.w;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scrollable Content (now includes question type and question)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      clipBehavior: Clip.none,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question Type inside scroll
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: isDesktop ? 40.h : 10.h,
                                bottom: isDesktop ? 40.h : 14.h,
                              ),
                              child: QuestionTypeWidget(question: questionType)
                                  .animate().fadeIn().slideY(begin: -0.1, end: 0),
                            ),
                          ),
                          
                          // Main Question Section
                          if (questionWidget != null)
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: isDesktop ? 1000.0 : double.infinity),
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: isDesktop ? 8.h : 4.h),
                                  child: QuestionSection(
                                    question: Column(
                                      children: [
                                        questionWidget!,
                                        if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                                          24.verticalSpace,
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(24.r),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight: 350.h,
                                              ),
                                              child: CustomCachedImage(
                                                imageUrl: imageUrl!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ).animate().fadeIn(delay: 200.ms),
                                ),
                              ),
                            ),
                          
                          // Answer Choices Section
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: isDesktop && useGridOnDesktop
                              ? Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 1000),
                                    child: Wrap(
                                        spacing: 24.w,
                                        runSpacing: 24.h,
                                        alignment: WrapAlignment.center,
                                        children: choices.map((c) => SizedBox(
                                          width: (constraints.maxWidth - horizontalPadding * 2 - 80.w) / 2,
                                          child: c,
                                        )).toList(),
                                      ),
                                  ),
                              )
                              : Column(
                                  children: choices.map((c) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isDesktop ? 8.h : 4.h,
                                      horizontal: isDesktop ? 12.w : 4.w,
                                    ),
                                    child: c,
                                  )).toList(),
                                ),
                          ).animate().fadeIn(delay: 400.ms),
                          
                          isDesktop ? 120.verticalSpace : 40.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                  
                  // Fixed Bottom Footer
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.h, top: 10.h),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 1000.0 : double.infinity),
                        child: BigButton(
                          text: buttonText,
                          onPressed: ref.watch(exercicesProvider).submittingStatus.isLoading
                              ? null
                              : onButtonPressed,
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
