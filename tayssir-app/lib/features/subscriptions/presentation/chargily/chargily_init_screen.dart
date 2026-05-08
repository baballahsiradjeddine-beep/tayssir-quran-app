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
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class ChargilyInitScreen extends HookConsumerWidget {
  const ChargilyInitScreen({super.key, required this.subscription, this.charityCampaignId});
  final SubscriptionModel subscription;
  final int? charityCampaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotorCodeController = useTextEditingController();
    final result = useState<bool?>(null);
    final controller = ref.watch(chargilyControllerProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(chargilyControllerProvider.select((v) => v.status), (prv, nxt) {
      nxt.handleSideThings(context, () {}, shouldShowError: true);
    });

    ref.listen(chargilyControllerProvider.select((v) => v.url), (prv, nxt) async {
      if (nxt != null) {
        final res = await context.pushNamed(AppRoutes.chargilyWebView.name, extra: {'checkoutUrl': nxt});
        result.value = res as bool?;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (result.value == true) {
            ref.read(userNotifierProvider.notifier).updateUserSub(subscription);
            await ref.read(dataProvider.notifier).refreshData();
            if (subscription.id == 999) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => DialogContent(
                  title: "جزاك الله خيراً! 💚",
                  subTitle: "تم استلام تبرعك بنجاح. لقد تمت إضافته لرصيد الحملة الجارية.",
                  buttonText: "العودة للرئيسية",
                  onPressed: () {
                    context.goNamed(AppRoutes.home.name);
                  },
                ),
              );
            } else {
              DialogService.showSubscriptionDoneDialog(context, () async {
                context.goNamed(AppRoutes.home.name);
              });
            }
          } else {
            DialogService.showSubscriptionDialog(context, () {}, SubscrptionStatus.failure);
          }
        });
      }
    });

    return BayanBackground(
      child: AppScaffold(
        paddingY: 0,
        paddingX: 0,
        includeBackButton: false,
        topSafeArea: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final isDesktop = availableWidth > 800;
            final double horizontalPadding = isDesktop ? (availableWidth - 600) / 2 : 24.w;

            return Column(
              children: [
                // Premium Header
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 12.h, horizontalPadding, 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'الدفع الإلكتروني (ذهبية / CIB)',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textBlack,
                            fontFamily: 'SomarSans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildBackButton(context, isDark),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          24.verticalSpace,
                          
                          // Amount Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                              gradient: LinearGradient(
                                colors: isDark 
                                  ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
                                  : [Colors.black.withOpacity(0.02), Colors.black.withOpacity(0.01)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  subscription.id == 999 ? "مبلغ التبرع المستحق :" : "قيمة الاشتراك :",
                                  style: TextStyle(color: (isDark ? Colors.white : AppColors.textBlack).withOpacity(0.5), fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'SomarSans'),
                                ),
                                8.verticalSpace,
                                Text(
                                  "${subscription.price} دج",
                                  style: TextStyle(color: const Color(0xFF10B981), fontSize: 32.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
                                ),
                              ],
                            ),
                          ),
                          
                          24.verticalSpace,
                          
                          Text(
                            'سيتم توجيهك الآن إلى منصة الدفع الآمنة (Chargily) لإتمام عملية التفعيل الفوري.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: (isDark ? Colors.white : AppColors.textBlack).withOpacity(0.6),
                              fontFamily: 'SomarSans',
                              height: 1.6,
                            ),
                          ),
                          
                          if (subscription.id != 999) ...[
                            32.verticalSpace,
                            Container(
                              padding: EdgeInsets.all(24.r),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.card_giftcard_rounded, size: 22.sp, color: const Color(0xFF10B981)),
                                      12.horizontalSpace,
                                      Text(
                                        'كود المروج (اختياري)',
                                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textBlack, fontFamily: 'SomarSans'),
                                      ),
                                    ],
                                  ),
                                  16.verticalSpace,
                                  TextFormField(
                                    controller: promotorCodeController,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textBlack),
                                    decoration: InputDecoration(
                                      hintText: 'أدخل كود المروج إن وجد',
                                      hintStyle: TextStyle(color: (isDark ? Colors.white : AppColors.textBlack).withOpacity(0.2), fontSize: 13.sp),
                                      filled: true,
                                      fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          40.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 16.h, horizontalPadding, 32.h),
                  child: BigButton(
                    text: "تأكيد والانتقال للدفع",
                    onPressed: controller.status.isLoading
                        ? null
                        : () => ref.read(chargilyControllerProvider.notifier).initChargilyPayment(
                              subscription.id,
                              promotorCodeController.text.isEmpty ? null : promotorCodeController.text,
                              amount: subscription.id == 999 ? subscription.price.toDouble() : null,
                              charityCampaignId: charityCampaignId,
                            ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40.sp,
        height: 40.sp,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white : AppColors.textBlack, size: 16.sp),
      ),
    );
  }
}
