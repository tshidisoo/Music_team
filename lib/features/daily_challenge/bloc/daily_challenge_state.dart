import 'package:equatable/equatable.dart';
import '../models/daily_challenge_model.dart';

abstract class DailyChallengeState extends Equatable {
  const DailyChallengeState();

  @override
  List<Object?> get props => [];
}

class DailyChallengeInitial extends DailyChallengeState {}

class DailyChallengeLoading extends DailyChallengeState {}

class DailyChallengeLoaded extends DailyChallengeState {
  final DailyChallenge challenge;
  final bool isCompletedToday;
  final DailyChallengeCompletion? todayCompletion;
  final int challengeStreak;
  final Map<String, DailyChallengeCompletion> monthCompletions;
  final int calendarYear;
  final int calendarMonth;

  const DailyChallengeLoaded({
    required this.challenge,
    required this.isCompletedToday,
    this.todayCompletion,
    required this.challengeStreak,
    required this.monthCompletions,
    required this.calendarYear,
    required this.calendarMonth,
  });

  @override
  List<Object?> get props => [
        challenge,
        isCompletedToday,
        todayCompletion,
        challengeStreak,
        monthCompletions,
        calendarYear,
        calendarMonth,
      ];
}

/// Teacher has disabled the daily challenge for today.
class DailyChallengeDisabled extends DailyChallengeState {
  final int challengeStreak;
  final Map<String, DailyChallengeCompletion> monthCompletions;
  final int calendarYear;
  final int calendarMonth;

  const DailyChallengeDisabled({
    required this.challengeStreak,
    required this.monthCompletions,
    required this.calendarYear,
    required this.calendarMonth,
  });

  @override
  List<Object?> get props =>
      [challengeStreak, monthCompletions, calendarYear, calendarMonth];
}

class DailyChallengeError extends DailyChallengeState {
  final String message;
  const DailyChallengeError(this.message);

  @override
  List<Object?> get props => [message];
}
