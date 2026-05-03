import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/utils/extensions/context.dart';

import '../../common/core/app_logo.dart';
import '../../resources/resources.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayssir/providers/app_assets/app_assets_provider.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/environment_config.dart';
import '../../common/bayan_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _precacheData();
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _precacheData();
  }

  void _precacheData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Pre-cache only safely on mobile. Web uses native DOM <img> which handles caching natively.
      if (kIsWeb) return;
      
      ImageProvider getProvider(String url) => CachedNetworkImageProvider(url);

      // 1. Pre-cache dynamic App Assets
      final assetsState = ref.read(appAssetsProvider);
      assetsState.whenData((assetsMap) {
        if (!mounted) return;
        for (final asset in assetsMap.values) {
          if (asset.url.isNotEmpty) {
            final rawUrl = '${asset.url}?${asset.version}';
            final fullUrl = EnvironmentConfig.resolveImageUrl(rawUrl);
            if (!fullUrl.toLowerCase().contains('.svg')) {
              precacheImage(getProvider(fullUrl), context);
            }
          }
        }
      });

      // 2. Pre-cache subject/material images
      final materials = ref.read(dataProvider).contentData.modules;
      if (materials.isNotEmpty && mounted) {
        for (final m in materials) {
          final imageUrls = [m.imageList, m.imageGrid];
          for (final rawUrl in imageUrls) {
            if (rawUrl.isNotEmpty && mounted) {
               final String fullUrl = EnvironmentConfig.resolveImageUrl(rawUrl);
               precacheImage(getProvider(fullUrl), context);
            }
          }
        }
      }

      // 3. Pre-cache user profile assets
      final user = ref.read(userNotifierProvider).valueOrNull;
      if (user != null && mounted) {
        if (user.completeProfilePic.isNotEmpty) {
          final fullUrl = EnvironmentConfig.resolveImageUrl(user.completeProfilePic);
          precacheImage(getProvider(fullUrl), context);
        }
        final badgeUrl = user.badge?.completeIconUrl;
        if (badgeUrl != null && badgeUrl.isNotEmpty && mounted) {
          final fullUrl = EnvironmentConfig.resolveImageUrl(badgeUrl);
          precacheImage(getProvider(fullUrl), context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = context.isSmallDevice ? 220.h : 250.h;
    final assetsState = ref.watch(appAssetsProvider);

    return BayanBackground(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 1.h),
              Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: assetsState.maybeWhen(
                      data: (_) => DynamicAppAsset(
                        key: const ValueKey('splash_hero_ready'),
                        assetKey: 'home_hero',
                        fallbackAssetPath: SVGs.refiqLogin,
                        type: AppAssetType.svg,
                        height: size,
                      ),
                      orElse: () => SizedBox(
                        key: const ValueKey('splash_hero_loading'),
                        height: size,
                      ),
                    ),
                  ),
                  20.verticalSpace,
                  const AppLogo(),
                ],
              ),
              Column(
                children: [
                  const TayssirDataLoader(),
                  30.verticalSpace,
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class TayssirDataLoader extends StatelessWidget {
  const TayssirDataLoader({
    super.key,
    this.textSize = 20,
    this.iconSize = 50,
  });

  final double textSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          'جاري تحميل البيانات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white : AppColors.textBlack,
              fontSize: textSize.sp,
              fontWeight: FontWeight.bold),
        ),
        10.verticalSpace,
        LoadingAnimationWidget.progressiveDots(
            size: iconSize, color: AppColors.secondaryColor),
      ],
    );
  }
}
