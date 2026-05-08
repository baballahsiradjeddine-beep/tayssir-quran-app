import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/features/auth/presentation/login/custom_text_form_field.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/features/exercice/presentation/view/select_right_option/latext_text_widget.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class ResultBottomSheet extends ConsumerWidget {
  const ResultBottomSheet({
    super.key,
    required this.isCorrect,
    required this.onNext,
    this.message,
    this.onPopScope,
    this.isLatex = false,
  });

  final bool isCorrect;
  final VoidCallback onNext;
  final String? message;
  final VoidCallback? onPopScope;
  final bool isLatex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVideo = ref.watch(exercicesProvider).currentExercise.explanationVideo != null;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFF43F5E);

    // The modal sheet is already constrained by BottomSheetService to the content area.
    // This widget just needs to fill 100% of the available width.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, isDark ? 28.h : 40.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header Row (RTL)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Container(
                        width: 36.sp,
                        height: 36.sp,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      16.horizontalSpace,
                      Expanded(
                        child: Text(
                          isCorrect ? 'صحيح ! أحسنت' : 'أوبس! إجابة خاطئة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasVideo)
                            IconButton(
                              onPressed: () {
                                context.pop();
                                ref.read(exercicesProvider.notifier).showVideo();
                              },
                              icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (hasVideo) 12.horizontalSpace,
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const ReportExoDialog(),
                              );
                            },
                            icon: const Icon(Icons.report_gmailerrorred_rounded, color: Colors.white70, size: 24),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (message != null) ...[
                  16.verticalSpace,
                  Directionality(
                    textDirection: Directionality.of(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                              8.horizontalSpace,
                              Text(
                                "الإجابة الصحيحة",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SomarSans',
                                ),
                              ),
                            ],
                          ),
                          10.verticalSpace,
                          LatextTextWidget(
                            text: message!,
                            isLatex: isLatex,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SomarSans',
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                24.verticalSpace,

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportExoDialog extends HookConsumerWidget {
  const ReportExoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(24.r),
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon with pulse
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.report_gmailerrorred_rounded,
                  size: 44,
                  color: Color(0xFFF43F5E),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut),
              
              20.verticalSpace,

              Text(
                'الإبلاغ عن التمرين',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'SomarSans',
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              
              8.verticalSpace,

              Text(
                'يرجى وصف المشكلة التي واجهتك في هذا التمرين بدقة لمساعدتنا على تحسينه.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontFamily: 'SomarSans',
                  height: 1.4,
                ),
              ),

              24.verticalSpace,

              CustomTextFormField(
                controller: messageController,
                hintText: 'وصف المشكلة...',
                labelText: 'المشكلة',
                isMultiLine: true,
              ),

              24.verticalSpace,

              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SomarSans',
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  
                  12.horizontalSpace,

                  // Submit Button
                  Expanded(
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (messageController.text.trim().isNotEmpty) {
                            context.pop();
                            ref.read(exercicesProvider.notifier).reportCurrentExercise(
                                  reason: messageController.text.trim(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'إرسال البلاغ',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
