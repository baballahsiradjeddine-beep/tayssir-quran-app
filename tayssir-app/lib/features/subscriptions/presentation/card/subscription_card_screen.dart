import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/bayan_bubble_talk_widget.dart';
import 'package:tayssir/features/subscriptions/presentation/card/subscribe_card_button.dart';
import 'package:tayssir/features/subscriptions/presentation/state/subscription_controller.dart';
import 'package:tayssir/providers/user/subscription_model.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/utils/enums/triangle_side.dart';
import 'package:tayssir/utils/extensions/async_value.dart';

import '../../../../common/app_buttons/big_button.dart';
import '../../../../common/core/app_scaffold.dart';
import '../../../../constants/strings.dart';
import '../../../../exceptions/app_exception.dart';
import '../../../../router/app_router.dart';

class SubscriptionCardScreen extends HookConsumerWidget {
  const SubscriptionCardScreen({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardNumberController = useTextEditingController();
    final isValid = useState<bool>(false);
    final state = ref.watch(subscriptionControllerProvider);
    final shouldShowError = state.state is AsyncError;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    cardNumberController.addListener(() {
      if (cardNumberController.text.length == 12) {
        isValid.value = true;
      } else {
        isValid.value = false;
      }
    });

    ref.listen(subscriptionControllerProvider.select((v) => v.state), (prv, nxt) {
      nxt.handleSideThings(context, () {
        DialogService.showSubscriptionDoneDialog(context, () {
          context.goNamed(AppRoutes.home.name);
        });
      }, shouldShowError: false);
    });

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      paddingX: 0,
      paddingY: 0,
      bodyBackgroundColor: isDark ? const Color(0xFF0B1120) : null,
      body: LayoutBuilder(
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
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'SomarSans',
                        ),
                        children: [
                          TextSpan(
                            text: "بيان ",
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                          ),
                          const TextSpan(
                            text: "القرآن",
                            style: TextStyle(color: Color(0xFF10B981)),
                          ),
                        ],
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
                        // Dolphin & Speech Bubble
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "📖",
                              style: TextStyle(fontSize: 70.sp),
                            ).animate(onPlay: (c) => c.repeat(reverse: true))
                             .moveY(begin: 0, end: -6, duration: 4.seconds, curve: Curves.easeInOutSine),
                            
                            8.horizontalSpace,
                            
                            SizedBox(
                              width: isDesktop ? 300.w : 170.w,
                              child: BayanBubbleTalkWidget(
                                text: "أحسنت الإختيار! بيان القرآن رفيقك نحو الحفظ 😉",
                                triangleSide: isDesktop ? TriangleSide.right : TriangleSide.right,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 100.ms),
                        
                        30.verticalSpace,
                        
                        // Virtual Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40.w : 10.w),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 500 : double.infinity),
                            child: SubscribeCardButton(
                              controller: cardNumberController,
                              hasError: shouldShowError,
                              price: subscription.realPrice,
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),
                        
                        24.verticalSpace,
                        
                        // Error message
                        if (shouldShowError)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Text(
                              (state.state.asError!.error as AppException).message.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                          ).animate().fadeIn().shake(),
                        
                        40.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed Bottom Action
              Padding(
                padding: EdgeInsets.only(
                  bottom: 32.h, 
                  top: 16.h,
                  left: horizontalPadding,
                  right: horizontalPadding,
                ),
                child: BigButton(
                  text: AppStrings.check,
                  onPressed: isValid.value && !state.state.isLoading
                      ? () => ref.read(subscriptionControllerProvider.notifier).subscribeWithCard(cardNumberController.text, subscription)
                      : null,
                ).animate().fadeIn(delay: 700.ms).scale(curve: Curves.easeOutBack),
              ),
            ],
          );
        }
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
