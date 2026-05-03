import 'dart:developer';

import 'package:tayssir/environment_config.dart';

class LatexField<T> {
  final bool isLatex;
  final T text;

  LatexField(this.isLatex, this.text);

  String get cleanText {
    String original = text.toString();
    final RegExp imgRegex = RegExp(r'''<img[^>]+src=["'\\]+([^"'\\>\s]+)["'\\]+[^>]*>''');
    return original.replaceAllMapped(imgRegex, (match) {
      String fullMatch = match.group(0)!;
      String src = match.group(1)!;
      String newSrc = EnvironmentConfig.resolveImageUrl(src);
      
      String fixedTag = fullMatch.replaceFirst(src, newSrc);
      if (!fixedTag.contains('style=')) {
         fixedTag = fixedTag.replaceFirst('<img', '<img style="max-width: 100%; max-height: 250px; object-fit: contain; margin: 0 auto; display: block; border-radius: 8px;"');
      }
      return fixedTag;
    });
  }

  factory LatexField.fromMap(Map<String, dynamic> map) {
    try {
      return LatexField(
        map['is_latex'] as bool,
        map['value'] as T,
      );
    } catch (e) {
      log('value:${map['value']}');
      // return LatexField(false, map['value']);
      rethrow;
    }
  }
}
