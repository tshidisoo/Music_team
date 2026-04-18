import 'package:equatable/equatable.dart';

/// Sentinel object to distinguish "not passed" from "explicitly null".
const _sentinel = _Sentinel();

class _Sentinel {
  const _Sentinel();
}

class EarTrainingState extends Equatable {
  final String category;
  final int difficulty;
  final int currentQuestion;
  final int totalQuestions;
  final int score;
  final String? correctAnswer;
  final String? selectedAnswer;
  final List<String> options;
  final bool answered;
  final bool isPlaying;
  final bool sessionComplete;

  const EarTrainingState({
    this.category = 'intervals',
    this.difficulty = 1,
    this.currentQuestion = 0,
    this.totalQuestions = 10,
    this.score = 0,
    this.correctAnswer,
    this.selectedAnswer,
    this.options = const [],
    this.answered = false,
    this.isPlaying = false,
    this.sessionComplete = false,
  });

  EarTrainingState copyWith({
    String? category,
    int? difficulty,
    int? currentQuestion,
    int? totalQuestions,
    int? score,
    Object? correctAnswer = _sentinel,
    Object? selectedAnswer = _sentinel,
    List<String>? options,
    bool? answered,
    bool? isPlaying,
    bool? sessionComplete,
  }) {
    return EarTrainingState(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      correctAnswer: correctAnswer == _sentinel
          ? this.correctAnswer
          : correctAnswer as String?,
      selectedAnswer: selectedAnswer == _sentinel
          ? this.selectedAnswer
          : selectedAnswer as String?,
      options: options ?? this.options,
      answered: answered ?? this.answered,
      isPlaying: isPlaying ?? this.isPlaying,
      sessionComplete: sessionComplete ?? this.sessionComplete,
    );
  }

  @override
  List<Object?> get props => [
        category, difficulty, currentQuestion, totalQuestions,
        score, correctAnswer, selectedAnswer, options,
        answered, isPlaying, sessionComplete,
      ];
}
