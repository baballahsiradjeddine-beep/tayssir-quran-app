import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
// import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/foundation.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:latext/latext.dart';

class LatextTextWidget extends StatelessWidget {
  final int id;
  final String text;
  final bool isLatex;
  final TextAlign? textAlign;
  final FontWeight fontWeight;
  // final int? color;
  final TextStyle textStyle;
  final bool useFittedBox;
  final TextOverflow? overflow;
  final int? maxLines;
  final Function(int id)? onLatexTap;
  const LatextTextWidget({
    super.key,
    this.id = 0,
    required this.text,
    required this.isLatex,
    required this.textStyle,
    this.textAlign,
    this.fontWeight = FontWeight.w700,
    this.overflow,
    this.useFittedBox = false,
    this.maxLines,
    this.onLatexTap,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-detect LaTeX if delimiters are present but isLatex is false
    final bool effectivelyLatex = isLatex || 
        text.contains(r'\(') || 
        text.contains(r'\[') || 
        text.contains(r'$$') || 
        (text.contains(r'$') && text.split(r'$').length >= 3);

    AppLogger.logInfo('LatextTextWidget: $text, isLatex: $isLatex, effectivelyLatex: $effectivelyLatex');
    if (effectivelyLatex) {
      if (kIsWeb) {
        String mathFixedText = text
            .replaceAll(r'\(', r'$')
            .replaceAll(r'\)', r'$')
            .replaceAll(r'\[', r'$$')
            .replaceAll(r'\]', r'$$');
        return Directionality(
          textDirection: Directionality.of(context),
          child: LaTexT(
            delimiter: r'$',
            displayDelimiter: r'$$',
            laTeXCode: Text(
              mathFixedText,
              textAlign: textAlign ?? TextAlign.start,
              style: textStyle,
            ),
          ),
        );
      }
      return TeXView(
        key: Key(text),
        child: TeXViewInkWell(
          id: text,
          rippleEffect: false,
          onTap: (String id) {
            if (onLatexTap != null) {
              onLatexTap!(this.id);
            }
          },
          child: TeXViewDocument(text,
              style: const TeXViewStyle.fromCSS(
                  'padding: 0px; text-align: start;')),
        ),
        style: TeXViewStyle(
          contentColor: textStyle.color ?? Colors.black,
          textAlign: textAlign == null
              ? null
              : textAlign == TextAlign.center
                  ? TeXViewTextAlign.center
                  : textAlign == TextAlign.right
                      ? TeXViewTextAlign.right
                      : TeXViewTextAlign.left,
          fontStyle: TeXViewFontStyle(
            fontSize: textStyle.fontSize?.toInt() ?? 14,
            fontWeight: TeXViewFontWeight.bold,
          ),
        ),
      );
    } else {
      return useFittedBox
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                // style: TextStyle(
                //   color: Color(color!),
                //   fontWeight: fontWeight,
                // ),
                style: textStyle,
                textAlign: textAlign,
                overflow: overflow,
                maxLines: maxLines,
              ),
            )
          : Text(
              text,
              // style: TextStyle(
              //   color: Color(color!),
              //   fontWeight: fontWeight,
              // ),
              style: textStyle,
              textAlign: textAlign,
              overflow: overflow,
              maxLines: maxLines,
            );
    }
  }
}
