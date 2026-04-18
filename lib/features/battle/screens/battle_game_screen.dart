import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/battle_bloc.dart';
import '../bloc/battle_event.dart';
import '../bloc/battle_state.dart';

class BattleGameScreen extends StatelessWidget {
  const BattleGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BattleBloc, BattleState>(
      builder: (context, state) {
        if (state is BattleLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is BattleWaiting) {
          return _WaitingView(state: state);
        }
        if (state is BattleInProgress) {
          return _GameView(state: state);
        }
        if (state is BattleComplete) {
          return _ResultsView(state: state);
        }
        if (state is BattleError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Battle')),
            body: Center(child: Text(state.message)),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

// ─── Waiting View ───────────────────────────────────────────────────────────────

class _WaitingView extends StatelessWidget {
  final BattleWaiting state;
  const _WaitingView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Waiting for opponent...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.opponentName} has been challenged',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Game View ──────────────────────────────────────────────────────────────────

class _GameView extends StatelessWidget {
  final BattleInProgress state;
  const _GameView({required this.state});

  @override
  Widget build(BuildContext context) {
    final battle = state.battle;
    final qIndex = battle.currentQuestionIndex;
    if (qIndex >= battle.questions.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = battle.questions[qIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Score bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ScoreBar(
                myName: state.myUid == battle.player1Uid
                    ? battle.player1Name
                    : battle.player2Name,
                opponentName: state.opponentName,
                myScore: state.myScore,
                opponentScore: state.opponentScore,
              ),
            ),
            const SizedBox(height: 8),

            // Question progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Question ${qIndex + 1} of ${battle.questions.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (qIndex + 1) / battle.questions.length,
                      minHeight: 6,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Question card
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sports_esports_rounded,
                          color: Colors.white70, size: 28),
                      const SizedBox(height: 12),
                      Text(
                        question.question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Answer options or waiting state
            Expanded(
              flex: 3,
              child: state.myAnswerSubmitted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Waiting for ${state.opponentName}...',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount:
                            question.options.length > 4 ? 4 : question.options.length,
                        itemBuilder: (ctx, i) {
                          return _BattleOptionButton(
                            label: question.options[i],
                            index: i,
                            onTap: () {
                              context
                                  .read<BattleBloc>()
                                  .add(SubmitBattleAnswer(i));
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Score Bar ───────────────────────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final String myName;
  final String opponentName;
  final int myScore;
  final int opponentScore;

  const _ScoreBar({
    required this.myName,
    required this.opponentName,
    required this.myScore,
    required this.opponentScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // My score
          Expanded(
            child: Column(
              children: [
                Text(
                  myName.split(' ').first,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$myScore',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          // VS badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.error,
                fontSize: 16,
              ),
            ),
          ),
          // Opponent score
          Expanded(
            child: Column(
              children: [
                Text(
                  opponentName.split(' ').first,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$opponentScore',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.error.withValues(alpha: 0.8),
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option Button ──────────────────────────────────────────────────────────────

class _BattleOptionButton extends StatelessWidget {
  final String label;
  final int index;
  final VoidCallback onTap;

  static const _colors = [
    Color(0xFF6C3FE8),
    Color(0xFFFF8C00),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
  ];

  const _BattleOptionButton({
    required this.label,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Results View ───────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final BattleComplete state;
  const _ResultsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final isWinner = state.isWinner;
    final isDraw = state.isDraw;
    final xp = isWinner ? 30 : (isDraw ? 15 : 10);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isWinner
                          ? AppColors.xpGold
                          : isDraw
                              ? AppColors.info
                              : AppColors.error,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    isWinner
                        ? Icons.emoji_events_rounded
                        : isDraw
                            ? Icons.handshake_rounded
                            : Icons.sentiment_dissatisfied_rounded,
                    color: isWinner
                        ? AppColors.xpGold
                        : isDraw
                            ? AppColors.info
                            : AppColors.error,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isWinner
                      ? 'You Won!'
                      : isDraw
                          ? "It's a Draw!"
                          : 'Better Luck Next Time!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),

                // Score comparison
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('You',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${state.myScore}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Text('VS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          )),
                      Column(
                        children: [
                          Text(
                            state.opponentName.split(' ').first,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.opponentScore}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // XP earned
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.xpGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+$xp XP earned',
                        style: const TextStyle(
                          color: AppColors.xpGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Back button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context)
                      ..pop() // game
                      ..pop(), // lobby (if navigated from there)
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back to Lobby',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
