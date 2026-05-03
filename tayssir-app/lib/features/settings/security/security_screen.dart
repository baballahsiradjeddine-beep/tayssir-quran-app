import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/common/tayssir_icon.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/strings.dart';

enum ChangeType {
  phone,
  email,
  password,
}

class TayssirSecurityOption {
  final String title;
  final String iconUrl;
  final ChangeType changeType;
  TayssirSecurityOption({
    required this.title,
    required this.iconUrl,
    required this.changeType,
  });
}

final securityOptionProvider = Provider<List<TayssirSecurityOption>>((ref) {
  return [
    TayssirSecurityOption(
      title: AppStrings.changeEmail,
      iconUrl: SVGs.icPhilo,
      changeType: ChangeType.email,
    ),
    TayssirSecurityOption(
      title: AppStrings.changePassword,
      iconUrl: SVGs.icBox,
      changeType: ChangeType.password,
    ),
  ];
});

class SecurityScreen extends HookConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final options = ref.watch(securityOptionProvider);

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: false,
      paddingX: 0,
      paddingB: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. Header (Standard RTL alignment: Title Right, Back Left)
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${AppStrings.security} 🔐',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textBlack,
                              fontFamily: 'SomarSans',
                            ),
                          ),
                        ],
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
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

              // 2. Security Options Grid (Desktop) or List (Mobile)
              if (isDesktop)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 6.5, // Matched with SettingsScreen
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return SecurityOptionWidget(option: options[index])
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .slideX(begin: 0.05, end: 0);
                      },
                      childCount: options.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      options.map((option) => SecurityOptionWidget(option: option)
                        .animate()
                        .fadeIn(delay: (options.indexOf(option) * 100).ms)
                        .slideX(begin: 0.05, end: 0)
                      ).toList(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class SecurityOptionWidget extends StatelessWidget {
  final TayssirSecurityOption option;
  const SecurityOptionWidget({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (option.changeType == ChangeType.password) {
          context.pushNamed(AppRoutes.resetPassword.name);
        } else {
          context.pushNamed(AppRoutes.changeEmail.name);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TayssirIcon(
                icon: option.iconUrl,
                size: 24.sp,
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Text(
                option.title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontFamily: 'SomarSans',
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
