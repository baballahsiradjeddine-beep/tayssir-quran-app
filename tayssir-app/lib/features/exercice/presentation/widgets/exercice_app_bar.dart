import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/exercice/presentation/state/exercise_state.dart';
import 'package:tayssir/features/exercice/presentation/widgets/exercise_header.dart';
import 'package:tayssir/providers/settings/settings_provider.dart';

class ExerciceAppBar extends ConsumerWidget {
  const ExerciceAppBar({
    super.key,
    required this.exercisesState,
    required this.onClosePressed,
  });

  final ExerciseState exercisesState;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? 60.0 : 16.w;
        const double maxContentWidth = 1000.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 16.h : 8.h,
                ),
                child: Row(
                  children: [
                    // Theme Toggle Button (Right side in RTL)
                    GestureDetector(
                      onTap: () => ref.read(settingsNotifierProvider.notifier).toggleDarkMode(),
                      child: Container(
                        width: 40.sp,
                        height: 40.sp,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          settings.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 20.sp,
                          color: settings.isDarkMode ? Colors.yellow : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    
                    24.horizontalSpace,
                    
                    // Progress Bar and Points Section (Center)
                    Expanded(
                      child: Row(
                        children: [
                           ExerciseHeader(progress: exercisesState.progress),
                           20.horizontalSpace,
                           // Points Display (GEM)
                           Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                                Text(
                                  exercisesState.points.toString(),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'SomarSans',
                                  ),
                                ),
                                6.horizontalSpace,
                                Text(
                                  "💎", 
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                             ],
                           ),
                        ],
                      ),
                    ),
                    
                    20.horizontalSpace,
                    
                    // Close Button (Left side in RTL)
                    IconButton(
                      onPressed: onClosePressed,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white : const Color(0xFF64748B),
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
