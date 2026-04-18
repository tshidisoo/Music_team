import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/daily_challenge_model.dart';
import 'daily_challenge_event.dart';
import 'daily_challenge_state.dart';

class DailyChallengeBloc
    extends Bloc<DailyChallengeEvent, DailyChallengeState> {
  final String uid;
  final DailyChallengeService _service = DailyChallengeService();
  final UserService _userService = UserService();

  DailyChallengeBloc({required this.uid}) : super(DailyChallengeInitial()) {
    on<LoadDailyChallenge>(_onLoad);
    on<CompleteDailyChallenge>(_onComplete);
    on<ChangeCalendarMonth>(_onChangeMonth);
  }

  Future<void> _onLoad(
    LoadDailyChallenge event,
    Emitter<DailyChallengeState> emit,
  ) async {
    emit(DailyChallengeLoading());
    try {
      final challenge = await _service.getTodaysChallenge();
      final now = DateTime.now();

      if (challenge == null) {
        // Teacher disabled today's challenge
        final monthCompletions =
            await _service.getMonthCompletions(uid, now.year, now.month);
        final streak = await _service.getDailyChallengeStreak(uid);

        emit(DailyChallengeDisabled(
          challengeStreak: streak,
          monthCompletions: monthCompletions,
          calendarYear: now.year,
          calendarMonth: now.month,
        ));
        return;
      }

      final completion =
          await _service.getCompletion(uid, challenge.dateKey);
      final streak = await _service.getDailyChallengeStreak(uid);
      final monthCompletions =
          await _service.getMonthCompletions(uid, now.year, now.month);

      emit(DailyChallengeLoaded(
        challenge: challenge,
        isCompletedToday: completion != null,
        todayCompletion: completion,
        challengeStreak: streak,
        monthCompletions: monthCompletions,
        calendarYear: now.year,
        calendarMonth: now.month,
      ));
    } catch (e) {
      emit(DailyChallengeError(e.toString()));
    }
  }

  Future<void> _onComplete(
    CompleteDailyChallenge event,
    Emitter<DailyChallengeState> emit,
  ) async {
    final challenge = await _service.getTodaysChallenge();
    if (challenge == null) return;

    // Calculate XP with multiplier
    final xpEarned = (event.baseXp * challenge.xpMultiplier).round();

    final completion = DailyChallengeCompletion(
      dateKey: challenge.dateKey,
      completedAt: DateTime.now(),
      xpEarned: xpEarned,
      gameType: challenge.gameType,
      score: event.score,
      total: event.total,
    );

    // Record completion & award XP
    await _service.recordCompletion(uid, completion);
    await _userService.awardXp(uid, xpEarned);
    await _userService.updateStreak(uid);

    // Check streak milestones
    final streak = await _service.getDailyChallengeStreak(uid);
    if (streak == 7 || streak == 30 || streak == 100) {
      final badgeId = 'daily_${streak}_streak';
      await _userService.unlockBadge(uid, badgeId);
      await NotificationService().showStreakMilestone(streak);
    }

    // Reload
    add(LoadDailyChallenge());
  }

  Future<void> _onChangeMonth(
    ChangeCalendarMonth event,
    Emitter<DailyChallengeState> emit,
  ) async {
    // Works with both DailyChallengeLoaded and DailyChallengeDisabled
    try {
      final monthCompletions =
          await _service.getMonthCompletions(uid, event.year, event.month);

      if (state is DailyChallengeLoaded) {
        final current = state as DailyChallengeLoaded;
        emit(DailyChallengeLoaded(
          challenge: current.challenge,
          isCompletedToday: current.isCompletedToday,
          todayCompletion: current.todayCompletion,
          challengeStreak: current.challengeStreak,
          monthCompletions: monthCompletions,
          calendarYear: event.year,
          calendarMonth: event.month,
        ));
      } else if (state is DailyChallengeDisabled) {
        final current = state as DailyChallengeDisabled;
        emit(DailyChallengeDisabled(
          challengeStreak: current.challengeStreak,
          monthCompletions: monthCompletions,
          calendarYear: event.year,
          calendarMonth: event.month,
        ));
      }
    } catch (_) {
      // Keep current state on calendar error
    }
  }
}
