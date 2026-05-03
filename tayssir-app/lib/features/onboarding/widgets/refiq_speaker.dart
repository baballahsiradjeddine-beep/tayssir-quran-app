import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/common/bayan_bubble_talk_widget.dart';
import 'package:tayssir/utils/enums/triangle_side.dart';

/// Tito dolphin + speech bubble composite widget for onboarding
class RefiqSpeaker extends StatelessWidget {
  final String message;
  const RefiqSpeaker({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Speech bubble
        BayanBubbleTalkWidget(
          text: message,
          triangleSide: TriangleSide.bottom,
        ),

        8.verticalSpace,

        // Tito floating dolphin
        Text(
          '📖',
          style: TextStyle(fontSize: 90.sp),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: -6,
              end: 6,
              duration: 2.seconds,
              curve: Curves.easeInOutSine,
            )
            .rotate(
              begin: -0.03,
              end: 0.03,
              duration: 3.seconds,
              curve: Curves.easeInOutSine,
            ),
      ],
    );
  }
}
