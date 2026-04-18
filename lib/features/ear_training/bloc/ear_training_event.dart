import 'package:equatable/equatable.dart';

abstract class EarTrainingEvent extends Equatable {
  const EarTrainingEvent();
  @override
  List<Object?> get props => [];
}

/// Start a new ear training session.
class StartEarTraining extends EarTrainingEvent {
  final String category; // 'intervals' or 'chords'
  final int difficulty; // 1, 2, 3
  const StartEarTraining({required this.category, required this.difficulty});
  @override
  List<Object?> get props => [category, difficulty];
}

/// Play the current sound again.
class ReplaySound extends EarTrainingEvent {}

/// User selected an answer.
class SubmitAnswer extends EarTrainingEvent {
  final String answer;
  const SubmitAnswer(this.answer);
  @override
  List<Object?> get props => [answer];
}

/// Move to the next question.
class NextQuestion extends EarTrainingEvent {}
