import 'package:tayssir/features/exercice/presentation/state/exercise_state.dart';

class SubmitAnswerModel {
  final int chapterId;
  final List<SubmissionAnswer> submissionAnswers;
  final int? totalSlides;

  SubmitAnswerModel({
    required this.chapterId,
    required this.submissionAnswers,
    this.totalSlides,
  });

  Map<String, dynamic> toMap() {
    return {
      'chapter_id': chapterId,
      'answers': submissionAnswers.map((e) => e.toMap()).toList(),
      if (totalSlides != null) 'total_slides': totalSlides,
    };
  }
}
