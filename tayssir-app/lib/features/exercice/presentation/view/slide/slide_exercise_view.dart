import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/providers/data/models/slide_exercise.dart';
import 'package:tayssir/features/exercice/presentation/widgets/video/video_view_portrait_widget.dart';

class SlideExerciseView extends HookConsumerWidget {
  final SlideExercise exercise;

  const SlideExerciseView({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  30.verticalSpace,
                  if (exercise.slideType == 'video' && exercise.mediaUrl != null)
                    _buildVideo(context)
                  else if (exercise.slideType == 'image' && exercise.mediaUrl != null)
                    _buildImage()
                  else
                    _buildText(context),
                  40.verticalSpace,
                ],
              ),
            ),
          ),
          _buildContinueButton(context, ref),
          30.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Text(
      exercise.contentText ?? '',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22.sp,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontFamily: 'SomarSans',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildVideo(BuildContext context) {
     return Container(
       height: 250.h,
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(16.r),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.1),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
       clipBehavior: Clip.antiAlias,
       child: VideoViewPortraitWidget(size: MediaQuery.of(context).size),
     );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Image.network(
        exercise.mediaUrl!,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // Simply move to the next item
          ref.read(exercicesProvider.notifier).nextExerise(context);
        },
        child: Text(
          'متابعة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
