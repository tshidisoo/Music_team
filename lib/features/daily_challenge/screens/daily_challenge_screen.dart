import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import '../../practice/data/practice_exercises.dart';
import '../../practice/games/quiz_game.dart';
import '../../practice/games/matching_game.dart';
import '../../practice/games/true_false_game.dart';
import '../../practice/games/flashcard_game.dart';
import '../../practice/games/anagram_game.dart';
import '../bloc/daily_challenge_bloc.dart';
import '../bloc/daily_challenge_event.dart';
import '../bloc/daily_challenge_state.dart';
import '../widgets/challenge_calendar_widget.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => DailyChallengeBloc(uid: authState.user.uid)
        ..add(LoadDailyChallenge()),
      child: const _DailyChallengeView(),
    );
  }
}

class _DailyChallengeView extends StatelessWidget {
  const _DailyChallengeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<DailyChallengeBloc, DailyChallengeState>(
        builder: (context, state) {
          if (state is DailyChallengeLoading || state is DailyChallengeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DailyChallengeError) {
            return Center(child: Text(state.message));
          }

          // ── Teacher disabled today's challenge ──
          if (state is DailyChallengeDisabled) {
            return _buildDisabledView(context, state);
          }

          if (state is! DailyChallengeLoaded) return const SizedBox.shrink();

          final challenge = state.challenge;
          final isCompleted = state.isCompletedToday;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DailyChallengeBloc>().add(LoadDailyChallenge());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StreakBanner(
                    streak: state.challengeStreak,
                    isCompleted: isCompleted,
                  ),
                  const SizedBox(height: 16),
                  _TodayChallengeCard(
                    challenge: challenge,
                    isCompleted: isCompleted,
                    completion: state.todayCompletion,
                    onPlay: () => _launchChallenge(context, challenge),
                  ),
                  const SizedBox(height: 20),
                  Text('Challenge History',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  ChallengeCalendarWidget(
                    year: state.calendarYear,
                    month: state.calendarMonth,
                    completions: state.monthCompletions,
                    onPreviousMonth: () {
                      var m = state.calendarMonth - 1;
                      var y = state.calendarYear;
                      if (m < 1) { m = 12; y--; }
                      context.read<DailyChallengeBloc>()
                          .add(ChangeCalendarMonth(year: y, month: m));
                    },
                    onNextMonth: () {
                      var m = state.calendarMonth + 1;
                      var y = state.calendarYear;
                      if (m > 12) { m = 1; y++; }
                      context.read<DailyChallengeBloc>()
                          .add(ChangeCalendarMonth(year: y, month: m));
                    },
                  ),
                  const SizedBox(height: 20),
                  _XpMultiplierInfo(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisabledView(
      BuildContext context, DailyChallengeDisabled state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak banner (show current streak even on disabled days)
          _StreakBanner(streak: state.challengeStreak, isCompleted: false),
          const SizedBox(height: 16),

          // Disabled message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.event_busy_rounded,
                        color: Colors.grey.shade400, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Challenge Today',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your teacher has not scheduled a challenge for today. '
                    'Check back tomorrow!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your streak won't be affected.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Calendar still visible
          Text('Challenge History',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ChallengeCalendarWidget(
            year: state.calendarYear,
            month: state.calendarMonth,
            completions: state.monthCompletions,
            onPreviousMonth: () {
              var m = state.calendarMonth - 1;
              var y = state.calendarYear;
              if (m < 1) { m = 12; y--; }
              context.read<DailyChallengeBloc>()
                  .add(ChangeCalendarMonth(year: y, month: m));
            },
            onNextMonth: () {
              var m = state.calendarMonth + 1;
              var y = state.calendarYear;
              if (m > 12) { m = 1; y++; }
              context.read<DailyChallengeBloc>()
                  .add(ChangeCalendarMonth(year: y, month: m));
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _launchChallenge(BuildContext context, dynamic challenge) {
    final exerciseSet = PracticeExercises.getForLesson(
      challenge.partNumber,
      challenge.chapterNumber,
    );
    if (exerciseSet == null) return;

    Widget game;
    switch (challenge.gameType) {
      case 'quiz':
        game = QuizGame(exerciseSet: exerciseSet);
      case 'matching':
        game = MatchingGame(exerciseSet: exerciseSet);
      case 'trueFalse':
        game = TrueFalseGame(exerciseSet: exerciseSet);
      case 'flashcards':
        game = FlashcardGame(exerciseSet: exerciseSet);
      case 'anagrams':
        game = AnagramGame(exerciseSet: exerciseSet);
      default:
        game = QuizGame(exerciseSet: exerciseSet);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => game),
    ).then((_) {
      if (context.mounted) {
        context.read<DailyChallengeBloc>().add(LoadDailyChallenge());
      }
    });
  }
}

// ─── Streak Banner ──────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  final int streak;
  final bool isCompleted;

  const _StreakBanner({required this.streak, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakOrange.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 ? '$streak Day Streak' : 'Start Your Streak!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted
                      ? 'Completed today — see you tomorrow!'
                      : 'Complete today\'s challenge to grow your streak',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 22),
            ),
        ],
      ),
    );
  }
}

// ─── Today's Challenge Card ─────────────────────────────────────────────────────

class _TodayChallengeCard extends StatelessWidget {
  final dynamic challenge;
  final bool isCompleted;
  final dynamic completion;
  final VoidCallback onPlay;

  const _TodayChallengeCard({
    required this.challenge,
    required this.isCompleted,
    required this.completion,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameTypeName =
        DailyChallengeService.gameTypeDisplayName(challenge.gameType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_gameIcon(challenge.gameType),
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text("Today's Challenge",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (challenge.xpMultiplier > 1.0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.xpGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${challenge.xpMultiplier}x XP',
                      style: const TextStyle(
                        color: AppColors.xpGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gameTypeName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      )),
                  const SizedBox(height: 4),
                  Text(challenge.lessonTitle,
                      style: theme.textTheme.bodyMedium),
                  Text(
                    'Part ${challenge.partNumber} — Chapter ${challenge.chapterNumber}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isCompleted && completion != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Completed — ${completion.score}/${completion.total} · +${completion.xpEarned} XP',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play Challenge',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _gameIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz_rounded;
      case 'matching':
        return Icons.link_rounded;
      case 'trueFalse':
        return Icons.check_circle_outline_rounded;
      case 'flashcards':
        return Icons.flip_rounded;
      case 'anagrams':
        return Icons.abc_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}

// ─── XP Multiplier Info ─────────────────────────────────────────────────────────

class _XpMultiplierInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Text('XP Bonuses',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            _BonusRow(
                icon: Icons.weekend_rounded,
                label: 'Weekend challenges',
                value: '1.5x XP'),
            const SizedBox(height: 6),
            _BonusRow(
                icon: Icons.local_fire_department_rounded,
                label: '7-day streak badge',
                value: 'Unlockable'),
            const SizedBox(height: 6),
            _BonusRow(
                icon: Icons.workspace_premium_rounded,
                label: '30-day streak badge',
                value: 'Unlockable'),
          ],
        ),
      ),
    );
  }
}

class _BonusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BonusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.xpGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.xpGold,
                )),
      ],
    );
  }
}
