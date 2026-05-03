import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/bayan_advice_widget.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/auth/presentation/common/header_text.dart';
import 'package:tayssir/features/auth/presentation/login/custom_text_form_field.dart';
import 'package:tayssir/features/settings/security/change_email/change_email_controller.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/utils/extensions/async_value.dart';
import 'package:tayssir/utils/validators.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class EnterEmailView extends HookConsumerWidget {
  const EnterEmailView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(changeEmailControllerProvider);
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final canSubmit = useState(false);

    useEffect(() {
        listener() => canSubmit.value = emailController.text.isNotEmpty;
        emailController.addListener(listener);
        return () => emailController.removeListener(listener);
    }, [emailController]);

    ref.listen(changeEmailControllerProvider.select((val) => val.status),
        (prv, curr) {
      if (curr is AsyncError) {
        curr.handleSideThings(context, () {});
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
            const double targetContentWidth = 1050;

            final double horizontalPadding = isDesktop 
                ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
                : 20.w;

            return Form(
              key: formKey,
              onChanged: () => canSubmit.value = emailController.text.isNotEmpty,
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
                            AppStrings.changeEmail,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              10.verticalSpace,
                              const BayanAdviceWidget(
                                text: AppStrings.enterCredentials,
                                isHorizontal: false,
                              ).animate().fadeIn(delay: 100.ms),
                              24.verticalSpace,
                              CustomTextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.validateEmail,
                                  labelText: AppStrings.email,
                                  prefix: const Icon(Icons.email)
                              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),
                              20.verticalSpace,
                              Text(
                                AppStrings.forgetPasswordAdvice,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? Colors.white60 : AppColors.darkColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SomarSans',
                                )
                              ).animate().fadeIn(delay: 300.ms),
                              60.verticalSpace,
                              BigButton(
                                text: AppStrings.continueText,
                                onPressed: (!canSubmit.value || controller.isLoading)
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          ref
                                              .read(changeEmailControllerProvider.notifier)
                                              .onEmailEntered(emailController.text);
                                        }
                                      },
                              ).animate().fadeIn(delay: 400.ms),
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
        )
    );
  }
}
