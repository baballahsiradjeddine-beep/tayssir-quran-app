import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/providers/data/models/charity_model.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CharityDetailScreen extends StatefulWidget {
  final CharityCampaign campaign;

  const CharityDetailScreen({super.key, required this.campaign});

  @override
  State<CharityDetailScreen> createState() => _CharityDetailScreenState();
}

class _CharityDetailScreenState extends State<CharityDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.campaign.mainMediaType == 'video' && widget.campaign.mainVideoUrl.isNotEmpty;
    if (_isVideo) {
      final videoId = YoutubePlayerController.convertUrlToId(widget.campaign.mainVideoUrl);
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId ?? '',
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BayanBackground(
      child: AppScaffold(
        bodyBackgroundColor: isDark ? null : AppColors.warmBackground,
        topSafeArea: false,
        paddingX: 0,
        paddingY: 0,
        body: CustomScrollView(
          slivers: [
            // 1. App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, left: 20.w, right: 20.w),
                child: const CustomAppBar(
                  showLogo: true,
                  showActions: true,
                  reverse: true,
                ),
              ),
            ),

            // 2. Main Image / Video
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 220.h,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.warmBorder),
                      ),
                      child: _isVideo
                          ? YoutubePlayer(controller: _controller)
                          : CachedNetworkImage(
                              imageUrl: widget.campaign.mainImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                    ).animate().scale(delay: 200.ms),
                    
                    24.verticalSpace,
                    
                    Text(
                      widget.campaign.title,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.warmTitle,
                        fontFamily: 'SomarSans',
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    
                    if (widget.campaign.documentationImages.isNotEmpty) ...[
                      12.verticalSpace,
                      Text(
                        "توثيق الإنجاز والمراحل :",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryColor : AppColors.warmAccent,
                          fontFamily: 'SomarSans',
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ],
                ),
              ),
            ),

            // 3. Media Grid (Photos)
            if (widget.campaign.documentationImages.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final media = widget.campaign.documentationImages[index];
                      return Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.warmBorder),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: media.url,
                          fit: BoxFit.cover,
                        ),
                      ).animate().fadeIn(delay: (500 + index * 100).ms).scale();
                    },
                    childCount: widget.campaign.documentationImages.length,
                  ),
                ),
              ),

            // 4. Description Text
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "عن هذه الحملة",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.warmTitle,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                      12.verticalSpace,
                      Text(
                        _stripHtml(widget.campaign.description),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white.withOpacity(0.7) : AppColors.warmSubtitle,
                          fontFamily: 'SomarSans',
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();
  }
}

