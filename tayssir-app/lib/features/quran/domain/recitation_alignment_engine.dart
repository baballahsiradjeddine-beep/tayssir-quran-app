import 'dart:math' as math;
import '../../../utils/arabic_utils.dart';

enum WordStatus { pending, current, correct, incorrect, partial }

class RecitationAlignmentEngine {
  // Cache for performance optimization
  static final Map<String, double> _similarityCache = {};

  // Anchor Words to prevent 'Drift' (re-sync points)
  static const Set<String> _anchors = {
    'الله', 'الرحمن', 'الرحيم', 'قال', 'قل', 'يا', 'ايها', 'الذين', 'امنوا', 'رب', 'العالمين',
    'ذلك', 'هدى', 'الكتاب', 'الذي', 'انزل', 'ناس', 'نعبد', 'نستعين'
  };

  static List<WordStatus> alignPage({
    required List<String> spokenWords,
    required List<String> targetWords,
    required List<WordStatus> currentStatuses,
  }) {
    if (spokenWords.isEmpty) return currentStatuses;

    // ══════════════════════════════════════════════════════════════════════
    // SLIDING WINDOW DP ALIGNMENT
    // ══════════════════════════════════════════════════════════════════════
    
    // Find our current "Window of Interest" centered on LAST CORRECT word
    // (not first pending/incorrect, which could be a stale error from earlier in the page)
    int lastCorrectForWindow = currentStatuses.lastIndexWhere((s) => s == WordStatus.correct);
    int currentIdx = (lastCorrectForWindow >= 0) ? lastCorrectForWindow + 1 : 0;
    if (currentIdx >= currentStatuses.length) currentIdx = currentStatuses.length - 1;

    // Window: Start 5 words before current position, end 20 words after
    int windowStart = math.max(0, currentIdx - 5);
    int windowEnd = math.min(targetWords.length, currentIdx + 20);
    List<String> windowTarget = targetWords.sublist(windowStart, windowEnd);

    int n = spokenWords.length;
    int m = windowTarget.length;

    // scoreMatrix[i][j] for window alignment
    List<List<double>> scoreMatrix = List.generate(n + 1, (_) => List.filled(m + 1, 0.0));
    
    const double gapPenalty = -0.5;
    const double mismatchPenalty = -1.0;

    // STRICT FORWARD LOGIC: 
    // Find where the user actually is (last correct word)
    int lastCorrectIdx = -1;
    for (int k = currentStatuses.length - 1; k >= 0; k--) {
      if (currentStatuses[k] == WordStatus.correct) {
        lastCorrectIdx = k;
        break;
      }
    }
    
    int relativeLastCorrect = lastCorrectIdx - windowStart;
    
    // STRICT SEQUENTIAL MODE:
    // If there is an incorrect (red) word after the last correct word,
    // collapse the window to ONLY that word. The user MUST fix it before advancing.
    int firstErrorIdx = -1;
    for (int k = lastCorrectIdx + 1; k < currentStatuses.length; k++) {
      if (currentStatuses[k] == WordStatus.incorrect) {
        firstErrorIdx = k;
        break;
      }
    }

    int maxAllowedJ;
    if (firstErrorIdx >= 0) {
      // Strict: only allow matching up to and including the error word
      int relativeError = firstErrorIdx - windowStart;
      maxAllowedJ = (relativeError >= 0 && relativeError < m) 
          ? relativeError + 1  // +1 so the user CAN fix this exact word
          : (relativeLastCorrect < 0 ? m : math.min(m, relativeLastCorrect + 4));
    } else {
      // No error: allow normal 4-word forward reading
      maxAllowedJ = (relativeLastCorrect < 0) 
          ? m  
          : math.min(m, relativeLastCorrect + 4);
    }

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        double sim = wordSimilarity(spokenWords[i - 1], windowTarget[j - 1]);
        double threshold = _getThreshold(windowTarget[j - 1]);
        
        // Disable matching if j is beyond our strict forward limit
        double matchScore;
        if (j > maxAllowedJ) {
          matchScore = mismatchPenalty * 2;
        } else {
          matchScore = (sim >= threshold) ? (sim * 2.0) : mismatchPenalty;
        }

        scoreMatrix[i][j] = [
          scoreMatrix[i - 1][j - 1] + matchScore,
          scoreMatrix[i - 1][j] + gapPenalty,
          scoreMatrix[i][j - 1] + gapPenalty,
        ].reduce(math.max);
      }
    }

    // 3. BACKTRACK: Start from the best matching end-point in the target window
    // EARLIEST MATCH PRIORITY: Among positions with similar scores, prefer the 
    // earliest (lowest j) to avoid matching duplicate words to later occurrences.
    int bestJ = 0;
    double maxScore = -double.infinity;
    // First pass: find the maximum score
    for (int j_ptr = 0; j_ptr <= m; j_ptr++) {
      if (scoreMatrix[n][j_ptr] > maxScore) {
        maxScore = scoreMatrix[n][j_ptr];
      }
    }
    // Second pass: pick the EARLIEST j that is within epsilon of the max score
    // AND is within the allowed forward range from the last correct word
    const double scoreTolerance = 0.5; // within 0.5 points of maximum is "good enough"
    for (int j_ptr = 0; j_ptr <= m; j_ptr++) {
      if (scoreMatrix[n][j_ptr] >= maxScore - scoreTolerance) {
        bestJ = j_ptr;
        break; // take the first (earliest) good match
      }
    }
    // If no match found with tolerance, fall back to the absolute maximum
    if (bestJ == 0 && maxScore > 0) {
      for (int j_ptr = 0; j_ptr <= m; j_ptr++) {
        if (scoreMatrix[n][j_ptr] == maxScore) {
          bestJ = j_ptr;
          break;
        }
      }
    }

    List<WordStatus> windowStatuses = List.filled(m, WordStatus.pending);
    int i = n;
    int j = bestJ;
    const double epsilon = 0.0001;
    
    int lastMatchedI = -1;
    
    // Everything after bestJ is definitely pending
    for (int k = bestJ; k < m; k++) windowStatuses[k] = WordStatus.pending;

    int consecutiveSkips = 0;
    while (i > 0 && j > 0) {
      double sim = wordSimilarity(spokenWords[i - 1], windowTarget[j - 1]);
      double currentScore = scoreMatrix[i][j];
      double threshold = _getThreshold(windowTarget[j - 1]);
      double matchScore = (sim >= threshold) ? (sim * 2.0) : mismatchPenalty;
      double diagonal = scoreMatrix[i - 1][j - 1];
      double up = scoreMatrix[i - 1][j];

      if ((currentScore - (diagonal + matchScore)).abs() < epsilon) {
        windowStatuses[j - 1] = WordStatus.correct;
        if (i > lastMatchedI) lastMatchedI = i;
        consecutiveSkips = 0; // Reset skips on match
        i--;
        j--;
      } else if ((currentScore - (up + gapPenalty)).abs() < epsilon) {
        i--; // Skip extra spoken word
      } else {
        // Gap in spoken (Skip in target)
        windowStatuses[j - 1] = WordStatus.incorrect;
        consecutiveSkips++;
        j--;
      }
    }

    // Remaining words at the very beginning of the window are pending
    while (j > 0) {
      windowStatuses[j - 1] = WordStatus.pending;
      j--;
    }

    // --- GAP ENFORCEMENT (Strict Sequential Mode) ---
    // If a gap (skipped target word) was detected, AND there is a correct word 
    // AFTER the gap, reset those post-gap correct words to 'pending'.
    // (If no correct word follows the gap, it's just the reading boundary — no action.)
    int firstGapInWindow = -1;
    for (int k = 0; k < m; k++) {
      if (windowStatuses[k] == WordStatus.incorrect) {
        firstGapInWindow = k;
        break;
      }
    }
    if (firstGapInWindow >= 0) {
      bool hasCorrectAfterGap = false;
      for (int k = firstGapInWindow + 1; k < m; k++) {
        if (windowStatuses[k] == WordStatus.correct) {
          hasCorrectAfterGap = true;
          break;
        }
      }
      if (hasCorrectAfterGap) {
        // Real skip detected: pull back post-gap correct words to pending
        for (int k = firstGapInWindow + 1; k < m; k++) {
          if (windowStatuses[k] == WordStatus.correct) {
            windowStatuses[k] = WordStatus.pending;
          }
        }
      }
    }

    // --- PEDAGOGICAL FORCE (Patient Mode) ---
    // Only force red hint if the user said something NEW that was NOT matched.
    if (n > 0 && lastMatchedI < n && bestJ <= relativeLastCorrect + 1) {
      // REPETITION CHECK: If the unmatched spoken words are actually repetitions
      // of words we already marked correct, don't punish the user.
      bool isRepetition = false;
      for (int i = lastMatchedI; i < n; i++) {
        for (int j = 0; j <= relativeLastCorrect; j++) {
           if (wordSimilarity(spokenWords[i], windowTarget[j]) >= _getThreshold(windowTarget[j])) {
             isRepetition = true;
             break;
           }
        }
        if (isRepetition) break;
      }

      if (!isRepetition) {
        int hintIdx = relativeLastCorrect + 1;
        if (hintIdx >= 0 && hintIdx < m && windowStatuses[hintIdx] == WordStatus.pending) {
          windowStatuses[hintIdx] = WordStatus.incorrect;
        }
      }
    }

    // --- SMART HINT POST-PROCESSING ---
    // If we have a large gap of incorrect words, only keep the FIRST one 
    // (the one at the lowest index) as red, and hide the rest.
    int k = 0;
    while (k < m) {
      if (windowStatuses[k] == WordStatus.incorrect) {
        int blockStart = k;
        while (k < m && windowStatuses[k] == WordStatus.incorrect) {
          k++;
        }
        int blockEnd = k;
        int blockSize = blockEnd - blockStart;
        
        if (blockSize > 2) {
          // Keep only the first 2 words as a hint, hide the rest
          for (int hideIdx = blockStart + 2; hideIdx < blockEnd; hideIdx++) {
            windowStatuses[hideIdx] = WordStatus.pending;
          }
        }
      } else {
        k++;
      }
    }

    // Merge window results back into full page statuses
    List<WordStatus> finalStatuses = List.from(currentStatuses);
    for (int k = 0; k < m; k++) {
      finalStatuses[windowStart + k] = windowStatuses[k];
    }

    // Refine: Next word logic
    int lastCorrect = finalStatuses.lastIndexOf(WordStatus.correct);
    if (lastCorrect + 1 < finalStatuses.length && finalStatuses[lastCorrect + 1] == WordStatus.pending) {
      finalStatuses[lastCorrect + 1] = WordStatus.current;
    } else if (lastCorrect == -1 && finalStatuses.isNotEmpty) {
      finalStatuses[0] = WordStatus.current;
    }

    return finalStatuses;
  }

  static double _getThreshold(String word) {
    String n = ArabicUtils.normalize(word);
    if (_anchors.contains(n)) return 0.85; // Anchors always strict
    if (word.length <= 2) return 0.90;     // Very short: هم، في، من — must be exact
    if (word.length <= 4) return 0.75;     // Short: بما، قال
    return 0.75;                            // Medium & Long words: الصلوة، يقيمون، المفلحون
  }

  static double wordSimilarity(String w1, String w2) {
    if (w1 == w2) return 1.0;
    if (w1.isEmpty || w2.isEmpty) return 0.0;

    // Cache key: combined words
    final String cacheKey = "${w1}|${w2}";
    if (_similarityCache.containsKey(cacheKey)) {
      return _similarityCache[cacheKey]!;
    }

    final double result = _calculateSimilarity(w1, w2);
    
    _evictCache();
    _similarityCache[cacheKey] = result;
    
    return result;
  }

  static void _evictCache() {
    if (_similarityCache.length <= 500) return;
    // Remove oldest 250 entries (Dart Map maintains insertion order)
    final keysToRemove = _similarityCache.keys.take(250).toList();
    for (final key in keysToRemove) {
      _similarityCache.remove(key);
    }
  }

  static double _calculateSimilarity(String w1, String w2) {
    String n1 = ArabicUtils.normalize(w1);
    String n2 = ArabicUtils.normalize(w2);

    double literalSim = _levenshteinSimilarity(n1, n2);
    double threshold = _getThreshold(w2);
    
    // Tier 1: Literal Match (High weight)
    if (literalSim >= threshold) return literalSim;

    // Tier 2: Phonetic Match (Lower weight fallback)
    String p1 = ArabicUtils.phoneticNormalize(w1);
    String p2 = ArabicUtils.phoneticNormalize(w2);
    double phoneticSim = _levenshteinSimilarity(p1, p2);
    
    if (phoneticSim >= 0.95) {
      // Expert's refined return: ensure literal isn't garbage
      return literalSim > 0.4 ? 0.90 : 0.80;
    }
    
    if (phoneticSim >= 0.80) return 0.75;

    return math.max(literalSim, phoneticSim * 0.7);
  }

  static double _levenshteinSimilarity(String s1, String s2) {
    int distance = levenshtein(s1, s2);
    int maxLength = math.max(s1.length, s2.length);
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
        v1[j + 1] = math.min(v1[j] + 1, math.min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }
}
