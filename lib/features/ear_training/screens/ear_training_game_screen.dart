import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../practice/games/results_screen.dart';
import '../bloc/ear_training_bloc.dart';
import '../bloc/ear_training_event.dart';
import '../bloc/ear_training_state.dart';

class EarTrainingGameScreen extends StatelessWidget {
  final String category;
  final int difficulty;

  const EarTrainingGameScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EarTrainingBloc()
        ..add(StartEarTraining(category: category, difficulty: difficulty)),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EarTrainingBloc, EarTrainingState>(
      listener: (context, state) {
        if (state.sessionComplete) {
          final perfect = state.score == state.totalQuestions;
          final xp = state.score * 5 + (perfect ? 50 : 0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultsScreen(
                gameTitle: 'Ear Training — ${state.category == 'intervals' ? 'Intervals' : 'Chords'}',
                score: state.score,
                total: state.totalQuestions,
                xpEarned: xp,
                perfect: perfect,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Question ${state.currentQuestion + 1} of ${state.totalQuestions}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (state.currentQuestion + 1) /
                                    state.totalQuestions,
                                minHeight: 6,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.xpGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.xpGold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${state.score}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.xpGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Listen prompt
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
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
                          Icon(
                            state.category == 'intervals'
                                ? Icons.swap_horiz_rounded
                                : Icons.music_note_rounded,
                            color: Colors.white70,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.category == 'intervals'
                                ? 'What interval do you hear?'
                                : 'What chord type do you hear?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Play button
                          _PlayButton(
                            isPlaying: state.isPlaying,
                            onTap: () {
                              context
                                  .read<EarTrainingBloc>()
                                  .add(ReplaySound());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Answer options
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.options.length,
                      itemBuilder: (ctx, i) {
                        final option = state.options[i];
                        return _AnswerButton(
                          label: option,
                          index: i,
                          isCorrect: state.answered &&
                              option == state.correctAnswer,
                          isWrong: state.answered &&
                              option == state.selectedAnswer &&
                              option != state.correctAnswer,
                          isAnswered: state.answered,
                          onTap: () {
                            context
                                .read<EarTrainingBloc>()
                                .add(SubmitAnswer(option));
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Next button (shown after answering)
                if (state.answered)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          context
                              .read<EarTrainingBloc>()
                              .add(NextQuestion());
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Next',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Play Button ────────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlaying ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isPlaying ? 0.3 : 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Icon(
          isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

// ─── Answer Button ──────────────────────────────────────────────────────────────

class _AnswerButton extends StatelessWidget {
  final String label;
  final int index;
  final bool isCorrect;
  final bool isWrong;
  final bool isAnswered;
  final VoidCallback onTap;

  static const _colors = [
    Color(0xFF6C3FE8),
    Color(0xFFFF8C00),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
  ];

  const _AnswerButton({
    required this.label,
    required this.index,
    required this.isCorrect,
    required this.isWrong,
    required this.isAnswered,
    required this.onTap,
  });

  Color get _color {
    if (isCorrect) return AppColors.success;
    if (isWrong) return AppColors.error;
    if (isAnswered) return _colors[index % _colors.length].withValues(alpha: 0.3);
    return _colors[index % _colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (isCorrect)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
              ),
            if (isWrong)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.cancel_rounded,
                    color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
