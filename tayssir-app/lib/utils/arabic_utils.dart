class ArabicUtils {
  static String normalize(String text) {
    String normalized = text;

    // ═══════════════════════════════════════════════════
    // 1. Remove standard diacritics (Tashkeel) U+064B-U+0652
    //    + U+0653 (maddah above ٓ — used on الٓمٓ in Quran package!)
    //    + U+0654 (hamza above) + superscript alef U+0670 + tatweel U+0640
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u0654\u0670\u0640]'), '');

    // ═══════════════════════════════════════════════════
    // 2. Remove extended Quranic annotation marks
    //    U+06D6-U+06DC: small signs (sajda, ruku...)
    //    U+06DF-U+06ED: more Quranic marks
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll(RegExp(r'[\u06D6-\u06DC\u06DF-\u06ED]'), '');

    // ═══════════════════════════════════════════════════
    // 3. Normalize ALL Alif variants → ا (U+0627)
    //    أ U+0623, إ U+0625, آ U+0622
    //    ٱ U+0671 (alef wasla — very common in Quran, e.g. ٱلْحَمْدُ)
    //    ٲ U+0672, ٳ U+0673, ٵ U+0675
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll(RegExp(r'[إأآٱ\u0671\u0672\u0673\u0675]'), 'ا');

    // ═══════════════════════════════════════════════════
    // 4. Normalize Ya variants → ي (U+064A)
    //    ى U+0649 alef maqsura
    //    ئ U+0626 ya with hamza (common in Quran)
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll(RegExp(r'[ىئ]'), 'ي');

    // ═══════════════════════════════════════════════════
    // 5. Normalize Te Marbuta → ه
    //    (STT reads it as haa sound)
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll('ة', 'ه');

    // ═══════════════════════════════════════════════════
    // 6. Normalize Hamza variants
    //    ؤ U+0624 → و
    //    ء U+0621 → removed (STT often drops standalone hamza)
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll('ؤ', 'و');
    normalized = normalized.replaceAll('ء', '');

    // ═══════════════════════════════════════════════════
    // 7. Normalize small Quranic letters (pronounced but STT won't transcribe separately)
    //    ۥ U+06E5 small waw → و
    //    ۦ U+06E6 small ya  → ي
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll('\u06E5', 'و');
    normalized = normalized.replaceAll('\u06E6', 'ي');

    // ═══════════════════════════════════════════════════
    // 8. Remove remaining Arabic non-letter marks
    //    (end of ayah marks U+06DD, sajda U+06DE, etc.)
    // ═══════════════════════════════════════════════════
    normalized = normalized.replaceAll(RegExp(r'[\u06D0-\u06D5\u06DD\u06DE\u06EE\u06EF]'), '');

    return normalized.trim();
  }

  static bool compareWords(String spoken, String original) {
    return normalize(spoken) == normalize(original);
  }

  /// Expands a Quranic Muqatta'at token into its spoken letter names.
  /// e.g. "الم" → ["الف", "لام", "ميم"]
  /// Regular words are returned as-is in a single-element list.
  static List<String> expandMuqattaat(String normalizedWord) {
    // Map from normalized written form → spoken letter names (also normalized)
    const Map<String, List<String>> muqattaatMap = {
      // 3+ letter combinations
      'الم':   ['الف', 'لام', 'ميم'],
      'المر':  ['الف', 'لام', 'ميم', 'راء'],
      'المص':  ['الف', 'لام', 'ميم', 'صاد'],
      'كهيعص': ['كاف', 'ها', 'يا', 'عين', 'صاد'],
      'حمعسق': ['حا', 'ميم', 'عين', 'سين', 'قاف'],
      // 2-letter combinations
      'الر':   ['الف', 'لام', 'راء'],
      'طسم':   ['طا', 'سين', 'ميم'],
      'حم':    ['حا', 'ميم'],
      'طه':    ['طا', 'ها'],
      'طس':    ['طا', 'سين'],
      'يس':    ['يا', 'سين'],
      'عسق':   ['عين', 'سين', 'قاف'],
      // Single letters
      'ص':     ['صاد'],
      'ق':     ['قاف'],
      'ن':     ['نون'],
    };

    // Direct lookup
    if (muqattaatMap.containsKey(normalizedWord)) {
      return muqattaatMap[normalizedWord]!;
    }

    // Fallback: strip any remaining non-Arabic-letter chars and retry
    final stripped = normalizedWord.replaceAll(RegExp(r'[^\u0600-\u06FF]'), '');
    if (stripped != normalizedWord && muqattaatMap.containsKey(stripped)) {
      return muqattaatMap[stripped]!;
    }

    return [normalizedWord];
  }
}
