import 'package:flutter/foundation.dart';
import 'package:tayssir/providers/data/models/exercise_model.dart';
import 'package:tayssir/providers/data/models/latex_field.dart';

class SelectMultipleOptionExercise extends ExerciseModel {
  final LatexField<String> question;
  final List<LatexField<String>> options;
  final List<int> correctOptions;

  SelectMultipleOptionExercise({
    required super.id,
    super.tags,
    required super.chapterId,
    required super.hints,
    required super.explanation,
    required super.points,
    required super.scope,
    required super.direction,
    super.image,
    super.explanationVideo,
    required this.options,
    required this.question,
    required this.correctOptions,
    super.hintImage,
  }) : super(
          type: ExerciseType.multipleChoices,
        );

  factory SelectMultipleOptionExercise.fromMap(Map<String, dynamic> map) {
    final baseParams = map.asExerciseBaseParams;

    return SelectMultipleOptionExercise(
      id: baseParams.id,
      tags: baseParams.tags,
      chapterId: baseParams.chapterId,
      question:
          LatexField<String>.fromMap(map['question'] as Map<String, dynamic>),
      options: List<LatexField<String>>.from(
        (map['options'] as List<dynamic>).map((e) {
          return LatexField<String>.fromMap(e);
        }),
      ),
      correctOptions: List<int>.from((map['correctOptions'] as List<dynamic>).map((e) {
        if (e is int) return e;
        if (e is String) return int.tryParse(e) ?? 0;
        return 0;
      })),
      points: baseParams.points,
      scope: baseParams.scope,
      direction: baseParams.direction,
      hints: baseParams.hints,
      explanation: baseParams.explanation,
      image: baseParams.image,
      explanationVideo: baseParams.explanationVideo,
      hintImage: baseParams.hintImage,
    );
  }

  @override
  bool checkAnswer(dynamic answer) {
    return listEquals(answer, correctOptions);
  }

  @override
  dynamic getCorrectAnswer() {
    return correctOptions;
  }

  @override
  String getFeedback() {
    String finalResult = '';
    if (explanation.text != null) {
      finalResult = explanation.text!;
    } else {
      final resultAnswer = correctOptions.map((e) => options[e].text).toList();
      finalResult = resultAnswer.join(', ');
    }

    return finalResult;
  }
}
