// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/services/actions/dialog_service.dart';

class FilterSection<T> extends ConsumerWidget {
  final List<T> items;
  final bool isPremium;
  final Function(T) onItemPressed;
  // final String Function(T) itemLabelExtractor;
  // final int Function(T) itemIdExtractor;
  final Function onClearAllSelected;
  final String allLabel;
  final Color filterColor;
  final bool Function(T) selectionExtractor;
  final Function(T) getLabel;
  final bool isAllOptionsPressed;
  final double padding;
  final Color? labelColor;
  final Color Function(T)? getItemColor;

  const FilterSection({
    super.key,
    required this.items,
    required this.isPremium,
    required this.onItemPressed,
    required this.onClearAllSelected,
    required this.selectionExtractor,
    required this.isAllOptionsPressed,
    required this.getLabel,
    this.allLabel = 'الكل',
    this.filterColor = Colors.blue,
    this.padding = 8,
    this.labelColor,
    this.getItemColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider).requireValue;
    final isSubscribed = user?.isSub ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 48.h, // Increased height for better interaction
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length + 1,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final isAllChip = index == 0;
          final isSelected = isAllChip ? isAllOptionsPressed : selectionExtractor(items[index - 1]);
          final chipText = isAllChip ? allLabel : getLabel(items[index - 1]);
          final itemColor = (isAllChip || getItemColor == null) ? filterColor : getItemColor!(items[index - 1]);
          final isLocked = !isAllChip && isPremium && !isSubscribed;

          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: GestureDetector(
              onTap: () {
                if (isLocked) {
                  DialogService.showNeedSubscriptionDialog(context);
                } else if (isAllChip) {
                  onClearAllSelected();
                } else {
                  onItemPressed(items[index - 1]);
                }
              },
              child: AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [itemColor, itemColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? itemColor.withOpacity(0.5)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: itemColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLocked) ...[
                        Icon(
                          Icons.lock_rounded,
                          size: 14.sp,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                        6.horizontalSpace,
                      ],
                      Text(
                        chipText,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
