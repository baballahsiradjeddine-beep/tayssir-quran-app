import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/features/home/data/data_response.dart';
import 'package:tayssir/features/home/data/image_precache_service.dart';
import 'package:tayssir/features/home/data/submit_answer_model.dart';
import 'package:tayssir/providers/data/submission_progress_response.dart';
import 'package:tayssir/utils/extensions/response.dart';

import '../../../providers/data/models/chapter_model.dart';
import '../../../providers/data/models/exercise_model.dart';
import '../../../providers/data/models/material_model.dart';
import '../../../providers/data/models/unit_model.dart';
import '../../exercice/presentation/state/exercise_state.dart';
import 'remote_courses_data_source.dart';

final dataRepoProvider = Provider<DataRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  // final localCoursesDataSource = ref.watch(localCoursesDataSourceProvider);
  return DataRepository(remoteDataSource
      // localCoursesDataSource: localCoursesDataSource
      );
});

class DataRepository {
  final RemoteCoursesDataSource _coursesDataSource;
  // final LocalCoursesDataSource _localCoursesDataSource;

  DataRepository(
    this._coursesDataSource,
    // this._localCoursesDataSource
  );

  Future<DataResponse> getCourses({int? divisionId}) async {
    try {
      print('DEBUG: Requesting courses for division ID: $divisionId');
      // await Future.delayed(const Duration(seconds: 50));
      final response = await _coursesDataSource.getCourses(divisionId: divisionId);
      final customData = response.data is Map ? response.data['data'] : null;
      print('📡 RAW API RESPONSE DATA keys: ${customData?.keys.toList()}');
      
      if (customData == null) {
        print('❌ ERROR: response.data[\'data\'] is NULL or not a Map. Full Response: ${response.data}');
        return DataResponse(modules: [], units: [], chapters: [], exercises: []);
      }

      final modules = (customData['modules'] as List?) ?? [];
      final units = (customData['units'] as List?) ?? [];
      final chapters = (customData['chapters'] as List?) ?? [];
      final exercises = (customData['exercices'] as List?) ?? [];

      print('✅ API Successfully Parsed List lengths: Modules=${modules.length}, Units=${units.length}, Chapters=${chapters.length}, Exercises=${exercises.length}');

      final prodModules = modules.map((m) {
        try {
          return MaterialModel.fromMap(m as Map<String, dynamic>);
        } catch (e) {
          print('❌ ERROR parsing module ${m['id']}: $e');
          return null;
        }
      }).whereType<MaterialModel>().toList();

      final prodUnits = units.map((u) {
        try {
          return UnitModel.fromMap(u as Map<String, dynamic>);
        } catch (e) {
          print('❌ ERROR parsing unit ${u['id']}: $e');
          return null;
        }
      }).whereType<UnitModel>().toList();

      final prodChapters = chapters.map((c) {
        try {
          return ChapterModel.fromMap(c as Map<String, dynamic>);
        } catch (e) {
          print('❌ ERROR parsing chapter ${c['id']}: $e');
          return null;
        }
      }).whereType<ChapterModel>().toList();

      final List<ExerciseModel> prodExercises = [];
      for (var exContainer in exercises) {
        try {
          if (exContainer is Map && exContainer['questions'] is List) {
            for (var quest in (exContainer['questions'] as List)) {
              try {
                prodExercises.add(ExerciseModel.fromMap(quest as Map<String, dynamic>));
              } catch (e) {
                print('❌ ERROR parsing question in chapter ${exContainer['chapter_id']}: $e');
              }
            }
          }
        } catch (e) {
          print('❌ ERROR processing exercise container: $e');
        }
      }

      final modulesImages = prodModules.map((module) => module.imageList).toList();
      final modulesGridImages = prodModules.map((module) => module.imageGrid).toList();

      // Fire and forget caching
      ImagePrecacheService.cacheImages([
        ...modulesImages,
        ...modulesGridImages,
      ]);

      return DataResponse(
        modules: prodModules,
        units: prodUnits,
        chapters: prodChapters,
        exercises: prodExercises,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return DataResponse(
          modules: [],
          units: [],
          chapters: [],
          exercises: [],
        );
      }

      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<SubmissionProgressResponse> submitAnswers(
    int chapterId,
    List<SubmissionAnswer> submissionAnswers, {
    int? totalSlides,
  }) async {
    try {
      final response = await _coursesDataSource.submitAnswers(
        SubmitAnswerModel(
          chapterId: chapterId,
          submissionAnswers: submissionAnswers,
          totalSlides: totalSlides,
        ).toMap(),
      );
      return SubmissionProgressResponse.fromMap(
          response.customData['progress']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportExercise(int exerciseId, String? reason) async {
    try {
      await _coursesDataSource.reportExercise(
        ReportExoDto(exerciseId: exerciseId, reason: reason),
      );
    } catch (e) {
      AppLogger.logError('Error reporting exercise: $e');
      rethrow;
    }
  }

  Future<List<ExerciseModel>> getTodayReview() async {
    try {
      final response = await _coursesDataSource.getTodayReview();
      final questions = response.customData['questions'] as List;
      return questions.map((q) => ExerciseModel.fromMap(q)).toList();
    } catch (e) {
      AppLogger.logError('Error getting review: $e');
      return [];
    }
  }

  Future<void> submitReview(List<SubmissionAnswer> results) async {
    try {
      final payload = results.map((r) => {
        'question_id': r.questionId,
        'is_correct': r.isCorrect,
      }).toList();
      await _coursesDataSource.submitReview(payload);
    } catch (e) {
      AppLogger.logError('Error submitting review: $e');
    }
  }
}
