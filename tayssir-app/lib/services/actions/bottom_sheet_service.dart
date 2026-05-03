import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/common/sheets/result_bottom_sheet.dart';

import '../../common/app_buttons/big_button.dart';
import '../../constants/strings.dart';
import '../action_button_sheet.dart';

class BottomSheetService {
  // The blue "تحقق" button sits in content area (screen - sidebar) with 40px
  // horizontal padding on each side. The sheet must match these exact same bounds.
  static const double _sidebarWidth = 250.0; // desktop sidebar width
  static const double _contentPadding = 40.0; // horizontal padding on each side
  static const double _buttonMaxWidth = 700.0; // Feedback bar maxWidth constraint

  static BoxConstraints? _sheetConstraints(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;
    if (!isDesktop) return null;

    // Content area width (excluding sidebar)
    final double contentWidth = screenWidth - _sidebarWidth;
    // The blue button width = min(800, contentWidth - 80px padding)
    final double buttonWidth = (_buttonMaxWidth < contentWidth - _contentPadding * 2)
        ? _buttonMaxWidth
        : contentWidth - _contentPadding * 2;

    return BoxConstraints(maxWidth: buttonWidth);
  }

  static Offset? _sheetAnchor(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;
    if (!isDesktop) return null;
    // Anchor so the sheet is centered on the content area (not the full screen)
    return Offset(_sidebarWidth + _contentPadding, 0);
  }

  static void showSuccessBottomSheet(
      BuildContext context, bool isCorrect, VoidCallback onNext) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      constraints: _sheetConstraints(context),
      anchorPoint: _sheetAnchor(context),
      builder: (BuildContext context) {
        return ResultBottomSheet(
          isCorrect: isCorrect,
          onNext: onNext,
        );
      },
    );
  }

  static void showErrorBottomSheet(
      BuildContext context, String message, VoidCallback onNext, bool isLatex) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        constraints: _sheetConstraints(context),
        anchorPoint: _sheetAnchor(context),
        builder: (context) {
          return ResultBottomSheet(
            isCorrect: false,
            onNext: onNext,
            onPopScope: () {},
            message: message,
            isLatex: isLatex,
          );
        });
  }

  static void showLeaveBottomSheet(BuildContext context,
      Function(BuildContext ctx) onLeave, Function(BuildContext ctx) onCancel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: _sheetConstraints(context),
      anchorPoint: _sheetAnchor(context),
      builder: (context) {
        return ActionButtonSheet(
          title: 'هل أنت متأكد',
          message: AppStrings.leaveMessage,
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: BigButton(
                  text: AppStrings.leaveNow,
                  hasBorder: false,
                  buttonType: ButtonType.secondary,
                  onPressed: () => onLeave(context),
                ),
              ),
              20.horizontalSpace,
              Expanded(
                child: BigButton(
                    text: AppStrings.continueLearning,
                    hasBorder: false,
                    onPressed: () => onCancel(context)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BlurOverlay extends StatelessWidget {
  final Widget child;

  const BlurOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply the blur effect
      child: Container(
        color: Colors.black.withOpacity(0.2), // Add a dim background
        child: child, // Display the actual bottom sheet content
      ),
    );
  }
}
