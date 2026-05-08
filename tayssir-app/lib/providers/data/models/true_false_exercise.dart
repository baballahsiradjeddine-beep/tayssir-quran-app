import 'package:tayssir/providers/data/models/exercise_model.dart';
import 'package:tayssir/providers/data/models/latex_field.dart';

class TrueFalseExercise extends ExerciseModel {
  final LatexField<String> question;
  final bool correctAnswer;

  TrueFalseExercise({
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
    required this.question,
    required this.correctAnswer,
    super.hintImage,
  }) : super(
          type: ExerciseType.trueFalse,
        );

  factory TrueFalseExercise.fromMap(Map<String, dynamic> map) {
    final baseParams = map.asExerciseBaseParams;

    return TrueFalseExercise(
      id: baseParams.id,
      tags: baseParams.tags,
      chapterId: baseParams.chapterId,
      points: baseParams.points,
      scope: baseParams.scope,
      // difficulty: baseParams.difficulty,
      direction: baseParams.direction,
      hints: baseParams.hints,
      hintImage: baseParams.hintImage,
      explanation: baseParams.explanation,
      image: baseParams.image,
      explanationVideo: baseParams.explanationVideo,
      question:
          LatexField<String>.fromMap(map['question'] as Map<String, dynamic>),
      correctAnswer: (() {
        final val = map['correctAnswer'];
        if (val is bool) return val;
        if (val is String) return val.toLowerCase() == 'true' || val == '1';
        if (val is int) return val == 1;
        return false;
      })(),
    );
  }

  @override
  bool checkAnswer(dynamic answer) {
    return answer == correctAnswer;
  }

  @override
  dynamic getCorrectAnswer() {
    return correctAnswer;
  }

  @override
  String getFeedback() {
    String finalResult = '';
    if (explanation.text != null) {
      finalResult = explanation.text!;
    } else {
      finalResult = "الاجابة الصحيحة هي ${correctAnswer ? 'صحيح' : 'خطأ'}";
    }
    return finalResult;
  }
}
