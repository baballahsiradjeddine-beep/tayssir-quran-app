import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tayssir/environment_config.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:tayssir/common/painters/islamic_pattern_painter.dart';

class BannerWidget extends StatelessWidget {
  final String? title;
  final String? description;
  final String actionUrl;
  final String gradientStart;
  final String gradientEnd;
  final String? image;
  final String? desktopImage;

  const BannerWidget({
    super.key,
    this.title,
    this.description,
    required this.actionUrl,
    required this.gradientStart,
    required this.gradientEnd,
    this.image,
    this.desktopImage,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we are on a desktop-sized screen (> 800)
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    
    // Pick the most appropriate image
    final String? effectiveImage = (isDesktop && desktopImage != null)
        ? desktopImage
        : image;

    final bool hasImage = effectiveImage != null;

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(actionUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      child: Container(
        height: 115.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: !hasImage
              ? LinearGradient(
                  colors: [
                    _parseColor(gradientStart),
                    _parseColor(gradientEnd),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20), // Updated to match SubscribeButton
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Islamic Star Pattern for all banners
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  painter: IslamicPatternPainter(
                    spacing: 25.0,
                    starRadius: 6.0,
                  ),
                ),
              ),
            ),
            
            if (hasImage)
              Positioned.fill(child: _buildImageBanner(context, effectiveImage!))
            else
              Positioned.fill(child: _buildGradientBanner(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBanner(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        Text(
          description ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildImageBanner(BuildContext context, String imageUrl) {
    final bool isSvg = imageUrl.endsWith('.svg') || imageUrl.contains('.svg?');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image/SVG
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: isSvg
                ? (imageUrl.startsWith('assets/')
                    ? SvgPicture.asset(imageUrl, fit: BoxFit.cover)
                    : Builder(builder: (context) {
                        try {
                          return SvgPicture.network(
                            EnvironmentConfig.resolveImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            // If the server returns HTML (404) instead of real SVG, show nothing
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          );
                        } catch (_) {
                          return const SizedBox.shrink();
                        }
                      }))
                : (imageUrl.startsWith('assets/')
                    ? Image.asset(imageUrl, fit: BoxFit.cover)
                    : CustomCachedImage(
                        imageUrl: imageUrl, // CustomCachedImage handles EnvironmentConfig.resolveImageUrl internally
                        fit: BoxFit.cover,
                      )),
          ),

          // Content Overlay
          title == null && description == null || (description != null && description!.isEmpty)
              ? const SizedBox.shrink()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: .5, sigmaY: .5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              if (description != null)
                                Text(
                                  description!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  /// Safely parses a hex color string. Returns a fallback color on invalid input.
  static Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceFirst('#', '').trim();
      if (cleaned.length == 6) {
        return Color(int.parse('0xff$cleaned'));
      } else if (cleaned.length == 8) {
        return Color(int.parse('0x$cleaned'));
      }
    } catch (_) {}
    return const Color(0xFF064E3B); // safe emerald fallback
  }
}
