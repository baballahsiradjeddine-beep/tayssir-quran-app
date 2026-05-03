import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/router/routes_service.dart';
import 'package:tayssir/environment_config.dart';

class ImagePrecacheService {
  const ImagePrecacheService._();

  /// Caches a list of image URLs
  /// Returns the count of successfully cached images
  static Future<int> cacheImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty || kIsWeb) {
      return 0;
    }

    int successCount = 0;

    for (final url in imageUrls) {
      try {
        final resolvedUrl = EnvironmentConfig.resolveImageUrl(url);
        await precacheImage(
          CachedNetworkImageProvider(resolvedUrl),
          rootScaffoldMessengerKey.currentContext!,
        );
        successCount++;
      } catch (e) {
        AppLogger.logError('❌ Failed to cache image $url: $e');
      }
    }

    AppLogger.logInfo(
        '✅ Successfully cached $successCount/${imageUrls.length} images');

    return successCount;
  }

  /// Clears all cached images
  static Future<void> clearCache() async {
    try {
      await CachedNetworkImage.evictFromCache('');
      AppLogger.logInfo('🧹 Image cache cleared');
    } catch (e) {
      AppLogger.logError('❌ Failed to clear image cache: $e');
    }
  }
}
