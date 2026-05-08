import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/shield_badge.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/providers/divisions/division_model.dart';
import 'package:tayssir/providers/divisions/divisions.dart';
import 'package:tayssir/providers/geo/country.dart';
import 'package:tayssir/providers/geo/region.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../common/forms/drop_down/taysir_drop_down.dart';
import '../../constants/strings.dart';
import '../../providers/user/user_notifier.dart';
import '../../resources/colors/app_colors.dart';
import '../../resources/resources.dart';
import '../../services/geo/geo_service.dart';
import '../../services/image_picker/image_picker_service.dart';
import '../auth/presentation/login/custom_text_form_field.dart';
import '../../common/blur_overlay_widget.dart';
import '../../services/actions/snack_bar_service.dart';
import '../../common/push_buttons/rounded_pushable_button.dart';
import '../../services/user/update_user_request.dart';
import 'profile_controller.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      return const AppScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final nameController = useTextEditingController(text: user.name);
    final ageController = useTextEditingController(text: user.age.toString());
    final phoneController = useTextEditingController(text: (() {
      String phone = user.phoneNumber ?? '';
      if (user.country?.phoneCode != null) {
        String code = user.country!.phoneCode!.replaceAll('+', '');
        if (phone.startsWith('+$code')) {
          phone = phone.replaceFirst('+$code', '');
        } else if (phone.startsWith(code)) {
          phone = phone.replaceFirst(code, '');
        }
      }
      return phone;
    })());
    final countriesAsync = ref.watch(countriesProvider);
    final countries = countriesAsync.valueOrNull ?? [];
    
    final country = useState<Country?>(user.country ?? (countries.isNotEmpty ? countries.firstWhere((c) => c.code == 'DZ', orElse: () => countries.first) : null));
    
    final regions = country.value != null ? (ref.watch(regionsProvider(country.value!.id)).asData?.value ?? []) : <Region>[];
    final region = useState<Region?>(user.region);

    final division = useState<DivisionModel?>(user.division);
    final localImage = useState<File?>(null);
    final isShowOverlay = useState(false);

    final currentUserSubscription = user.subscriptions.isNotEmpty ? user.subscriptions.first : null;

    ref.listen<ProfileState>(profileControllerProvider, (prev, next) {
      if (next.isCompleted && (prev == null || !prev.isCompleted)) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          SnackBarService.showSuccessSnackBar('تم تحديث المعلومات بنجاح',
              context: context);
        });
      }
    });

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlurOverlayWidget(
      hasTopSafeArea: false,
      showOverlay: isShowOverlay.value,
      onPopScope: () {
        if (isShowOverlay.value) {
            isShowOverlay.value = false;
            localImage.value = null;
        }
      },
      overlayContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (localImage.value != null)
            PushableImageButton(
              image: FileImage(localImage.value!),
              size: 300,
              borderRadius: 50.r,
              topColor: isDark ? const Color(0xFF10B981) : AppColors.warmAccent,
              bottomColor: isDark ? const Color(0xFF059669) : AppColors.warmTitle,
              elevation: 20,
              borderWidth: 10,
              borderColor: isDark ? const Color(0xFF10B981) : AppColors.warmAccent,
              onPressed: () {
                isShowOverlay.value = false;
                localImage.value = null;
              },
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          30.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  isShowOverlay.value = false;
                  localImage.value = null;
                },
                icon: Icon(Icons.close_rounded, color: Colors.white, size: 40.sp),
              ),
              40.horizontalSpace,
              IconButton(
                onPressed: () {
                  // Save profile image immediately when confirmed
                  if (localImage.value != null) {
                    ref.read(profileControllerProvider.notifier).updateUser(
                      UpdateUserRequest(image: localImage.value),
                    );
                  }
                  isShowOverlay.value = false;
                },
                icon: Icon(Icons.check_rounded, color: isDark ? const Color(0xFF10B981) : AppColors.warmAccent, size: 44.sp),
              ),
            ],
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final bool isDesktop = availableWidth > 800;
            const double targetContentWidth = 1050;

            // Standardized centering and alignment logic
            final double horizontalPadding = isDesktop 
                ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
                : 20.w;

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(userNotifierProvider),
              color: isDark ? const Color(0xFF10B981) : AppColors.warmTitle,
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // 1. Integrated Header
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
                                AppStrings.personalInformations,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.textBlack,
                                  fontFamily: 'SomarSans',
                                ),
                              ),
                              8.horizontalSpace,
                              const Icon(Icons.person_outline_rounded, color: Color(0xFF7C4A27)),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) context.pop();
                            },
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
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          // 2. Avatar Section
                          _buildProfileHeader(context, user, localImage)
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
                          25.verticalSpace,
                          
                          // 3. Subscription Card
                          if (user.subscriptions.isNotEmpty) 
                            _buildStatsCards(context, user, currentUserSubscription)
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .scale(begin: const Offset(0.95, 0.95)),
                          
                          30.verticalSpace,

                          // 4. Form Fields Grid/List
                          _buildFormFields(
                            context, 
                            ref,
                            isDesktop: isDesktop,
                            availableWidth: availableWidth,
                            horizontalPadding: horizontalPadding,
                            nameController: nameController,
                            ageController: ageController,
                            phoneController: phoneController,
                            country: country,
                            region: region,
                            division: division,
                            countries: countries,
                            regions: regions,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0),

                          40.verticalSpace,

                          // 5. Save Button
                          SizedBox(
                            width: isDesktop ? 400 : double.infinity,
                            child: BigButton(
                              text: 'تحديث بياناتي الإيمانية 🌿',
                              onPressed: ref.watch(profileControllerProvider).isLoading
                                  ? null
                                  : () {
                                      if (region.value == null || division.value == null) {
                                        SnackBarService.showErrorSnackBar('يرجى ملء جميع الحقول المطلوبة', context: context);
                                        return;
                                      }
                                      ref
                                          .read(profileControllerProvider.notifier)
                                          .updateUser(UpdateUserRequest(
                                            name: nameController.text,
                                            age: int.tryParse(ageController.text) ?? 18,
                                            phoneNumber: phoneController.text,
                                            image: localImage.value,
                                            countryId: country.value?.id,
                                            regionId: region.value?.id,
                                            devisionId: division.value!.id,
                                          ));
                                    },
                            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut),
                          ),
                          
                          120.verticalSpace,
                        ],
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

  Widget _buildProfileHeader(BuildContext context, dynamic user, ValueNotifier<File?> localImage) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeIconUrl = user.badge?.completeIconUrl;
    final badgeColor = user.badge?.color;
    final themeColor = badgeColor != null
        ? Color(int.parse(badgeColor.replaceAll('#', '0xFF')))
        : (isDark ? const Color(0xFF10B981) : AppColors.warmTitle);

    return Hero(
      tag: 'profile_badge',
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShieldBadge(
            localAvatarImage: localImage.value != null ? FileImage(localImage.value!) : null,
            userAvatarUrl: localImage.value == null ? user.completeProfilePic : null,
            badgeIconUrl: badgeIconUrl,
            themeColor: themeColor,
            width: 140.sp,
            height: 175.sp,
            avatarPaddingTop: 35.sp,
            avatarSize: 120.sp,
          ),
          Positioned(
            bottom: 5.h,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final resultImage = await ImagePickerService.pickImage();
                if (resultImage != null) {
                  localImage.value = resultImage;
                }
              },
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF10B981) : AppColors.warmTitle,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20.sp),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds, duration: 1.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, dynamic user, dynamic subscription) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: _StatCard(
        title: "نوع مساهمة الوقف",
        value: subscription?.name ?? 'وقف عام',
        icon: Icons.mosque_rounded,
        gradient: isDark 
            ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
            : AppColors.warmGradient,
        isDark: isDark,
      ),
    );
  }

  Widget _buildFormFields(
    BuildContext context, 
    WidgetRef ref, {
    required bool isDesktop,
    required double availableWidth,
    required double horizontalPadding,
    required TextEditingController nameController,
    required TextEditingController ageController,
    required TextEditingController phoneController,
    required ValueNotifier<Country?> country,
    required ValueNotifier<Region?> region,
    required ValueNotifier<DivisionModel?> division,
    required List<Country> countries,
    required List<Region> regions,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final fields = [
      CustomTextFormField(
        controller: nameController,
        labelText: AppStrings.name,
        suffix: Icon(Icons.person_outline_rounded, color: isDark ? const Color(0xFF10B981) : AppColors.warmTitle),
      ),
      CustomTextFormField(
        controller: ageController,
        labelText: "العمر",
        keyboardType: TextInputType.number,
        suffix: Icon(Icons.cake_outlined, color: isDark ? const Color(0xFF10B981) : AppColors.warmTitle),
      ),
      CustomTextFormField(
        controller: phoneController,
        labelText: AppStrings.phoneNumber,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_outlined, size: 20),
            4.horizontalSpace,
            if (country.value?.phoneCode != null)
              Text(
                country.value!.phoneCode!.startsWith('+') 
                    ? country.value!.phoneCode! 
                    : '+${country.value!.phoneCode!}',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF10B981) : AppColors.warmTitle,
                ),
              ),
            4.horizontalSpace,
            Container(
              width: 1,
              height: 20.h,
              color: Colors.white24,
            ),
            8.horizontalSpace,
          ],
        ),
      ),
      TayssirDropDown<Country>(
        selectedItem: country.value,
        items: countries,
        onChanged: (value) {
          if (value == country.value) return;
          country.value = value;
          region.value = null;
        },
        hintText: AppStrings.country,
        iconPath: SVGs.icBuilding,
      ),
      TayssirDropDown<Region>(
        selectedItem: region.value,
        items: region.value != null ? regions : [],
        onChanged: (value) {
          region.value = value;
        },
        hintText: AppStrings.region,
        iconPath: SVGs.icCommune,
      ),
      TayssirDropDown<DivisionModel>(
        selectedItem: division.value,
        items: ref.watch(divisionsProvider).valueOrNull ?? [],
        onChanged: (value) {
          division.value = value;
        },
        hintText: "تصنيف الحفظ (مكي/مدني)",
        iconPath: SVGs.icSpecitlity,
      ),
    ];

    if (isDesktop) {
        final double spacing = 20.w;
        final double effectiveWidth = availableWidth - (horizontalPadding * 2);
        final double cardWidth = (effectiveWidth - spacing) / 2;

        return Wrap(
            spacing: spacing,
            runSpacing: 16.h,
            children: fields.map((f) => SizedBox(
                width: cardWidth,
                child: f,
            )).toList(),
      );
    }

    return Column(
      children: fields.expand((f) => [f, 16.verticalSpace]).toList()..removeLast(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(color: isDark ? Colors.white : AppColors.textBlack, fontSize: 18.sp, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
