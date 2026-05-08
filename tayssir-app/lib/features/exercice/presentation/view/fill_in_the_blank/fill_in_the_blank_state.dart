import 'package:equatable/equatable.dart';
import 'package:tayssir/providers/data/models/fill_in_the_blank_exercise.dart';

class FillInTheBlankState extends Equatable {
  final FillInTheBlankExercise exercise;
  final List<int?> filledBlanks;
  final List<bool> wordSelectionState;
  final int? selectedBlankIndex;
  final bool isChecked;
  final bool isCorrect;

  const FillInTheBlankState({
    required this.exercise,
    required this.filledBlanks,
    required this.wordSelectionState,
    this.selectedBlankIndex,
    this.isChecked = false,
    this.isCorrect = false,
  });

  FillInTheBlankState copyWith({
    FillInTheBlankExercise? exercise,
    List<int?>? filledBlanks,
    List<bool>? wordSelectionState,
    int? selectedBlankIndex,
    bool? isChecked,
    bool? isCorrect,
    bool clearSelection = false,
  }) {
    return FillInTheBlankState(
      exercise: exercise ?? this.exercise,
      filledBlanks: filledBlanks ?? this.filledBlanks,
      wordSelectionState: wordSelectionState ?? this.wordSelectionState,
      selectedBlankIndex: clearSelection ? null : (selectedBlankIndex ?? this.selectedBlankIndex),
      isChecked: isChecked ?? this.isChecked,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  int getNextBlankIndex() {
    if (selectedBlankIndex != null && filledBlanks[selectedBlankIndex!] == null) {
      return selectedBlankIndex!;
    }
    for (int i = 0; i < filledBlanks.length; i++) {
      if (filledBlanks[i] == null) {
        return i;
      }
    }
    return -1;
  }

  bool isAllBlanksFilled() {
    return filledBlanks.every((blank) => blank != null);
  }

  bool isAllWordsSelected() {
    return wordSelectionState.every((isSelected) => isSelected);
  }

  bool isWordSelected(int wordIndex) {
    return wordSelectionState[wordIndex];
  }

  bool get canSubmit => isAllBlanksFilled();

  bool checkAnswer() {
    final blanks = exercise.blanks;
    for (int i = 0; i < blanks.length; i++) {
      if (filledBlanks[i] == null) return false;
      if (blanks[i].correctWord != exercise.suggestions[filledBlanks[i]!]) {
        return false;
      }
    }
    return true;
  }

  bool isAnswered(int blankIndex) => filledBlanks[blankIndex] != null;
  
  String getBlankAnswer(int blankIndex) {
    if (filledBlanks[blankIndex] != null) {
      return exercise.suggestions[filledBlanks[blankIndex]!];
    }
    return List.filled(5, "_").join("");
  }

  bool isCorrectWord(int blankIndex) {
    if (filledBlanks[blankIndex] == null) return false;
    return exercise.blanks[blankIndex].correctWord == exercise.suggestions[filledBlanks[blankIndex]!];
  }

  @override
  List<Object?> get props =>
      [exercise, filledBlanks, wordSelectionState, isChecked, isCorrect];

  @override
  String toString() {
    return 'FillInTheBlankState(exercise: $exercise, filledBlanks: $filledBlanks, wordSelectionState: $wordSelectionState, isChecked: $isChecked, isCorrect: $isCorrect)';
  }
}
