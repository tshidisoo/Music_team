import 'package:equatable/equatable.dart';

abstract class DailyChallengeEvent extends Equatable {
  const DailyChallengeEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's challenge and check if it's been completed.
class LoadDailyChallenge extends DailyChallengeEvent {}

/// The user completed the daily challenge.
class CompleteDailyChallenge extends DailyChallengeEvent {
  final int score;
  final int total;
  final int baseXp;

  const CompleteDailyChallenge({
    required this.score,
    required this.total,
    required this.baseXp,
  });

  @override
  List<Object?> get props => [score, total, baseXp];
}

/// Navigate to a different month on the calendar.
class ChangeCalendarMonth extends DailyChallengeEvent {
  final int year;
  final int month;

  const ChangeCalendarMonth({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}
