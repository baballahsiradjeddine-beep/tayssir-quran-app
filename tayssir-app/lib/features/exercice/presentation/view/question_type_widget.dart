import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/features/exercice/presentation/view/question_widget.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/common/core/shield_badge.dart';
import 'package:tayssir/providers/user/user_notifier.dart';

class QuestionTypeWidget extends ConsumerWidget {
  const QuestionTypeWidget({
    super.key,
    required this.question,
  });

  final String question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userNotifierProvider).valueOrNull;
    final exercisesState = ref.watch(exercicesProvider);
    final currentExerciseIndex = exercisesState.currentExerciceIndex + 1;
    final exercise = exercisesState.currentExercise;
    final totalExercises = exercisesState.exercises.length;
    
    final badgeColor = user?.badge?.color;
    final themeColor = badgeColor != null
        ? Color(int.parse(badgeColor.replaceAll('#', '0xFF')))
        : AppColors.warmAccent;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge Section (Right in RTL)
          ShieldBadge(
            userAvatarUrl: user?.completeProfilePic,
            badgeIconUrl: user?.badge?.completeIconUrl,
            themeColor: themeColor,
            width: 72.w,
            height: 88.h,
            avatarPaddingTop: 24.h,
            avatarSize: 60.sp,
          ),
          
          18.horizontalSpace,

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "سؤال $currentExerciseIndex من $totalExercises",
                  style: TextStyle(
                    color: AppColors.warmAccent,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SomarSans',
                  ),
                ),
                4.verticalSpace,
                Text(
                  question,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SomarSans',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Hint button — far left in RTL (appears leftmost on screen)
          if (exercise.shouldShowHint) ...[
            18.horizontalSpace,
            QuestionWidget(onTap: () {
              DialogService.showHintDialog(
                context,
                exercise.hints,
                exercise.hintImage,
              );
            }),
          ],
        ],
      ),
    );
  }
}
