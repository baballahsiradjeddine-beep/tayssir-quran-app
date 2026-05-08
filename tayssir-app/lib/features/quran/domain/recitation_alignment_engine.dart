import 'dart:math';

enum WordStatus { pending, current, correct, incorrect, partial }

class RecitationAlignmentEngine {
  static const double _correctThreshold = 0.70;

  static List<WordStatus> alignPage({
    required String spokenText,
    required List<String> targetWords,
  }) {
    List<WordStatus> statuses = List.filled(targetWords.length, WordStatus.pending);
    if (spokenText.isEmpty) {
      if (statuses.isNotEmpty) statuses[0] = WordStatus.current;
      return statuses;
    }

    final spokenWords = spokenText.split(' ').where((w) => w.trim().isNotEmpty).toList();
    
    int targetIdx = 0;
    
    for (int spokenIdx = 0; spokenIdx < spokenWords.length; spokenIdx++) {
      String sWord = spokenWords[spokenIdx];
      if (targetIdx >= targetWords.length) break;

      bool foundMatch = false;
      int matchIdx = -1;
      
      // Look ahead up to 3 words to find a match (allowing 2 skipped words max)
      for (int lookAhead = 0; lookAhead < 3; lookAhead++) {
        if (targetIdx + lookAhead >= targetWords.length) break;
        
        String tWord = targetWords[targetIdx + lookAhead];
        if (wordSimilarity(sWord, tWord) >= _correctThreshold) {
          foundMatch = true;
          matchIdx = targetIdx + lookAhead;
          break;
        }
      }

      if (foundMatch) {
        // Mark skipped words as incorrect
        for (int i = targetIdx; i < matchIdx; i++) {
          statuses[i] = WordStatus.incorrect;
        }
        // Mark matched word as correct
        statuses[matchIdx] = WordStatus.correct;
        targetIdx = matchIdx + 1; // Move pointer past the match
      }
    }

    // After processing all spoken words, mark the NEXT target word as 'current'
    if (targetIdx < targetWords.length) {
      statuses[targetIdx] = WordStatus.current;
    }

    return statuses;
  }

  static double wordSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int distance = levenshtein(s1, s2);
    int maxLength = max(s1.length, s2.length);
    return 1.0 - (distance / maxLength);
  }

  static int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }
}
