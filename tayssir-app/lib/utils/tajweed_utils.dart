import 'package:tayssir/utils/arabic_utils.dart';

enum TajweedRule {
  ghunnah,    // نّ, مّ
  qalqalah,   // ق, ط, ب, ج, د with sukun
  madd,       // Prolongation
  none
}

class TajweedUtils {
  /// Identifies the Tajweed rule for a specific word based on characters and diacritics.
  static TajweedRule getRule(String word) {
    // 1. Ghunnah (Noon or Meem with Shadda)
    if (word.contains('\u0651')) { // Shadda
      if (word.contains('\u0646') || word.contains('\u0645')) {
        // More specifically, check if Shadda is ON Noon/Meem
        // This is a simplification; a full parser would be better.
        if (RegExp(r'[\u0646\u0645]\u0651').hasMatch(word)) {
          return TajweedRule.ghunnah;
        }
      }
    }

    // 2. Qalqalah (ق ط ب ج د with Sukun)
    // Note: Sukun is often omitted in Mushaf for some rules, but let's check for explicit Sukun \u0652
    if (RegExp(r'[قطبجد]\u0652').hasMatch(word)) {
      return TajweedRule.qalqalah;
    }
    
    // Qalqalah at end of word (implied sukun if user stops)
    if (RegExp(r'[قطبجد]$').hasMatch(ArabicUtils.normalize(word))) {
       // This would only apply if the user stops at the word.
    }

    // 3. Madd (Presence of Madd sign \u0653)
    if (word.contains('\u0653')) {
      return TajweedRule.madd;
    }

    return TajweedRule.none;
  }

  static String getRuleName(TajweedRule rule) {
    switch (rule) {
      case TajweedRule.ghunnah: return "غنة";
      case TajweedRule.qalqalah: return "قلقلة";
      case TajweedRule.madd: return "مد";
      case TajweedRule.none: return "";
    }
  }
}
