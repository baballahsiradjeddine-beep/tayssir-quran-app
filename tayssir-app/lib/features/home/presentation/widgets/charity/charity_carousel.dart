import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/providers/data/models/charity_model.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class CharityCarousel extends StatefulWidget {
  final List<CharityCampaign> campaigns;
  const CharityCarousel({Key? key, required this.campaigns}) : super(key: key);

  @override
  State<CharityCarousel> createState() => _CharityCarouselState();
}

class _CharityCarouselState extends State<CharityCarousel> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _patternController;
  late Animation<double> _patternAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late final ScrollController _scrollController;

  static const double _spacing = 160.0;
  static const double _dotW = 100.0;

  @override
  void initState() {
    super.initState();
    final campaignsList = widget.campaigns.toList();
    final idx = campaignsList.indexWhere((c) => c.status == 'ongoing');
    final activeIdx = idx != -1 ? idx : 0;
    _scrollController = ScrollController(initialScrollOffset: activeIdx * _spacing);

    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _patternController = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _patternAnimation = Tween<double>(begin: 0, end: 1).animate(_patternController);

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _patternController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaigns.isEmpty) return const SizedBox.shrink();

    final campaigns = widget.campaigns.toList();
    final activeIdx = campaigns.indexWhere((c) => c.status == 'ongoing');
    final active = activeIdx != -1 ? campaigns[activeIdx] : campaigns.first;
    final screenW = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDesktop = screenW > 900;
    
    final double outerHorizontalPadding = isDesktop ? 60.w : 20.w;
    
    final int n = campaigns.length;
    final double stackW = (n - 1) * _spacing + _dotW;
    final double stackH = isDesktop ? 105.h : 100.h;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1250.w),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: outerHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('سهم الخير والوقف',
                        style: TextStyle(
                            fontSize: isDesktop ? 22.sp : 19.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.warmTitle,
                            fontFamily: 'SomarSans')),
                    12.horizontalSpace,
                    Container(
                      width: 4.w, height: 20.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.goldColor, AppColors.goldColor.withOpacity(0.5)]),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ],
                ),
              ),
              12.verticalSpace,
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F172A), const Color(0xFF064E3B).withOpacity(0.5)]
                        : [const Color(0xFFFCFAF7), const Color(0xFFF1F5F9)], // Premium light gradient
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : AppColors.warmTitle.withOpacity(0.08), 
                      blurRadius: 20, 
                      offset: const Offset(0, 10)
                    )
                  ],
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder.withOpacity(0.6), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _patternAnimation,
                          builder: (_, __) => CustomPaint(
                            painter: _IslamicPatternPainter(
                              color: isDark ? Colors.white.withOpacity(0.015) : AppColors.warmTitle.withOpacity(0.03),
                              progress: _patternAnimation.value,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 25.w),
                        child: isDesktop 
                          ? Row( 
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildInfoColumn(active, isDark, isDesktop),
                                Expanded(
                                  child: Center(
                                    child: _buildTimeline(stackH, stackW, 0, campaigns, activeIdx, isDark),
                                  ),
                                ),
                              ],
                            )
                          : Column( 
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [_buildInfoColumn(active, isDark, isDesktop)],
                                ),
                                15.verticalSpace,
                                _buildTimeline(stackH, stackW, 0, campaigns, activeIdx, isDark),
                              ],
                            ),
                      ),
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

  Widget _buildInfoColumn(CharityCampaign active, bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('المبلغ المتبقي للمرحلة',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : AppColors.warmSubtitle, fontFamily: 'Cairo')),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('دج', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isDark ? AppColors.goldColor : AppColors.warmAccent)),
            8.horizontalSpace,
            Text('${active.remainingAmount.toInt()}',
                style: TextStyle(fontSize: isDesktop ? 38.sp : 32.sp, fontWeight: FontWeight.w900, color: isDark ? AppColors.goldColor : AppColors.warmAccent, height: 1.0)),
          ],
        ),
        10.verticalSpace,
        _donateBtn(context, active),
      ],
    );
  }

  Widget _buildTimeline(double stackH, double stackW, double horizontalPadding, List<CharityCampaign> campaigns, int activeIdx, bool isDark) {
    final double lineW = (campaigns.length - 1) * _spacing;
    return SizedBox(
      height: stackH,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: stackW + horizontalPadding * 2,
          height: stackH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: horizontalPadding + _dotW / 2,
                width: lineW,
                top: 22.h,
                height: 6.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              (() {
                double cumulativeProgress = 0;
                for (int i = 0; i < campaigns.length - 1; i++) {
                   if (activeIdx != -1 && i < activeIdx) {
                     cumulativeProgress += 1.0;
                   } else if (i == activeIdx) {
                     cumulativeProgress += campaigns[i].progress;
                     break;
                   }
                }
                return Positioned(
                  right: horizontalPadding + _dotW / 2,
                  width: (cumulativeProgress * _spacing).clamp(0.0, lineW),
                  top: 22.h,
                  height: 6.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                            ? [const Color(0xFF10B981), const Color(0xFF34D399)] 
                            : [AppColors.warmAccent, AppColors.goldColor],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? const Color(0xFF10B981) : AppColors.warmAccent).withOpacity(isDark ? 0.5 : 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                );
              })(),
              ...campaigns.asMap().entries.map((e) {
                final i = e.key;
                final c = e.value;
                final isActive = i == activeIdx || (activeIdx == -1 && i == 0);
                final isPast = activeIdx != -1 && i < activeIdx;
                
                return Positioned(
                  right: horizontalPadding + i * _spacing,
                  width: _dotW,
                  top: 0,
                  height: stackH,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.pushNamed(AppRoutes.charityDetail.name, extra: {'campaign': c}),
                      child: Column(
                        children: [
                          8.verticalSpace,
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isActive)
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 40.w, height: 40.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (isDark ? const Color(0xFF10B981) : AppColors.warmAccent).withOpacity(0.12),
                                    ),
                                  ),
                                ),
                              Container(
                                width: isActive ? 30.w : 24.w,
                                height: isActive ? 30.w : 24.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive 
                                      ? (isDark ? const Color(0xFF10B981) : AppColors.warmAccent) 
                                      : isPast ? (isDark ? AppColors.goldColor : AppColors.warmAccent) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                  border: Border.all(
                                    color: isActive || isPast ? Colors.white : (isDark ? Colors.white12 : AppColors.warmBorder),
                                    width: isActive ? 3.5.r : 2.5.r,
                                  ),
                                  boxShadow: [
                                    if (isActive || isPast)
                                      BoxShadow(
                                        color: (isActive ? (isDark ? const Color(0xFF10B981) : AppColors.warmAccent) : AppColors.goldColor).withOpacity(0.4),
                                        blurRadius: 10,
                                        spreadRadius: 1.5,
                                      )
                                  ],
                                ),
                                child: isActive ? Center(
                                  child: Container(
                                    width: 8.w, height: 8.w,
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  ),
                                ) : (isPast ? const Icon(Icons.check, color: Colors.white, size: 14) : null),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Text(c.title, 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis, 
                              style: TextStyle(
                                  fontSize: 14.sp, 
                                  fontWeight: isActive ? FontWeight.w800 : FontWeight.bold, 
                                  color: isActive ? (isDark ? Colors.white : AppColors.warmTitle) : (isDark ? Colors.white30 : AppColors.warmSubtitle),
                                  fontFamily: 'Cairo')),
                          Text('${c.targetAmount.toInt()} دج', 
                              style: TextStyle(
                                  fontSize: 11.sp, 
                                  color: isActive ? (isDark ? AppColors.goldColor : AppColors.warmAccent) : (isDark ? Colors.white12 : AppColors.warmSubtitle.withOpacity(0.4)),
                                  fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _donateBtn(BuildContext context, CharityCampaign campaign) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.pushNamed(AppRoutes.charityDonation.name, extra: {'campaign': campaign}),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: isDark 
                  ? [const Color(0xFF10B981), const Color(0xFF059669)] 
                  : [AppColors.warmTitle, AppColors.warmAccent], // Warm Brown to Bronze gradient
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF10B981) : AppColors.warmTitle).withOpacity(0.3), 
                blurRadius: 12, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 16.sp),
              10.horizontalSpace,
              Text('ساهم الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.sp, fontFamily: 'SomarSans')),
            ],
          ),
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double progress;
  _IslamicPatternPainter({required this.color, this.progress = 0});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.8..style = PaintingStyle.stroke;
    const double side = 60.0;
    final double ox = (progress * side) % side;
    for (double x = -side + ox; x < size.width + side; x += side) {
      for (double y = -side; y < size.height + side; y += side) {
        _star(canvas, Offset(x, y), side / 2.2, paint);
      }
    }
  }
  void _star(Canvas canvas, Offset c, double r, Paint p) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawRect(rect, p);
    canvas.rotate(3.14159 / 4);
    canvas.drawRect(rect, p);
    canvas.drawCircle(Offset.zero, r * 0.2, p);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_IslamicPatternPainter old) => old.progress != progress;
}
