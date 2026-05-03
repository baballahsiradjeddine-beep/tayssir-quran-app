import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/providers/data/content_data.dart';
import 'package:tayssir/providers/data/data_state.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/providers/data/models/material_model.dart';

import '../../features/exercice/presentation/state/exercise_state.dart';
import '../../services/course_service.dart';
import 'package:tayssir/providers/data/models/unit_model.dart';
import 'package:tayssir/providers/data/models/chapter_model.dart';
import 'package:tayssir/providers/data/models/exercise_model.dart';
import 'package:tayssir/providers/data/submission_progress_response.dart';
import 'package:tayssir/providers/data/progress_model.dart';
import 'package:tayssir/common/data/configs.dart';

final dataProvider = StateNotifierProvider<DataController, DataState>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  final controller = DataController(dataService, ref);

  // For guests: re-fetch whenever they select a division during onboarding
  ref.listen<int?>(onboardingProvider.select((s) => s.divisionId), (prev, next) {
    if (next != null && next != prev) {
      controller.getData();
    }
  });

  return controller;
});


class SubmissionExerciceModel {
  final int points;
  final int bonusPoints;
  final double bestProgress;

  SubmissionExerciceModel({
    required this.points,
    required this.bonusPoints,
    required this.bestProgress,
  });

  int get totalPoints {
    return points + bonusPoints;
  }
}

class DataController extends StateNotifier<DataState> {
  final DataService dataService;
  final Ref ref;
  DataController(this.dataService, this.ref) : super(const DataState()) {
    _init();
  }

  void _init() {
    // On init, check the current user state:
    // - If user already has a division (e.g. app resumed), fetch immediately.
    // - If user is empty/null (first load), the ref.listen in dataProvider will trigger getData()
    //   as soon as userNotifier receives real data.
    // - If user is loading, also wait for the listener.
    Future.microtask(() {
      if (!mounted) return;
      final user = ref.read(userNotifierProvider).valueOrNull;
      // User already loaded with division — fetch now
      if (user != null && !user.isEmpty && user.division != null) {
        getData();
      } else if (user == null) {
        // Confirmed guest — fetch mock data
        getData();
      }
      // Otherwise: user is empty (not yet fetched) — listener will call getData() when ready
    });
  }

  Future<void> refreshData() async {
    await getData();
  }

  /// Ensures mock/demo data is present without blanking the UI.
  /// Use this after tour completion instead of refreshData().
  void ensureMockData({bool force = false}) {
    final user = ref.read(userNotifierProvider).valueOrNull;
    if (user != null) return; // not a guest, don't touch

    final hasMock = state.contentData.modules.any((m) => m.id == -999);
    if (!hasMock || force) {
      dataService.clearData();
      _addMockData(dataService);
      state = state.copyWith(
        isLoading: false,
        contentData: ContentData(
          modules: List.from(dataService.modules),
          units: List.from(dataService.units),
          chapters: List.from(dataService.chapters),
          exercises: List.from(dataService.exercises),
        ),
      );
    }
  }

  void clearData() {
    print('🗑️ clearData() called from: ${StackTrace.current.toString().split('\n').take(3).join(' | ')}');
    state = const DataState();
    dataService.clearData();
  }

  Future<void> checkPendingReviews() async {
    try {
      final reviews = await dataService.getReviewQuestions();
      state = state.copyWith(pendingReviewsCount: reviews.length);
    } catch (e) {
      state = state.copyWith(pendingReviewsCount: 0);
    }
  }

  void debugTriggerReview() {
    state = state.copyWith(pendingReviewsCount: 5);
  }

  Future<void> getData() async {
    print('🚀 getData() called. Current modules: ${state.contentData.modules.length}');
    
    // Only show the loading spinner if we have no data at all
    if (state.contentData.modules.isEmpty) {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = ref.read(userNotifierProvider).valueOrNull;
      int? divisionId = user?.division?.id;
      if (divisionId == null || divisionId == 0) {
        divisionId = ref.read(onboardingProvider).divisionId;
      }

      if (divisionId == null && user == null) {
        // Guest with no division selected yet — skip API, mock data will be added below
        print('💡 Guest with no division — skipping API');
        dataService.clearData();
      } else {
        await dataService.getCourses(divisionId: divisionId)
            .timeout(const Duration(seconds: 60));
      }
      
      print('✅ getCourses done: modules=${dataService.modules.length}');
      
      // If we are a guest, always add the walkthrough material
      if (user == null) {
        // Ensure we don't duplicate if already added (though clearData above should prevent it)
        final alreadyHasMock = dataService.modules.any((m) => m.id == -999);
        if (!alreadyHasMock) {
          _addMockData(dataService);
        }
      }

      state = state.copyWith(
        isLoading: false,
        contentData: ContentData(
          modules: List.from(dataService.modules),
          units: List.from(dataService.units),
          chapters: List.from(dataService.chapters),
          exercises: List.from(dataService.exercises),
        ),
      );
      print('✅ State updated: modules=${state.contentData.modules.length}');
    } catch (e, st) {
      print('❌ getData ERROR: $e\n$st');
      // If it fails, provide a fallback material with hierarchy for guests
      final user = ref.read(userNotifierProvider).valueOrNull;
      if (user == null) {
        dataService.clearData();
        _addMockData(dataService);
        state = state.copyWith(
          isLoading: false,
          contentData: ContentData(
            modules: List.from(dataService.modules),
            units: List.from(dataService.units),
            chapters: List.from(dataService.chapters),
            exercises: List.from(dataService.exercises),
          ),
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void _addMockData(DataService dataService) {
    // Read the optional admin-configured Tour Images
    final config = ref.read(configsProvider).valueOrNull;

    final m = MaterialModel(
      id: -999,
      title: "جولة تعليمية 📖",
      description: "ابدأ بتجربة الأسئلة والمحاور الحقيقية هنا",
      gradiantColorStart: "#F59E0B", // gold500
      gradiantColorEnd: "#D97706",   // gold600
      imageList: config?.tourMaterialListImage.isNotEmpty == true 
          ? config!.tourMaterialListImage 
          : "assets/svg/tito_boarding.svg",
      imageGrid: config?.tourMaterialGridImage.isNotEmpty == true 
          ? config!.tourMaterialGridImage 
          : "assets/svg/tito_boarding.svg",
      isActive: true,
      progress: 0.0,
      direction: TextDirection.rtl,
    );

    final u = UnitModel(
      id: -999,
      materialId: -999,
      title: "المحور الأول: تجربة المنصة",
      progress: 0.0,
      direction: TextDirection.rtl,
      image: config?.tourUnitImage ?? "",
    );

    final c = ChapterModel(
      id: -999,
      unitId: -999,
      title: "الفصل الأول: أنماط الأسئلة التفاعلية",
      progress: 0.0,
      direction: TextDirection.rtl,
      image: config?.tourChapterImage,
    );

    // 1. Multiple Choice
    final ex1 = ExerciseModel.fromMap({
      "id": -999,
      "type": "multiple_choices",
      "chapter_id": -999,
      "points": 2,
      "scope": "lesson",
      "direction": "RTL",
      "question": {"value": "ما هو هدف تيسير الأساسي؟", "is_latex": false},
      "options": [
        {"value": "توفير الوقت والجهد", "is_latex": false},
        {"value": "صعوبة المذاكرة", "is_latex": false}
      ],
      "correctOptions": [0],
      "hint": [],
      "explanation_text": {"value": "تيسير صممت لجعل دراستك أسهل وأمتع!", "is_latex": false}
    });

    // 2. True or False
    final ex2 = ExerciseModel.fromMap({
      "id": -998,
      "type": "true_or_false",
      "chapter_id": -999,
      "points": 2,
      "scope": "lesson",
      "direction": "RTL",
      "question": {"value": "تطبيق تيسير يوفر ملخصات وفيديوهات لجميع المواد", "is_latex": false},
      "correctAnswer": true,
      "hint": [],
      "explanation_text": {"value": "نعم، تيسير هو رفيقك الشامل في البكالوريا", "is_latex": false}
    });

    // 3. Fill in the blanks
    final ex3 = ExerciseModel.fromMap({
      "id": -997,
      "type": "fill_in_the_blanks",
      "chapter_id": -999,
      "points": 2,
      "scope": "lesson",
      "direction": "RTL",
      "paragraph": "تطبيق تيسير يساعدك على [1] دروسك بـ [2] عالية",
      "blanks": [
        {"correct_word": "فهم", "position": 1},
        {"correct_word": "كفاءة", "position": 2}
      ],
      "suggestions": ["فهم", "كفاءة", "تضييع", "بطء"],
      "hint": [],
      "explanation_text": {"value": "هدفنا هو الفهم العميق والكفاءة العالية", "is_latex": false}
    });

    // 4. Pair two words (match_with_arrows)
    final ex4 = ExerciseModel.fromMap({
      "id": -996,
      "type": "match_with_arrows",
      "chapter_id": -999,
      "points": 2,
      "scope": "lesson",
      "direction": "RTL",
      "pairs": [
        {
          "first": {"value": "تيسير", "is_latex": false},
          "second": {"value": "التفوق", "is_latex": false}
        },
        {
          "first": {"value": "المذاكرة", "is_latex": false},
          "second": {"value": "الاجتهاد", "is_latex": false}
        }
      ],
      "hint": [],
      "explanation_text": {"value": "اربط كل كلمة بما يناسبها", "is_latex": false}
    });

    // 5. Pick the intruder (anomaly_word)
    final ex5 = ExerciseModel.fromMap({
      "id": -995,
      "type": "pick_the_intruder",
      "chapter_id": -999,
      "points": 2,
      "scope": "lesson",
      "direction": "RTL",
      "question": {"value": "اختر الكلمة الدخيلة", "is_latex": false},
      "words": [
        {"value": "نجاح", "is_latex": false},
        {"value": "تفوق", "is_latex": false},
        {"value": "رسوب", "is_latex": false}
      ],
      "correctAnomalies": [2],
      "hint": [],
      "explanation_text": {"value": "الرسوب هو الكلمة الدخيلة على النجاح والتفوق", "is_latex": false}
    });

    dataService.modules.add(m);
    dataService.units.add(u);
    dataService.chapters.add(c);
    dataService.exercises.addAll([ex1, ex2, ex3, ex4, ex5]);
  }

  Future<SubmissionExerciceModel> submitAnswers(
      List<SubmissionAnswer> answers, int chapterId, {int? totalSlides}) async {
    // If it's the mock chapter, return mock progress instead of calling API
    if (chapterId == -999) {
      final mockResponse = SubmissionProgressResponse(
        material: ProgressModel(id: -999, progress: 100, points: 0),
        unit: ProgressModel(id: -999, progress: 100, points: 0),
        chapter: ProgressModel(id: -999, progress: 100, points: totalSlides ?? 10, bonusPoints: 0),
      );
      state = state.updateAllProgress(mockResponse);
      return SubmissionExerciceModel(
        points: totalSlides ?? 10,
        bonusPoints: 0,
        bestProgress: 100.0,
      );
    }

    final progress = await dataService.submitAnswers(
      answers,
      chapterId,
      totalSlides: totalSlides,
    );
    state = state.updateAllProgress(progress);
    final response = SubmissionExerciceModel(
      points: progress.chapter.points,
      bonusPoints: progress.chapter.bonusPoints!,
      bestProgress: progress.chapter.progress,
    );
    return response;
  }

  int getChapterBonusPoints(int chapterId) {
    return state.getChapterBonusPoints(chapterId);
  }
}
