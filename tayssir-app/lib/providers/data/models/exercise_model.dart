import 'dart:developer';
import 'dart:ui';

import 'package:tayssir/environment_config.dart';

import 'package:tayssir/providers/data/models/anomaly_word_exercise.dart';
import 'package:tayssir/providers/data/models/fill_in_the_blank_exercise.dart';
import 'package:tayssir/providers/data/models/latex_field.dart';
import 'package:tayssir/providers/data/models/pair_two_words_exercise.dart';
import 'package:tayssir/providers/data/models/select_multiple_option_exercise.dart';
import 'package:tayssir/providers/data/models/slide_exercise.dart';
import 'package:tayssir/providers/data/models/true_false_exercise.dart';

enum ExerciseType {
  multipleChoices,
  trueFalse,
  pairTwoWords,
  fillInTheBlank,
  anomalyWord,
  slide,
  ordering, // New: Verse Reconstruction
  audioRecording, // New: AI Voice Analysis
}

enum ExerciseDirection {
  rtl,
  ltr,
}

enum ExerciseDifficulty { easy, medium, hard }

enum ExerciseScope {
  exercice,
  lesson,
}

abstract class ExerciseModel {
  final int id;
  final List<String> tags; // New: Dynamic Skill Tags (e.g., 'Ikhfa', 'Madd')
  final ExerciseType type;
  final int chapterId;
  final List<LatexField<String>> hints;
  final LatexField<String?> explanation;
  final String? image;
  final int points;
  // final ExerciseDifficulty difficulty;
  final ExerciseScope scope;
  final String? hintImage;
  final String? explanationVideo;
  final ExerciseDirection direction;

  ExerciseModel({
    required this.id,
    this.tags = const [],
    required this.type,
    required this.chapterId,
    required this.hints,
    required this.explanation,
    this.hintImage,
    // required this.difficulty,
    required this.points,
    required this.scope,
    required this.direction,
    this.image,
    this.explanationVideo,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> rawMap) {
    // Handle Filament Builder Block structure
    Map<String, dynamic> map = rawMap;
    String blockType = '';
    
    if (rawMap.containsKey('type') && rawMap.containsKey('data')) {
      blockType = rawMap['type'] as String;
      map = Map<String, dynamic>.from(rawMap['data'] as Map);
      // Inject IDs for internal consistency if missing
      map['id'] ??= -1; 
      map['chapter_id'] ??= -1;
    } else {
      blockType = rawMap['type'] as String;
    }

    if (blockType == 'slide') {
      return SlideExercise.fromMap(map);
    }

    // Question logic
    final questionType = map['type'] as String? ?? blockType;

    switch (questionType) {
      case 'multiple_choices':
        return SelectMultipleOptionExercise.fromMap(map);
      case 'true_or_false':
        return TrueFalseExercise.fromMap(map);
      case 'match_with_arrows':
        return PairTwoWordsExercise.fromMap(map);
      case 'fill_in_the_blanks':
        return FillInTheBlankExercise.fromMap(map);
      case "pick_the_intruder":
        return AnomalyWordExercise.fromMap(map);
      case "ordering":
        // Fallback to multiple choice for now if specific view not ready, but register type
        return SelectMultipleOptionExercise.fromMap(map); 
      case "audio_recording":
        return SelectMultipleOptionExercise.fromMap(map);
      case "slide":
        return SlideExercise.fromMap(map);
      default:
        // Attempt fallback for question_text based models if coming from Builder
        if (map.containsKey('question_text')) {
           return SelectMultipleOptionExercise.fromMap(map);
        }
        throw Exception('Invalid exercise type: $questionType');
    }
  }

  List<LatexField<String>>? get remark =>
      scope == ExerciseScope.lesson ? hints : null;

  bool get shouldShowHint =>
      hints.isNotEmpty && scope == ExerciseScope.exercice;

  TextDirection get currentDirection => direction == ExerciseDirection.rtl
      ? TextDirection.rtl
      : TextDirection.ltr;

  bool checkAnswer(dynamic answer);
  dynamic getCorrectAnswer();
  String getFeedback();
}

extension ExerciseMapExtension on Map<String, dynamic> {
  ExerciseBaseParams get asExerciseBaseParams {
    try {
      return ExerciseBaseParams(
        id: _toInt(this['id']),
        tags: List<String>.from(this['tags'] ?? []),
        chapterId: _toInt(this['chapter_id']),
        points: _toInt(this['points']),
        hints: List<LatexField<String>>.from((this['hint'] as List<dynamic>?)
                ?.map((e) => LatexField<String>.fromMap(e)) ??
            []),
        explanation: LatexField<String?>.fromMap(
            this['explanation_text'] as Map<String, dynamic>),
        image: EnvironmentConfig.resolveImageUrl(this['image'] as String?),
        explanationVideo: this['explanationVideo'] as String?,
        scope: this['scope'] == 'lesson'
            ? ExerciseScope.lesson
            : ExerciseScope.exercice,
        direction: this['direction'] == 'RTL'
            ? ExerciseDirection.rtl
            : ExerciseDirection.ltr,
        hintImage:
            EnvironmentConfig.resolveImageUrl(this['hintImage'] as String?),
      );
    } catch (e) {
      log('Error parsing exo Id: ${this['id']} - $e');
      return ExerciseBaseParams(
        id: _toInt(this['id']),
        tags: [],
        chapterId: -1,
        points: 0,
        hints: [],
        explanation: LatexField<String?>(false, 'val'),
        scope: ExerciseScope.exercice,
        direction: ExerciseDirection.ltr,
      );
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ExerciseBaseParams {
  final int id;
  final List<String> tags;
  final int chapterId;
  final List<LatexField<String>> hints;
  final LatexField<String?> explanation;
  final String? image;
  final int points;
  // final ExerciseDifficulty difficulty;
  final ExerciseScope scope;
  final String? hintImage;
  final String? explanationVideo;
  final ExerciseDirection direction;

  ExerciseBaseParams({
    required this.id,
    this.tags = const [],
    required this.chapterId,
    required this.points,
    required this.scope,
    // required this.difficulty,
    required this.direction,
    required this.explanation,
    required this.hints,
    this.image,
    this.hintImage,
    this.explanationVideo,
  });
}
