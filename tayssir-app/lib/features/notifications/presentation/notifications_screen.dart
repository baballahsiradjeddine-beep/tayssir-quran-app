import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/notifications/domaine/notifiacation_model.dart';
import 'package:tayssir/features/notifications/presentation/notification_card.dart';
import 'package:tayssir/features/notifications/presentation/notifications_controller.dart';
import 'package:tayssir/features/notifications/presentation/paginated_list_view.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      paddingX: 0,
      paddingB: 0,
      topSafeArea: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          // Standardized centering and alignment logic
          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsControllerProvider),
            color: AppColors.primaryColor,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 1. Standardized Header
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تنبيهات بيان القرآن',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textBlack,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            8.horizontalSpace,
                            const Icon(Icons.notifications_active_outlined, color: AppColors.primaryColor),
                          ],
                        ),
                        const Spacer(),
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

                // 2. Notifications List or Empty State
                controller.notifications.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(30.r),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_off_outlined,
                                  size: 80.sp,
                                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                                ),
                              ),
                              24.verticalSpace,
                              Text(
                                'لا توجد تنبيهات حالياً',
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.textBlack,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'SomarSans',
                                ),
                              ),
                              8.verticalSpace,
                              Text(
                                'سنقوم بتنبيهك بكل ما هو جديد ومبارك في رحلة حفظك!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white38 : AppColors.textBlack.withOpacity(0.5),
                                  fontSize: 14.sp,
                                  fontFamily: 'SomarSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // To avoid double scrollbars, we use SliverList instead of SliverFillRemaining containing a ListView
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == data.length) {
                                if (controller.canLoadMore) {
                                    if (controller.isFetchingMore) {
                                        return const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 20),
                                            child: Center(child: CircularProgressIndicator()),
                                        );
                                    } else {
                                        // Trigger loading more
                                        Future.microtask(() => ref.read(notificationsControllerProvider.notifier).fetchMoreNotifications());
                                        return const SizedBox.shrink();
                                    }
                                }
                                return 120.verticalSpace; // Extra space at the end
                            }

                            final item = data[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: NotificationCard(
                                notification: item,
                              ).animate()
                               .fadeIn(delay: (index * 50).clamp(0, 500).ms, duration: 400.ms)
                               .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                            );
                          },
                          childCount: data.length + 1,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('حدث خطأ في جلب البيانات')),
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
