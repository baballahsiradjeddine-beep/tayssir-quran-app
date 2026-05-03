import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tayssir/environment_config.dart';

class AnimatedCircularProgressWidget extends StatelessWidget {
  const AnimatedCircularProgressWidget({
    super.key,
    required this.color,
    required this.percentage,
    this.imageUrl,
    this.isLocked = false,
    this.showPercentage = false,
    this.size = 65,
    this.borderWidth = 4.0,
    this.padding = 2.0,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.onTap,
    this.showImageIcon = true,
    this.showText = false,
    this.backgroundColor = Colors.white,
  });

  final Color color;
  final double percentage;
  final String? imageUrl;
  final bool isLocked;
  final bool showPercentage;
  final double size;
  final double borderWidth;
  final double padding;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final bool showImageIcon;
  final bool showText;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Determine the complete Image URL
    String fullImageUrl = '';
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      fullImageUrl = EnvironmentConfig.resolveImageUrl(imageUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: CircularPercentIndicator(
          radius: size / 2,
          lineWidth: borderWidth,
          percent: percentage / 100,
          backgroundColor: backgroundColor == Colors.transparent 
              ? Colors.white.withOpacity(0.1) 
              : const Color(0xffEEEEEE),
          progressColor: color,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: animationDuration.inMilliseconds,
          center: Container(
            width: size - (2 * borderWidth), 
            height: size - (2 * borderWidth),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            padding: EdgeInsets.all(padding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Image or placeholder
                fullImageUrl.isNotEmpty
                    ? CustomCachedImage(
                        imageUrl: imageUrl!,
                        width: size - (2 * borderWidth) - (2 * padding),
                        height: size - (2 * borderWidth) - (2 * padding),
                        fit: BoxFit.cover,
                        isGrayscale: isLocked,
                        borderRadius: (size - (2 * borderWidth) - (2 * padding)) / 2,
                      )
                    : Container(
                        width: size - (2 * borderWidth) - (2 * padding),
                        height: size - (2 * borderWidth) - (2 * padding),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: showImageIcon
                            ? Icon(
                                Icons.image,
                                color: percentage >= 0.99 ? color : Colors.grey,
                                size: (size - (2 * borderWidth) - (2 * padding)) / 3,
                              )
                            : showText
                                ? Center(
                                    child: Text(
                                      percentage == 100
                                          ? '100'
                                          : '${percentage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: backgroundColor == Colors.transparent ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null),
                // Lock overlay
                if (isLocked)
                  Container(
                    width: size - (2 * borderWidth) - (2 * padding),
                    height: size - (2 * borderWidth) - (2 * padding),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: (size - (2 * borderWidth) - (2 * padding)) / 4,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
