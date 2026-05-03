import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayssir/environment_config.dart';
import 'package:tayssir/providers/app_assets/app_assets_provider.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import 'package:flutter/foundation.dart';

enum AppAssetType { svg, image }

class DynamicAppAsset extends ConsumerWidget {
  /// The unique key for this asset (matches the backend key)
  final String assetKey;

  /// The local fallback asset path (e.g. 'assets/svg/subscribe.svg' or 'assets/png/hero.png')
  final String fallbackAssetPath;

  /// Whether the fallback is an SVG or normal Image
  final AppAssetType type;

  /// Optional parameters for SVG or Image
  final double? width;
  final double? height;
  final BoxFit fit;

  const DynamicAppAsset({
    super.key,
    required this.assetKey,
    required this.fallbackAssetPath,
    this.type = AppAssetType.svg, // Default is SVG because it's most common in your app
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsState = ref.watch(appAssetsProvider);

    return assetsState.maybeWhen(
      data: (assetsMap) {
        final serverAsset = assetsMap[assetKey];
        
        if (serverAsset != null && serverAsset.url.isNotEmpty) {
          final rawUrl = '${serverAsset.url}?${serverAsset.version}';
          final imageUrl = EnvironmentConfig.resolveImageUrl(rawUrl);
          final isSvg = imageUrl.toLowerCase().contains('.svg');
          
          if (isSvg) {
            return SvgPicture.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholderBuilder: (BuildContext context) => _buildFallback(),
            );
          } else {
            if (kIsWeb) {
              String getObjectFit() {
                switch (fit) {
                  case BoxFit.cover: return 'cover';
                  case BoxFit.contain: return 'contain';
                  case BoxFit.fill: return 'fill';
                  case BoxFit.fitWidth: return 'cover';
                  case BoxFit.fitHeight: return 'cover';
                  default: return 'contain';
                }
              }
              return SizedBox(
                width: width,
                height: height,
                child: HtmlElementView.fromTagName(
                  tagName: 'img',
                  onElementCreated: (Object element) {
                    final dynamic img = element;
                    img.src = imageUrl;
                    img.style.objectFit = getObjectFit();
                    img.style.width = '100%';
                    img.style.height = '100%';
                    // We must attach an error listener directly to the DOM element if we want fallback
                    img.onerror = (dynamic event) {
                       print('>>> DynamicAppAsset HTML ERROR [$assetKey]');
                    };
                  },
                ),
              );
            }
            return CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => shimmer.Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.2),
                highlightColor: Colors.grey.withOpacity(0.1),
                child: Container(
                  width: width ?? 100,
                  height: height ?? 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              errorWidget: (context, url, error) {
                print('>>> DynamicAppAsset ERROR [$assetKey]: $error');
                return _buildFallback();
              },
            );
          }
        }

        // Otherwise (or if URL is empty), use the local fallback
        return _buildFallback();
      },
      // If loading or error, use local fallback so user never sees a broken image
      orElse: () => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    if (type == AppAssetType.svg) {
      return SvgPicture.asset(
        fallbackAssetPath,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      return Image.asset(
        fallbackAssetPath,
        width: width,
        height: height,
        fit: fit,
      );
    }
  }
}
