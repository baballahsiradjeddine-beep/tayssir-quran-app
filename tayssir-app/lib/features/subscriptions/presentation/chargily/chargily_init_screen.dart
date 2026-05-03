// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/sliver_scrolling_widget.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/subscriptions/presentation/chargily/chargily_controller.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/user/subscription_model.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/utils/extensions/async_value.dart';

class ChargilyInitScreen extends HookConsumerWidget {
  const ChargilyInitScreen({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotorCodeController = useTextEditingController();
    final result = useState<bool?>(null);
    final controller = ref.watch(chargilyControllerProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(chargilyControllerProvider.select((v) => v.status), (prv, nxt) {
      nxt.handleSideThings(context, () {}, shouldShowError: true);
    });

    ref.listen(chargilyControllerProvider.select((v) => v.url),
        (prv, nxt) async {
      if (nxt != null) {
        final res = await context.pushNamed(AppRoutes.chargilyWebView.name,
            extra: {'checkoutUrl': nxt});
        result.value = res as bool?;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (result.value == true) {
            ref.read(userNotifierProvider.notifier).updateUserSub(subscription);
            await ref.read(dataProvider.notifier).refreshData();
            DialogService.showSubscriptionDoneDialog(context, () async {
              context.goNamed(AppRoutes.home.name);
            });
          } else {
            DialogService.showSubscriptionDialog(context, () {
              // context.pop();
            }, SubscrptionStatus.failure);
          }
        });
      }
    });

    return AppScaffold(
      paddingY: 0,
      paddingX: 0,
      includeBackButton: false,
      topSafeArea: true,
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
                      'الدفع الإلكتروني (ذهبية / CIB)',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontFamily: 'SomarSans',
                      ),
                    ),
                    _buildBackButton(context, isDark),
                  ],
                ),
              ),

              Expanded(
                child: SliverScrollingWidget(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          20.verticalSpace,
                          Text(
                            'سيتم توجيهك الآن إلى منصة الدفع الآمنة (Chargily) لإتمام عملية التفعيل الفوري لاشتراكك.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontFamily: 'SomarSans',
                              height: 1.5,
                            ),
                          ),
                          30.verticalSpace,
                          
                          Container(
                            padding: EdgeInsets.all(24.r),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard_rounded,
                                      size: 24.sp,
                                      color: const Color(0xFF10B981),
                                    ),
                                    12.horizontalSpace,
                                    Text(
                                      'كود المروج (اختياري)',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        fontFamily: 'SomarSans',
                                      ),
                                    ),
                                  ],
                                ),
                                16.verticalSpace,
                                TextFormField(
                                  controller: promotorCodeController,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'أدخل كود المروج إن وجد',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14.sp,
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          40.verticalSpace,
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 32.h,
                  top: 16.h,
                ),
                child: BigButton(
                  text: "تأكيد والانتقال للدفع",
                  onPressed: controller.status.isLoading
                      ? null
                      : () {
                          ref
                              .read(chargilyControllerProvider.notifier)
                              .initChargilyPayment(
                                subscription.id,
                                promotorCodeController.text.isEmpty
                                    ? null
                                    : promotorCodeController.text,
                              );
                        },
                ),
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
