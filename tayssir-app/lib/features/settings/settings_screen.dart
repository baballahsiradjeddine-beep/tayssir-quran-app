import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:tayssir/common/app_buttons/logout_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/constants/app_consts.dart';
import 'package:tayssir/features/settings/widgets/custom_switch_button.dart';
import 'package:tayssir/features/settings/widgets/settings_item.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/actions/snack_bar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/strings.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> requestReview() async {
    const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.tayssir.bac&hl=fr';
    final InAppReview inAppReview = InAppReview.instance;

    try {
      if (await inAppReview.isAvailable()) {
          inAppReview.openStoreListing();
      } else {
          _launchUrl(playStoreUrl, context);
      }
    } catch (e) {
      _launchUrl(playStoreUrl, context);
    }
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      SnackBarService.showErrorToast(
        'تعذر فتح الرابط المطلوب.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      extendBody: true,
      bodyBackgroundColor: Colors.transparent,
      paddingB: 0,
      paddingX: 0,
      paddingY: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          // Standardized centering and alignment logic
          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          final List<Widget> mainSettings = [
            SettingsItem(
              iconData: Icons.person_outline_rounded,
              title: AppStrings.personalInformations,
              onTap: () => context.pushNamed(AppRoutes.profile.name),
            ),
            SettingsItem(
              iconData: Icons.notifications_none_rounded,
              title: AppStrings.notifications,
              actionWidget: const SizedBox.shrink(),
              onTap: () => context.pushNamed(AppRoutes.notifcations.name),
            ),
            SettingsItem(
              iconData: Icons.security_outlined,
              title: AppStrings.security,
              onTap: () => context.pushNamed(AppRoutes.security.name),
            ),
            const SettingsItem(
              iconData: Icons.volume_up_outlined,
              title: 'أصوات التطبيق والاهتزاز',
              actionWidget: AudioSoundSwitchButton(),
            ),
          ];

          final List<Widget> appSettings = [
            SettingsItem(
              iconData: Icons.star_outline_rounded,
              title: 'قيّم تطبيق بيان القرآن على المتجر',
              onTap: requestReview,
            ),
            SettingsItem(
              iconData: Icons.share_outlined,
              title: 'شارك التطبيق مع أصدقائك',
              onTap: () {
                  Share.share('حمل تطبيق بيان القرآن وابدأ رحلتك المباركة في حفظ القرآن الكريم وتثبيته! 🌿✨\nhttps://play.google.com/store/apps/details?id=com.bayan.quran');
              },
            ),
            SettingsItem(
              iconData: Icons.alternate_email_rounded,
              title: 'تواصل معنا (اتصل بنا)',
              onTap: () => context.pushNamed(AppRoutes.contactUs.name),
            ),
            SettingsItem(
              iconData: Icons.privacy_tip_outlined,
              title: AppStrings.privacyPolicy,
              onTap: () => _launchUrl(AppConsts.privacyUrl, context),
            ),
          ];

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.settings,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textBlack,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                      8.horizontalSpace,
                      const Icon(Icons.settings_outlined, color: AppColors.primaryColor),
                    ],
                  ),
                ),
              ),

              // Main Settings Group
              if (isDesktop)
                SliverPadding(
                   padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                   sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 16,
                      childAspectRatio: 6.5,
                    ),
                    delegate: SliverChildListDelegate(mainSettings),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(mainSettings),
                  ),
                ),

              SliverToBoxAdapter(child: 24.verticalSpace),

              // App Settings Group
              if (isDesktop)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 16,
                      childAspectRatio: 6.5,
                    ),
                    delegate: SliverChildListDelegate(appSettings),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(appSettings),
                  ),
                ),

              // Re-added About Us Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30.h),
                  child: _AboutUsCard(isDark: isDark),
                ),
              ),

              // Logout & Version
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, bottom: 40.h),
                  child: Column(
                    children: [
                      const LogoutButton(),
                      20.verticalSpace,
                      Text(
                        'الإصدار ${AppConsts.appVersion}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }
}

class _AboutUsCard extends StatelessWidget {
  final bool isDark;

  const _AboutUsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 32.sp)
              .animate(onPlay: (c) => c.repeat())
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2), duration: 1.seconds, curve: Curves.easeInOutSine)
              .then()
              .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 1.seconds),
          16.verticalSpace,
          Text(
            'نحن فريق يسعى لخدمة كتاب الله',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontFamily: 'SomarSans',
            ),
          ),
          8.verticalSpace,
          Text(
            'لأي مشكلة أو استفسار، يرجى التواصل معنا. هذا سيساعدنا كثيراً في تطوير المشروع، وشكراً لدعمكم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white60 : Colors.black54,
              fontFamily: 'SomarSans',
              height: 1.5,
            ),
          ),
          24.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(icon: Icons.play_circle_fill_rounded, color: Colors.red, url: AppConsts.youtubeLink),
              20.horizontalSpace,
              _SocialIcon(icon: Icons.camera_alt_rounded, color: AppColors.emerald600, url: AppConsts.instagramLink),
              20.horizontalSpace,
              _SocialIcon(icon: Icons.telegram_rounded, color: const Color(0xFF0EA5E9), url: AppConsts.telegramLink),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String url;

  const _SocialIcon({required this.icon, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
      return GestureDetector(
          onTap: () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
          },
          child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
          ),
      );
  }
}
