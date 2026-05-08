import 'package:tayssir/providers/data/models/exercise_model.dart';
import 'package:tayssir/providers/data/models/latex_field.dart';

class SlideExercise extends ExerciseModel {
  final String slideType; // 'text', 'video', 'image', 'flashcard'
  final String? mediaUrl;
  final String? contentText;

  SlideExercise({
    required this.slideType,
    this.mediaUrl,
    this.contentText,
    required super.id,
    required super.chapterId,
    required super.points,
    required super.scope,
    required super.direction,
    required super.explanation,
    required super.hints,
    super.image,
    super.explanationVideo,
    super.hintImage,
  }) : super(
          type: ExerciseType.slide,
        );

  factory SlideExercise.fromMap(Map<String, dynamic> map) {
    final baseParams = map.asExerciseBaseParams;

    return SlideExercise(
      id: baseParams.id,
      chapterId: baseParams.chapterId,
      points: baseParams.points,
      scope: baseParams.scope,
      direction: baseParams.direction,
      hints: baseParams.hints,
      explanation: baseParams.explanation,
      image: baseParams.image,
      explanationVideo: baseParams.explanationVideo,
      hintImage: baseParams.hintImage,
      slideType: map['type'] as String? ?? 'text',
      mediaUrl: map['media_url'] as String?,
      contentText: map['content'] as String?,
    );
  }

  @override
  bool checkAnswer(dynamic answer) {
    // Slides are always "correct" once viewed
    return true;
  }

  @override
  dynamic getCorrectAnswer() {
    return null;
  }

  @override
  String getFeedback() {
    return "";
  }
}
