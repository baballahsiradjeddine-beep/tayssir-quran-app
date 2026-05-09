import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:tayssir/features/quran/domain/recitation_alignment_engine.dart';
import 'package:tayssir/utils/arabic_utils.dart';

/// A developer tool to test the recitation alignment engine without voice input.
class EngineTester {
  
  static void testBaqarah() {
    print("--- STARTING ALIGNMENT TEST (Baqarah Page 1) ---");

    final List<String> targetWords = [
      "الف", "لام", "ميم", // الم
      "ذلك", "الكتاب", "لا", "ريب", "فيه", "هدى", "للمتقين" // Verse 2
    ];

    final List<WordStatus> initialStatuses = List.filled(targetWords.length, WordStatus.pending);
    initialStatuses[0] = WordStatus.current;

    // Test Case 1: Perfect partial recitation
    print("\nCase 1: Perfect partial ('Alif Lam Mim Dhalika')");
    final spoken1 = ["الف", "لام", "ميم", "ذلك"];
    final result1 = RecitationAlignmentEngine.alignPage(
      spokenWords: spoken1,
      targetWords: targetWords,
      currentStatuses: List.from(initialStatuses),
    );
    _printResults(targetWords, result1);

    // Test Case 2: User skips 'Al-Kitab' but says 'Huda'
    print("\nCase 2: Skip 'Al-Kitab' ('Alif Lam Mim Dhalika Huda')");
    final spoken2 = ["الف", "لام", "ميم", "ذلك", "هدى"];
    final result2 = RecitationAlignmentEngine.alignPage(
      spokenWords: spoken2,
      targetWords: targetWords,
      currentStatuses: List.from(initialStatuses),
    );
    _printResults(targetWords, result2);
    
    // Test Case 3: Messy STT (Phonetic variations)
    print("\nCase 3: Messy STT ('الف لام ميم زلك الكتاب')");
    final spoken3 = ["الف", "لام", "ميم", "زلك", "الكتاب"];
    final result3 = RecitationAlignmentEngine.alignPage(
      spokenWords: spoken3,
      targetWords: targetWords,
      currentStatuses: List.from(initialStatuses),
    );
    _printResults(targetWords, result3);
  }

  static void _printResults(List<String> target, List<WordStatus> results) {
    String output = "";
    for (int i = 0; i < target.length; i++) {
      String status = results[i].name;
      output += "${target[i]}($status) ";
    }
    print(output);
  }
}
