import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class TayssirIcon extends StatelessWidget {
  const TayssirIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  final String icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      colorFilter:
          ColorFilter.mode(color ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.goldColor : AppColors.warmAccent), BlendMode.srcIn),
      height: size ?? 20.h,
      width: size,
    );
  }
}
