import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/auth/presentation/login/custom_text_form_field.dart';
import 'package:tayssir/features/settings/contact_us/contact_us_controller.dart';
import 'package:tayssir/features/settings/domaine/contact_us_model.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/services/actions/snack_bar_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ContactUsScreen extends HookConsumerWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final canSubmit = useState(false);
    final user = ref.watch(userNotifierProvider).valueOrNull;
    
    final emailController = useTextEditingController(text: user?.email ?? '');
    final fullNameController = useTextEditingController(text: user?.name ?? '');
    final messageController = useTextEditingController();

    // Side effects for submission success
    ref.listen(contactUsControllerProvider, (prv, next) {
      if (next.hasValue && !next.isLoading && prv?.isLoading == true) {
        SnackBarService.showSuccessToast('تم إرسال رسالتك بنجاح! شكراً لتواصلك معنا.');
        messageController.clear();
        canSubmit.value = false;
        if (context.canPop()) context.pop();
      }
    });

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppScaffold(
      paddingX: 0,
      paddingB: 0,
      topSafeArea: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050; // Use same width as others for horizontal consistency

          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return Form(
            key: formKey,
            onChanged: () => canSubmit.value =
                messageController.text.trim().isNotEmpty &&
                emailController.text.trim().isNotEmpty &&
                fullNameController.text.trim().isNotEmpty,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 1. Standardized Header (Title on Right, Back on Left)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding, 
                      right: horizontalPadding, 
                      top: isDesktop ? 30.h : 8.h, 
                      bottom: 16.h
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Title on the Right (Start in RTL)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تواصل معنا',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textBlack,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            8.horizontalSpace,
                            const Icon(Icons.phone_in_talk_outlined, color: AppColors.primaryColor),
                          ],
                        ),

                        const Spacer(),

                        // Back Button on the Left (End in RTL)
                        IconButton(
                            onPressed: () {
                              if (context.canPop()) context.pop();
                            },
                            icon: Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                size: 18.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                ),

                // 2. Form Content (Centered narrow column)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700), // Form looks better narrower
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            12.verticalSpace,
                            Text(
                              AppStrings.contactUsTitle,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                height: 1.5,
                                fontFamily: 'SomarSans',
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                            30.verticalSpace,
                            
                            CustomTextFormField(
                              prefix: CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: 14.r,
                                child: const Icon(Icons.person, color: Colors.white, size: 15),
                              ),
                              controller: fullNameController,
                              labelText: AppStrings.fullName,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),
                            
                            16.verticalSpace,
                            
                            CustomTextFormField(
                              prefix: CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                radius: 14.r,
                                child: const Icon(Icons.email, color: Colors.white, size: 15),
                              ),
                              controller: emailController,
                              labelText: AppStrings.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05, end: 0),
                            
                            16.verticalSpace,
                            
                            CustomTextFormField(
                              controller: messageController,
                              labelText: AppStrings.enterMessage,
                              isMultiLine: true,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05, end: 0),
                            
                            40.verticalSpace,
                            
                            BigButton(
                              text: AppStrings.submit,
                              onPressed: ref.watch(contactUsControllerProvider).isLoading
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        ref.read(contactUsControllerProvider.notifier)
                                           .sendContactUs(ContactUsModel(
                                              email: emailController.text,
                                              name: fullNameController.text,
                                              message: messageController.text));
                                      }
                                    },
                            ).animate().fadeIn(delay: 500.ms),
                            
                            120.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
