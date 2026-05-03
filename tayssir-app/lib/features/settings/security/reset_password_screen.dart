import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/bayan_advice_widget.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/services/actions/snack_bar_service.dart';
import 'package:tayssir/utils/extensions/async_value.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import '../../../../../utils/validators.dart';
import '../../auth/presentation/login/custom_text_form_field.dart';
import 'reset_password_controller.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(resetPasswordController);
    final oldPasswordController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final canSubmit = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    void checker() {
      canSubmit.value = oldPasswordController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
    }

    ref.listen(resetPasswordController, (prev, next) {
      next.handleSideThings(context, () {
        SnackBarService.showSuccessSnackBar(
            AppStrings.passwordChangedSuccessfully,
            context: context);
      });
    });

    return AppScaffold(
      paddingX: 0,
      paddingB: 0,
      topSafeArea: false,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return Form(
            key: formKey,
            onChanged: checker,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding, 
                      right: horizontalPadding, 
                      top: isDesktop ? 30.h : 8.h, 
                      bottom: 24.h
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.changingPassword,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textBlack,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
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

                // Content
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          children: [
                            10.verticalSpace,
                            const BayanAdviceWidget(
                              text: AppStrings.enterCredentials,
                              isHorizontal: false,
                            ).animate().fadeIn(delay: 100.ms).scale(curve: Curves.easeOutBack),
                            
                            40.verticalSpace,
                            
                            CustomTextFormField(
                              controller: oldPasswordController,
                              labelText: "كلمة السر الحالية",
                              isPassword: true,
                              prefix: const Icon(Icons.lock_outline_rounded),
                              validator: Validators.validatePassword,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
                            
                            20.verticalSpace,
                            
                            CustomTextFormField(
                              controller: passwordController,
                              labelText: "كلمة السر الجديدة",
                              isPassword: true,
                              prefix: const Icon(Icons.lock_reset_rounded),
                              validator: Validators.validatePassword,
                            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                            
                            20.verticalSpace,
                            
                            CustomTextFormField(
                              controller: confirmPasswordController,
                              labelText: AppStrings.confirmPassword,
                              isPassword: true,
                              prefix: const Icon(Icons.check_circle_outline_rounded),
                              validator: (value) => Validators.validateConfirmPassword(
                                  value, passwordController.text),
                            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                            
                            60.verticalSpace,
                            
                            BigButton(
                              text: "تغيير كلمة السر",
                              onPressed: canSubmit.value && !controller.isLoading
                                  ? () {
                                      if (formKey.currentState!.validate()) {
                                        ref
                                            .read(resetPasswordController.notifier)
                                            .resetPassword(oldPasswordController.text,
                                                passwordController.text);
                                      }
                                    }
                                  : null,
                            ).animate().fadeIn(delay: 600.ms).scale(),
                            
                            100.verticalSpace,
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
