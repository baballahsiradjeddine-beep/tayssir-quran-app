import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/utils/arabic_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/features/quran/domain/recitation_alignment_engine.dart';

/// A buffer that handles unstable STT transcripts by extracting only the new/revised tokens.
class StreamingTranscriptBuffer {
  List<String> lastWords = [];

  /// Returns the full list of words if anything changed, otherwise returns null.
  List<String>? process(String transcript) {
    final normalized = ArabicUtils.normalize(transcript);
    final words = normalized
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    if (words.length == lastWords.length) {
      bool identical = true;
      for (int i = 0; i < words.length; i++) {
        if (words[i] != lastWords[i]) {
          identical = false;
          break;
        }
      }
      if (identical) return null;
    }

    lastWords = words;
    return words;
  }
}

class MushafScreen extends ConsumerStatefulWidget {
  const MushafScreen({super.key});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final StreamingTranscriptBuffer _transcriptBuffer = StreamingTranscriptBuffer();
  DateTime _lastErrorSoundTime = DateTime.now().subtract(const Duration(seconds: 3));

  int _currentPage = 1;
  int _activeVerseIndex = -1;
  bool _isListening = false;
  bool _isCountingDown = false;
  bool _isSelectingVerse = false;
  int _countdownValue = 3;
  int _startVerseNumber = -1;
  int _sessionStartWordIdx = 0; // First tracking-word index of the chosen start verse

  // Word-by-Word tracking state for the entire page
  List<String> _pageWords = [];          // expanded (Muqatta'at split into letters)
  List<int> _pageWordVerseMapping = [];  // verse number for each tracking word
  List<WordStatus> _wordStatuses = [];
  List<bool> _isWordLocked = []; // Prevent revisions of confirmed words
  List<int> _displayWordTrackingStart = []; 
  String _currentSpeechSession = "";


  final Map<int, int> _errorConfirmationCounts = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncActiveVerseOnScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPageTracking(_currentPage);
      // Pre-load audio assets for zero-latency feedback
      _errorPlayer.setAsset('assets/sounds/error_soft.mp3').catchError((_) => null);
      _errorPlayer.setVolume(0.3);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  void _playErrorSound() async {
    // Throttle: don't play more than once every 3 seconds
    if (DateTime.now().difference(_lastErrorSoundTime).inSeconds < 3) return;
    _lastErrorSoundTime = DateTime.now();

    try {
      if (_errorPlayer.playing) await _errorPlayer.stop();
      await _errorPlayer.seek(Duration.zero);
      _errorPlayer.play();
    } catch (e) {
      debugPrint("Error playing error sound: $e");
    }
  }

  List<String> _lastSpokenWords = [];

  void _initPageTracking(int pageNum) {
    _pageWords.clear();
    _pageWordVerseMapping.clear();
    _displayWordTrackingStart.clear();
    _lastSpokenWords.clear();

    final pageData = quran.getPageData(pageNum);
    for (var surah in pageData) {
      final surahId = surah['surah'] as int;
      final start = surah['start'] as int;
      final end = surah['end'] as int;

      for (int v = start; v <= end; v++) {
        final rawVerse = quran.getVerse(surahId, v, verseEndSymbol: false);
        final targetText = ArabicUtils.normalize(rawVerse);
        final rawWords = targetText.split(' ').where((w) => w.trim().isNotEmpty).toList();
        for (var word in rawWords) {
          // Record the tracking start index for this DISPLAY word
          _displayWordTrackingStart.add(_pageWords.length);
          final expanded = ArabicUtils.expandMuqattaat(word);
          for (var expandedWord in expanded) {
            _pageWords.add(expandedWord);
            _pageWordVerseMapping.add(v);
          }
        }
      }
    }

    _wordStatuses = List.filled(_pageWords.length, WordStatus.pending);
    _isWordLocked = List.filled(_pageWords.length, false);
    _errorConfirmationCounts.clear();
    _transcriptBuffer.lastWords = [];
    if (_wordStatuses.isNotEmpty) _wordStatuses[0] = WordStatus.current;

    setState(() {});
  }

  void _syncActiveVerseOnScroll() {
    if (!_isListening && _scrollController.hasClients) {
      final newIndex = (_scrollController.offset / 100.h).floor() + 1;
      if (newIndex != _activeVerseIndex && newIndex > 0) {
        setState(() => _activeVerseIndex = newIndex);
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!_isListening && !_isCountingDown && !_isSelectingVerse) {
      // Step 1: Enter selection mode
      setState(() => _isSelectingVerse = true);
    } else if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else if (_isSelectingVerse) {
      // Cancel selection mode
      setState(() => _isSelectingVerse = false);
    }
  }

  /// Called when the user taps a verse marker directly on the Mushaf.
  Future<void> _onVerseTapped(int verseNum) async {
    if (!_isSelectingVerse) return;
    
    setState(() {
      _isSelectingVerse = false;
      _startVerseNumber = verseNum;
    });
    await _startCountdown();
  }


  Future<void> _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdownValue = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() => _isCountingDown = false);
    await _beginListening();
  }

  Future<void> _moveToNextPage() async {
    if (_currentPage >= 604) return;
    
    _speech.stop();
    setState(() => _isListening = false);

    await _pageController.animateToPage(
      _currentPage, 
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );

    // Start listening almost immediately
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _beginListening();
      }
    });
  }

  Future<void> _beginListening() async {
    bool available = false;
    const bool isWeb = bool.fromEnvironment('dart.library.js_util');

    if (!isWeb) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.speech,
      ].request();

      if (statuses[Permission.microphone]!.isGranted &&
          statuses[Permission.speech]!.isGranted) {
        available = await _speech.initialize(
          onStatus: (status) => debugPrint("Speech Status: $status"),
          onError: (errorNotification) => debugPrint("Speech Error: ${errorNotification.errorMsg}"),
        );
      }
    } else {
      available = await _speech.initialize(
        onStatus: (status) => debugPrint("Web Speech Status: $status"),
        onError: (errorNotification) => debugPrint("Web Speech Error: ${errorNotification.errorMsg}"),
      );
    }

    if (available && mounted) {
      _initPageTracking(_currentPage);
      // Jump to selected verse if user picked one
      if (_startVerseNumber > 0) {
        _seekToVerse(_startVerseNumber);
      }
      setState(() {
        _isListening = true;
        _activeVerseIndex = _startVerseNumber > 0
            ? _startVerseNumber
            : quran.getPageData(_currentPage).first['start'];
      });

      _speech.listen(
        onResult: (val) => _analyzeSpeech(val.recognizedWords, val.finalResult),
        localeId: 'ar-SA',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      );
    }
  }

  /// Fast-forward tracking state to begin at a specific verse number.
  void _seekToVerse(int verseNum) {
    bool foundVerseStart = false;
    _sessionStartWordIdx = 0; // Reset to beginning by default
    for (int i = 0; i < _pageWords.length; i++) {
      final v = _pageWordVerseMapping[i];
      if (v < verseNum) {
        _wordStatuses[i] = WordStatus.correct;
        _isWordLocked[i] = true;
      } else if (v == verseNum && !foundVerseStart) {
        _sessionStartWordIdx = i; // Remember where session starts
        _wordStatuses[i] = WordStatus.current;
        foundVerseStart = true;
      } else if (v == verseNum) {
        _wordStatuses[i] = WordStatus.pending;
      } else {
        break;
      }
    }
  }


  void _analyzeSpeech(String text, bool isFinal) {
    if (text.isEmpty || _pageWords.isEmpty || !_isListening) return;
    
    // 1. Get the current FULL transcript from the buffer
    final allWords = _transcriptBuffer.process(text);
    if (allWords == null) return; // Nothing changed

    // 2. WINDOWED DP ALIGNMENT
    final newStatuses = RecitationAlignmentEngine.alignPage(
      spokenWords: allWords,
      targetWords: _pageWords,
      currentStatuses: List.from(_wordStatuses),
    );

    // 4. Update UI State with Error Smoothing and LOCKING
    final List<WordStatus> smoothedStatuses = List.from(_wordStatuses);
    bool errorConfirmed = false;

    for (int i = 0; i < smoothedStatuses.length; i++) {
      // PRE-START IMMUNITY: Words before the session start point are ALWAYS correct.
      // _seekToVerse() set them — they must NEVER be changed by the engine or GAP logic.
      if (i < _sessionStartWordIdx && _isWordLocked[i] && _wordStatuses[i] == WordStatus.correct) {
        smoothedStatuses[i] = WordStatus.correct; // Permanently locked
        continue;
      }

      // SUCCESS PROTECTION: If locked as CORRECT, never let it turn RED.
      // BUT: allow it to turn PENDING if the engine detected a gap before it.
      if (_isWordLocked[i] && _wordStatuses[i] == WordStatus.correct) {
        if (newStatuses[i] == WordStatus.pending) {
          // Engine says this word is after a gap — pull it back to pending
          smoothedStatuses[i] = WordStatus.pending;
          _isWordLocked[i] = false;
          _errorConfirmationCounts.remove(i);
        }
        continue; // Never flip locked-correct to red (only to pending above)
      }

      if (newStatuses[i] == WordStatus.incorrect) {
        // If it was ALREADY CORRECT in this session, be suspicious of turning it red
        if (_wordStatuses[i] == WordStatus.correct) {
          continue; // Keep it green! STT revisions shouldn't break existing success.
        }

        _errorConfirmationCounts[i] = (_errorConfirmationCounts[i] ?? 0) + 1;
        
        // FLICKER FIX: Partial results need MORE confirmations before showing red.
        int requiredConfirmations = isFinal ? 2 : 4;
        
        if (_errorConfirmationCounts[i]! >= requiredConfirmations) {
          smoothedStatuses[i] = WordStatus.incorrect;
          if (_wordStatuses[i] != WordStatus.incorrect) errorConfirmed = true;
          if (isFinal && _errorConfirmationCounts[i]! >= 3) {
            _isWordLocked[i] = true;
          }
        }
      } else if (newStatuses[i] == WordStatus.correct) {
        smoothedStatuses[i] = WordStatus.correct;
        _errorConfirmationCounts.remove(i);
        _isWordLocked[i] = false; 
        if (isFinal) _isWordLocked[i] = true;
      } else if (newStatuses[i] == WordStatus.pending) {
        // Engine explicitly reset this to pending (gap before it)
        if (_wordStatuses[i] != WordStatus.correct || !_isWordLocked[i]) {
          smoothedStatuses[i] = WordStatus.pending;
          _errorConfirmationCounts.remove(i);
        }
      }
    }

    if (errorConfirmed) _playErrorSound();

    setState(() {
      _wordStatuses = smoothedStatuses;
      
      // Update targetIdx - FORWARD ONLY logic
      int targetIdx = _wordStatuses.indexWhere((s) => 
        s == WordStatus.current || s == WordStatus.pending || s == WordStatus.incorrect);
      
      if (targetIdx != -1) {
        int activeVerse = _pageWordVerseMapping[math.min(targetIdx, _pageWords.length - 1)];
        // Only move forward (unless it's a huge jump/reset)
        if (activeVerse > _activeVerseIndex || (activeVerse - _activeVerseIndex).abs() > 5) {
          _activeVerseIndex = activeVerse;
        }
      }
    });

    // 5. Automation: Move to next page if completed
    final bool isPageComplete = _wordStatuses.every((s) => s == WordStatus.correct);
    if (isPageComplete) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _isListening && _wordStatuses.every((s) => s == WordStatus.correct)) {
          _moveToNextPage();
        }
      });
    }
  }

  void _runAlignmentSimulation() {
    if (_pageWords.isEmpty) return;
    int count = (_pageWords.length * 0.7).floor();
    List<String> simulatedSpoken = _pageWords.sublist(0, count);
    final simulatedStatuses = RecitationAlignmentEngine.alignPage(
      spokenWords: simulatedSpoken,
      targetWords: _pageWords,
      currentStatuses: List.filled(_pageWords.length, WordStatus.pending),
    );
    setState(() {
      _wordStatuses = simulatedStatuses;
      _activeVerseIndex = _pageWordVerseMapping[math.min(count, _pageWords.length - 1)];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت محاكاة قراءة %70 من الصفحة (اختبار المحرك)'), backgroundColor: Colors.green),
    );
  }

  void _runAlignmentSimulationWithErrors() {
    if (_pageWords.isEmpty) return;
    
    // Create a version of the words where some are WRONG
    List<String> simulatedSpoken = List.from(_pageWords.sublist(0, math.min(15, _pageWords.length)));
    if (simulatedSpoken.length > 5) {
      simulatedSpoken[3] = "كلمة_خاطئة"; // Deliberate error
      simulatedSpoken[7] = "نطق_غير_صحيح"; // Another error
    }

    final simulatedStatuses = RecitationAlignmentEngine.alignPage(
      spokenWords: simulatedSpoken,
      targetWords: _pageWords,
      currentStatuses: List.filled(_pageWords.length, WordStatus.pending),
    );

    setState(() {
      _wordStatuses = simulatedStatuses;
      _activeVerseIndex = _pageWordVerseMapping[0];
    });

    _playErrorSound(); // Trigger the actual error sound logic
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تمت المحاكاة: لاحظ تلوين الأخطاء باللون الأحمر!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A202C);
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final user = ref.watch(userNotifierProvider).valueOrNull;
    final String narration = user?.division?.name ?? "حفص";

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? (constraints.maxWidth - 850) / 2 : 0;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? bgColor : Colors.white,
            elevation: 1,
            toolbarHeight: isDesktop ? 80.h : 60.h,
            centerTitle: true,
            leadingWidth: isDesktop ? 100.w : 70.w,
            leading: IconButton(
              icon: Icon(Icons.format_list_bulleted_rounded, color: AppColors.goldColor, size: isDesktop ? 28.sp : 24.sp),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              tooltip: 'القائمة',
            ),
            title: Text(
              quran.getSurahNameArabic(quran.getPageData(_currentPage).first['surah']),
              style: TextStyle(
                fontFamily: 'SomarSans', 
                fontSize: isDesktop ? 32.sp : 22.sp, 
                fontWeight: FontWeight.w900, 
                color: textColor
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30.w : 20.w),
                child: Container(
                  decoration: _isListening ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.goldColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
                    ]
                  ) : null,
                  child: IconButton(
                    onPressed: _toggleListening,
                    icon: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: AppColors.goldColor,
                      size: isDesktop ? 30.sp : 26.sp,
                    ).animate(target: _isListening ? 1 : 0).scaleXY(end: 1.1).shake(hz: 2, curve: Curves.easeInOutCubic),
                  ),
                ),
              ),
            ],
          ),
          drawer: _buildDrawer(isDark, textColor, bgColor, narration),
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: 604,
                reverse: true,
                physics: (_isListening || _isCountingDown) ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                onPageChanged: (p) {
                  setState(() {
                    _currentPage = p + 1;
                    _startVerseNumber = -1;
                    _activeVerseIndex = -1;
                    _initPageTracking(_currentPage);
                  });

                  if (_isListening) {
                     _speech.stop();
                     Future.delayed(const Duration(milliseconds: 100), () {
                       if (mounted && _isListening) {
                         _speech.listen(
                           onResult: (val) => _analyzeSpeech(val.recognizedWords, val.finalResult),
                           localeId: 'ar-SA',
                           listenMode: stt.ListenMode.dictation,
                           partialResults: true,
                         );
                       }
                     });
                  }
                },
                itemBuilder: (context, index) => _buildResponsivePage(index + 1, textColor, bgColor, isDesktop),
              ),
              // ── Verse Selection Banner ────────────────────────────────────
              if (_isSelectingVerse)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: SafeArea(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.goldColor.withOpacity(0.5)),
                        boxShadow: [BoxShadow(color: AppColors.goldColor.withOpacity(0.12), blurRadius: 20)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_rounded, color: AppColors.goldColor, size: 22.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'انقر على رقم الآية التي تريد البدء منها',
                              style: TextStyle(
                                fontFamily: 'SomarSans',
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => setState(() => _isSelectingVerse = false),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('إلغاء',
                                style: TextStyle(
                                  fontFamily: 'SomarSans',
                                  fontSize: 13.sp,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // ── Countdown Overlay ─────────────────────────────────────────
              if (_isCountingDown)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        color: const Color(0xFF0A0F1E).withOpacity(0.85),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Islamic decorative dot
                            Text('❁', style: TextStyle(fontSize: 28.sp, color: AppColors.goldColor.withOpacity(0.6))),
                            SizedBox(height: 16.h),
                            // Religious text
                            Text(
                              'بِسْمِ اللهِ نَبْدَأُ',
                              style: TextStyle(
                                fontFamily: 'UthmanicHafs',
                                fontSize: isDesktop ? 32.sp : 26.sp,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 1,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'تَوَكَّلْ عَلَى اللهِ',
                              style: TextStyle(
                                fontFamily: 'UthmanicHafs',
                                fontSize: isDesktop ? 22.sp : 18.sp,
                                color: AppColors.goldColor.withOpacity(0.8),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: 48.h),
                            // Countdown circle
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) => ScaleTransition(
                                scale: anim,
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: Container(
                                key: ValueKey(_countdownValue),
                                width: isDesktop ? 120.w : 90.w,
                                height: isDesktop ? 120.w : 90.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.goldColor, width: 3),
                                  gradient: RadialGradient(colors: [
                                    AppColors.goldColor.withOpacity(0.15),
                                    Colors.transparent,
                                  ]),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldColor.withOpacity(0.35),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$_countdownValue',
                                  style: TextStyle(
                                    fontFamily: 'SomarSans',
                                    fontSize: isDesktop ? 56.sp : 44.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.goldColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Text(
                              'استعد للقراءة...',
                              style: TextStyle(
                                fontFamily: 'SomarSans',
                                fontSize: 14.sp,
                                color: Colors.white38,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildResponsivePage(int pageNum, Color textColor, Color bgColor, bool isDesktop) {
    return Container(
      color: bgColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 850 : double.infinity),
          child: _buildTextPage(pageNum, textColor, isDesktop),
        ),
      ),
    );
  }

  Widget _buildTextPage(int pageNum, Color textColor, bool isDesktop) {
    final pageData = quran.getPageData(pageNum);
    final bool isSpecialPage = pageNum <= 2;

    int globalWordCounter = 0;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
      child: Column(
        children: [
          for (var surah in pageData) ...[
            if (surah['start'] == 1) _buildSurahHeader(surah['surah'], isDesktop),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Builder(builder: (context) {
                // Build per-verse widgets for tap-selection support
                final List<Widget> verseWidgets = [];

                for (int i = 0; i < (surah['end'] as int) - (surah['start'] as int) + 1; i++) {
                  final verseNum = (surah['start'] as int) + i;
                  final rawVerse = quran.getVerse(surah['surah'], verseNum, verseEndSymbol: false);
                  final normalizedWords = ArabicUtils.normalize(rawVerse)
                      .split(' ').where((w) => w.trim().isNotEmpty).toList();
                  final displayWords = rawVerse.split(' ')
                      .where((w) => w.trim().isNotEmpty).toList();
                  final wordCount = math.min(normalizedWords.length, displayWords.length);

                  bool hasErrorInVerse = false;
                  bool isVerseCompleted = true;
                  int verseDisplayStart = globalWordCounter;

                  for (int w = 0; w < wordCount; w++) {
                    int displayIdx = verseDisplayStart + w;
                    if (displayIdx >= _displayWordTrackingStart.length) break;
                    int trackingStart = _displayWordTrackingStart[displayIdx];
                    int trackingEnd = (displayIdx + 1 < _displayWordTrackingStart.length)
                        ? _displayWordTrackingStart[displayIdx + 1]
                        : _pageWords.length;
                    for (int t = trackingStart; t < trackingEnd; t++) {
                      if (t < _wordStatuses.length) {
                        if (_wordStatuses[t] == WordStatus.incorrect) hasErrorInVerse = true;
                        if (_wordStatuses[t] == WordStatus.pending || _wordStatuses[t] == WordStatus.current) isVerseCompleted = false;
                      }
                    }
                  }

                  int lastCorrectTrackingIdx = _wordStatuses.lastIndexWhere((s) => s == WordStatus.correct);
                  final List<Widget> wordWidgets = [];

                  for (int w = 0; w < wordCount; w++) {
                    Color wordColor = textColor;

                    if (globalWordCounter < _displayWordTrackingStart.length) {
                      int trackingStart = _displayWordTrackingStart[globalWordCounter];
                      int trackingEnd = (globalWordCounter + 1 < _displayWordTrackingStart.length)
                          ? _displayWordTrackingStart[globalWordCounter + 1]
                          : _pageWords.length;

                      WordStatus worstStatus = _computeDisplayStatus(trackingStart, trackingEnd);

                      bool isLastCorrect = (trackingEnd - 1 == lastCorrectTrackingIdx || (lastCorrectTrackingIdx >= trackingStart && lastCorrectTrackingIdx < trackingEnd)) 
                          && worstStatus == WordStatus.correct;

                      if (_isListening) {
                        switch (worstStatus) {
                          case WordStatus.correct:
                            wordColor = isLastCorrect ? const Color(0xFF4ADE80) : textColor;
                            break;
                          case WordStatus.incorrect: 
                            wordColor = Colors.redAccent; 
                            break;
                          case WordStatus.partial:   
                            wordColor = Colors.orange; 
                            break;
                          case WordStatus.current:
                            // The next word to read must be VISIBLE (white), not hidden!
                            wordColor = textColor;
                            break;
                          case WordStatus.pending:
                            // Show in white if: before session start OR before reading position
                            wordColor = (trackingStart < _sessionStartWordIdx ||
                                         trackingStart <= lastCorrectTrackingIdx)
                                ? textColor
                                : Colors.transparent;
                            break;
                        }
                      } else if (verseNum == _activeVerseIndex) {
                        wordColor = AppColors.goldColor;
                      }
                    }

                    wordWidgets.add(GestureDetector(
                      onTap: () => _onVerseTapped(verseNum),
                      child: Text(
                        "${w < displayWords.length ? displayWords[w] : normalizedWords[w]} ",
                        style: TextStyle(
                          fontFamily: 'UthmanicHafs',
                          fontSize: isDesktop ? 38.sp : (isSpecialPage ? 28.sp : 22.sp),
                          height: isDesktop ? 1.9 : (isSpecialPage ? 2.3 : 2.0),
                          color: wordColor,
                        ),
                      ),
                    ));
                    globalWordCounter++;
                  }

                  final Color badgeColor = hasErrorInVerse && _isListening
                      ? Colors.redAccent
                      : isVerseCompleted && _isListening ? Colors.green : AppColors.goldColor;

                  wordWidgets.add(GestureDetector(
                    onTap: () => _onVerseTapped(verseNum),
                    child: _buildAyahMarker(
                      verseNum, badgeColor, isDesktop,
                      onTap: () => _onVerseTapped(verseNum),
                    ),
                  ));

                  verseWidgets.add(Wrap(
                    textDirection: TextDirection.rtl,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: wordWidgets,
                  ));
                }

                // Always flat Wrap — normal Mushaf text flow
                final List<Widget> flatItems = [];
                for (final vw in verseWidgets) flatItems.addAll((vw as Wrap).children);
                return Wrap(
                  textDirection: TextDirection.rtl,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: flatItems,
                );
              }).animate().fadeIn(duration: 500.ms),
            ),
            if (surah != pageData.last) SizedBox(height: 30.h),
          ],
        ],
      ),
    );
  }

  Widget _buildAyahMarker(int verseNum, Color color, bool isDesktop, {VoidCallback? onTap}) {
    final double size = isDesktop ? 52.w : 40.w;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        width: size,
        height: size,
        child: CustomPaint(
          painter: _AyahMarkerPainter(color: color),
          child: Center(
            child: Text(
              _toArabic(verseNum),
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: isDesktop ? 16.sp : 12.sp,
                color: color,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahHeader(int surahId, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Divider(color: AppColors.goldColor.withOpacity(0.2), thickness: 1.5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.goldColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.r),
              border: Border.all(color: AppColors.goldColor.withOpacity(0.2)),
            ),
            child: Text(
              "سورة ${quran.getSurahNameArabic(surahId)}", 
              style: TextStyle(
                fontFamily: 'SomarSans', 
                fontSize: isDesktop ? 22.sp : 18.sp, 
                color: AppColors.goldColor, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark, Color textColor, Color bgColor, String narration) {
    return Drawer(
      backgroundColor: bgColor,
      width: 320.w,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 60.h, bottom: 30.h, left: 24.w, right: 24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldColor.withOpacity(0.2), AppColors.goldColor.withOpacity(0.05)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("الرواية الحالية", style: TextStyle(fontFamily: 'SomarSans', fontSize: 13.sp, color: AppColors.goldColor, fontWeight: FontWeight.bold)),
                    Text(narration, style: TextStyle(fontFamily: 'SomarSans', fontSize: 22.sp, fontWeight: FontWeight.w900, color: textColor)),
                  ],
                ),
                Icon(Icons.menu_book_rounded, color: AppColors.goldColor, size: 32.sp),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.bug_report_rounded, color: AppColors.goldColor),
            title: Text("محاكاة القراءة (مثالية)", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'SomarSans')),
            onTap: () {
              Navigator.pop(context);
              _runAlignmentSimulation();
            },
          ),
          ListTile(
            leading: Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            title: Text("محاكاة القراءة (بها أخطاء)", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'SomarSans')),
            onTap: () {
              Navigator.pop(context);
              _runAlignmentSimulationWithErrors();
            },
          ),
          Divider(color: textColor.withOpacity(0.1)),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              itemCount: 114,
              separatorBuilder: (context, index) => Divider(height: 1, color: textColor.withOpacity(0.05)),
              itemBuilder: (context, index) {
                final sId = index + 1;
                final isCurrent = quran.getPageData(_currentPage).first['surah'] == sId;
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                  leading: CircleAvatar(
                    backgroundColor: isCurrent ? AppColors.goldColor : AppColors.goldColor.withOpacity(0.1),
                    child: Text(_toArabic(sId), style: TextStyle(color: isCurrent ? Colors.white : AppColors.goldColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ),
                  title: Text(quran.getSurahNameArabic(sId), style: TextStyle(color: textColor, fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold, fontSize: 16.sp)),
                  trailing: Text("صـ ${_toArabic(quran.getPageNumber(sId, 1))}", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13.sp)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentPage = quran.getPageNumber(sId, 1));
                    _pageController.jumpToPage(_currentPage - 1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _toArabic(int n) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String s = n.toString();
    for (int i = 0; i < 10; i++) s = s.replaceAll(english[i], arabic[i]);
    return s;
  }

  WordStatus _computeDisplayStatus(int trackingStart, int trackingEnd) {
    bool hasIncorrect = false;
    bool hasPendingOrCurrent = false;
    bool hasCorrect = false;

    for (int t = trackingStart; t < trackingEnd; t++) {
      if (t >= _wordStatuses.length) break;
      switch (_wordStatuses[t]) {
        case WordStatus.incorrect: hasIncorrect = true; break;
        case WordStatus.correct:   hasCorrect = true; break;
        case WordStatus.pending:
        case WordStatus.current:   hasPendingOrCurrent = true; break;
        default: break;
      }
    }

    bool isExpanded = (trackingEnd - trackingStart) > 1;
    if (isExpanded && hasIncorrect && hasCorrect) return WordStatus.partial;
    if (hasIncorrect) return WordStatus.incorrect;
    if (hasPendingOrCurrent) return WordStatus.pending;
    return WordStatus.correct;
  }
}

/// Paints the traditional ۝ (Arabic End of Ayah) ornamental marker shape.
/// Draws 8 decorative diamond petals around a central circle.
class _AyahMarkerPainter extends CustomPainter {
  final Color color;
  _AyahMarkerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Paint fillPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    final double innerR = r * 0.52;
    final double petalR = r * 0.22;

    // Draw 8 diamond petals
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final petalCenter = Offset(
        center.dx + (innerR + petalR * 0.5) * cos(angle),
        center.dy + (innerR + petalR * 0.5) * sin(angle),
      );
      canvas.drawCircle(petalCenter, petalR, fillPaint);
      canvas.drawCircle(petalCenter, petalR, paint);
    }

    // Draw inner circle
    canvas.drawCircle(center, innerR, fillPaint);
    canvas.drawCircle(center, innerR, paint);

    // Draw outer circle
    canvas.drawCircle(center, r * 0.95, paint..strokeWidth = 0.8);
  }

  double cos(double angle) => math.cos(angle);
  double sin(double angle) => math.sin(angle);

  @override
  bool shouldRepaint(_AyahMarkerPainter old) => old.color != color;
}
