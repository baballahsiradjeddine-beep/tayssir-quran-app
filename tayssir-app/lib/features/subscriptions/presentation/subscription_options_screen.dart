// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tayssir/features/subscriptions/data/subscription_repository.dart';
import 'package:tayssir/features/subscriptions/presentation/widgets/subscription_option.dart';
import 'package:tayssir/providers/user/subscription_model.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/core/app_scaffold.dart';

import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/bayan_advice_widget.dart';
import 'package:tayssir/constants/strings.dart';

final subscriptionOptionsProvider =
    FutureProvider<List<SubscriptionModel>>((ref) async {
  // Keep the data in memory after the first fetch to make transitions instant
  ref.keepAlive();
  
  final data =
      await ref.watch(subscriptionRepositoryProvider).getSubscriptions();

  return data;
});

class SubscriptionOptionsScreen extends HookConsumerWidget {
  const SubscriptionOptionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionOptionsAsync = ref.watch(subscriptionOptionsProvider);
    final selectedSubOption = useState<SubscriptionModel?>(null);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      paddingX: 0,
      paddingY: 0,
      body: subscriptionOptionsAsync.when(
        data: (subscriptionOptions) {
          final filteredOptions = subscriptionOptions.where((sub) => sub.id != 999).toList();
          
          if (selectedSubOption.value == null && filteredOptions.isNotEmpty) {
            selectedSubOption.value = filteredOptions.first;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final isDesktop = availableWidth > 800;
              const double targetContentWidth = 1050;

              final double horizontalPadding = isDesktop 
                  ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
                  : 20.w;

              return Column(
                children: [
                   // Custom Managed AppBar
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 12.h, horizontalPadding, 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اختر اشتراكك 💎',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textBlack,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                        _buildBackButton(context, isDark),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            20.verticalSpace,
                            const BayanAdviceWidget(
                              text: AppStrings.dearStudentChooseSubscription,
                            ),
                            20.verticalSpace,
                            ...filteredOptions.map((sub) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: SubscriptionOptionWidget(
                                totalPrice: sub.price,
                                discountedPrice: sub.discounts.isNotEmpty ? sub.realPrice : null,
                                percentageDiscount: sub.discounts.isNotEmpty ? sub.percentage : null,
                                descriptionText: sub.description,
                                gradientColors: sub.gradientColors.isEmpty 
                                  ? [const Color(0XFF175DC7), const Color(0XFF00C4F6)] 
                                  : sub.gradientColors,
                                innerColor: sub.innterColor ?? const Color(0XFF175DC7),
                                onPressed: () => selectedSubOption.value = sub,
                                isSelected: selectedSubOption.value == sub,
                              ),
                            )),
                            40.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.h, 
                      top: 10.h,
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    child: BigButton(
                      text: AppStrings.continueText,
                      onPressed: selectedSubOption.value != null
                          ? () {
                              context.pushNamed(AppRoutes.subscriptions.name,
                                  extra: {'subscription': selectedSubOption.value});
                            }
                          : null,
                    ),
                  ),
                ],
              );
            }
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              16.verticalSpace,
              Text('Error loading subscriptions: $error'),
              16.verticalSpace,
              ElevatedButton(
                onPressed: () => ref.refresh(subscriptionOptionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return IconButton(
      onPressed: () => context.pop(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        width: 44.sp,
        height: 44.sp,
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
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          size: 18.sp,
        ),
      ),
    );
  }
}
