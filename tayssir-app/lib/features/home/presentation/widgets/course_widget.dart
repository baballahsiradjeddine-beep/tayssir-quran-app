import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/tools/common/models/tool_model.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import 'package:tayssir/environment_config.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class CardWidget extends ConsumerWidget {
  const CardWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.onPressed,
    required this.startColor,
    required this.endColor,
    this.imageList = '',
    this.imageGrid = '',
    this.isGrid = false,
    this.isLocked = false,
    this.toolImage,
    this.isStartBottomColor = true,
    this.progress = 0,
    this.unitsCount = 0,
    this.chaptersCount = 0,
  });

  final bool isLocked;
  final String title;
  final String subTitle;
  final Function onPressed;
  final Color startColor;
  final Color endColor;
  final bool isGrid;
  final String imageList;
  final String imageGrid;
  // Optional fields for ToolsScreen compatibility
  final ToolImage? toolImage;
  final bool isStartBottomColor;
  final double progress;
  final int unitsCount;
  final int chaptersCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isGrid) {
      return _buildGridCard(context, ref);
    } else {
      return _buildListCard(context, ref);
    }
  }

  Widget _buildGridCard(BuildContext context, WidgetRef ref) {
    final bool isDesktop = MediaQuery.sizeOf(context).width > 800;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          ref.read(specialEffectServiceProvider).playEffects();
          onPressed();
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [startColor, endColor]
                : [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Light effect overlay
              Positioned(
                left: -30.w,
                top: -30.h,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Content Layout
              isDesktop 
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                      child: Row(
                        children: [
                          // Text and Button Area (Right side in RTL)
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'SomarSans',
                                      height: 1.1,
                                    ),
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    subTitle.replaceAll('<br>', ' ').replaceAll('<br class="br-hide">', ' '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SomarSans',
                                      height: 1.2,
                                    ),
                                  ),
                                  10.verticalSpace,
                                  
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, 
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Text(
                                          isLocked ? "قريباً" : (title.contains('جولة') ? "ابدأ التجربة ✨" : "ابدأ الحفظ ✨"),
                                          style: TextStyle(
                                            color: endColor.withOpacity(0.9),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'SomarSans',
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),

                          // Mascot/Image Area (Left side in RTL)
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildImageWidget(
                                toolImage?.grid ?? (imageGrid.isNotEmpty ? imageGrid : imageList),
                                125.h,
                                125.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.expand(
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),
                            Center(
                              child: _buildImageWidget(
                                toolImage?.grid ?? (imageGrid.isNotEmpty ? imageGrid : imageList),
                                130.h,
                                130.h,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          ref.read(specialEffectServiceProvider).playEffects();
          onPressed();
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: 120.h, // Increased from 110.h to fix overflow
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [startColor, endColor]
                : [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Decorative Light Effect
              Positioned(
                left: -20.w,
                top: -20.h,
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Row(
                children: [
                  // 1. Text & Content Section (Left side in RTL)
                  Expanded(
                    flex: 80,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 8.h, 24.w, 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SomarSans',
                              height: 1.1,
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            subTitle.replaceAll('<br>', ' ').replaceAll('<br class="br-hide">', ' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SomarSans',
                            ),
                          ),
                          4.verticalSpace,
                          const Spacer(),
                          // Action Button
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Text(
                              isLocked ? "قريباً" : (title.contains('جولة') ? "ابدأ التجربة ✨" : "ابدأ الحفظ ✨"),
                              style: TextStyle(
                                color: endColor.withOpacity(0.9),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                          ),
                          6.verticalSpace,
                          // Progress Section
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: (progress / 100).clamp(0.05, 1.0),
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              10.horizontalSpace,
                              Text(
                                '${progress.toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Mascot/Image Section (Right side in RTL)
                  Expanded(
                    flex: 20,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: Border(
                          right: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                        ),
                      ),
                      child: Center(
                        child: _buildImageWidget(
                          toolImage?.list ?? imageList,
                          100.h,
                          100.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath, double height, double width) {
    if (imagePath.isEmpty) {
      // Default fallback for subjects/tools
      final fallbackPath = isGrid ? 'modules/images_grid/math.png' : 'modules/images_list/math.png';
      return _renderNetworkImage(fallbackPath, height, width);
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: BoxFit.contain,
      );
    }

    return _renderNetworkImage(imagePath, height, width);
  }

  Widget _renderNetworkImage(String path, double height, double width) {
    if (path.isEmpty) return const SizedBox.shrink();
    return CustomCachedImage(
      imageUrl: path,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorWidget: Center(
        child: Text(
          _getEmojiForSubject(title),
          style: TextStyle(fontSize: isGrid ? 75.sp : 85.sp),
        ),
      ),
    );
  }

  String _getEmojiForSubject(String title) {
    if (title.contains('البقرة')) return '🐄';
    if (title.contains('الكهف')) return '⛰️';
    if (title.contains('يس')) return '📜';
    if (title.contains('تبارك')) return '✨';
    if (title.contains('جزء')) return '📖';
    if (title.contains('حفظ')) return '💎';
    if (title.contains('مراجعة')) return '🔄';
    if (title.contains('تجويد')) return '🗣️';
    return '🕌';
  }

  Widget _buildMiniStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16.sp),
        6.horizontalSpace,
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'SomarSans',
          ),
        ),
      ],
    );
  }
}
