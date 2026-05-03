import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/bayan_bubble_talk_widget.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/subscriptions/domaine/payement_model.dart';
import 'package:tayssir/features/subscriptions/presentation/widgets/premium_subscription_banner.dart';
import 'package:tayssir/providers/user/subscription_model.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/utils/enums/triangle_side.dart';
import '../../auth/presentation/register/widgets/option_selection.dart';
import 'state/subscription_controller.dart';

class SubscriptionsScreen extends HookConsumerWidget {
  const SubscriptionsScreen({super.key, required this.subscription});

  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsMethodes = ref.watch(paymentsMethodesProvider);
    final selectedPaymentMethod = useState<PayementModel>(paymentsMethodes.first);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      paddingX: 0,
      paddingY: 0,
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
                    Text(
                      'الدفع والتفعيل ✅',
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
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
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
                             .moveY(begin: 0, end: -6, duration: 4.seconds, curve: Curves.easeInOutSine)
                             .rotate(begin: -0.02, end: 0.01, duration: 4.seconds, curve: Curves.easeInOutSine),
                            
                            8.horizontalSpace,
                            
                            SizedBox(
                              width: isDesktop ? 300.w : 170.w,
                              child: const BayanBubbleTalkWidget(
                                text: "لماذا تضيع وقتك؟ ثبت حفظك الآن مع ميزات متقدمة! 📖✨",
                                triangleSide: TriangleSide.right,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                        
                        30.verticalSpace,
                        
                        // Hero Banner
                        PremiumSubscriptionBanner(
                          price: subscription.realPrice,
                          description: subscription.description,
                        ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),
                        
                        24.verticalSpace,
                        
                        // Payment Title
                        Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            12.horizontalSpace,
                            Text(
                              "اختر وسيلة الدفع :",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                fontFamily: 'SomarSans',
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                        
                        20.verticalSpace,
                        
                        // Payment Methods List
                        ...paymentsMethodes.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final method = entry.value;
                            final isSelected = selectedPaymentMethod.value == method;

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: OptionSelection(
                                iconPath: method.icon,
                                text: method.value,
                                subText: _getSubTextForMethod(method.value),
                                onPressed: () => selectedPaymentMethod.value = method,
                                isSelected: isSelected,
                                accentColor: method.value.contains('إلكتروني') ? const Color(0xFFF59E0B) : null,
                              ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.05, end: 0),
                            );
                          },
                        ),
                        
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
                  text: AppStrings.continueText,
                  onPressed: () {
                    context.pushNamed(selectedPaymentMethod.value.path, extra: {
                      'subscription': subscription,
                    });
                  },
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

  String _getSubTextForMethod(String methodName) {
    if (methodName.contains('إلكتروني')) return 'البطاقة الذهبية / CIB (تفعيل فوري)';
    if (methodName.contains('تحويل')) return 'BaridiMob أو عبر مكاتب CCP';
    if (methodName.contains('بطاقة')) return 'عبر إدخال كود البطاقة';
    if (methodName.contains('استلام')) return 'توصيل البطاقة للمنزل أو المكتب';
    return '';
  }
}
