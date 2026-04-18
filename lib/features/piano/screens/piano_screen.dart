import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/piano_bloc.dart';
import '../bloc/piano_event.dart';
import '../bloc/piano_state.dart';
import '../widgets/piano_keyboard_widget.dart';
import '../../practice/games/results_screen.dart';

class PianoScreen extends StatelessWidget {
  const PianoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PianoBloc(),
      child: const _PianoView(),
    );
  }
}

class _PianoView extends StatelessWidget {
  const _PianoView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PianoBloc, PianoState>(
      listener: (context, state) {
        if (state.allDone) {
          final perfect = state.score == state.totalChallenges;
          final xp = state.score * 5 + (perfect ? 50 : 0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultsScreen(
                gameTitle: 'Piano Challenge',
                score: state.score,
                total: state.totalChallenges,
                xpEarned: xp,
                perfect: perfect,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Piano'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Mode selector
              _ModeSelector(currentMode: state.mode),
              const SizedBox(height: 8),

              // Challenge prompt (if not free play)
              if (state.mode != 'freePlay') ...[
                _ChallengePrompt(state: state),
                const SizedBox(height: 8),
              ],

              const Spacer(),

              // Piano keyboard — 3 octaves to cover all challenge ranges
              SizedBox(
                height: 220,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PianoKeyboardWidget(
                    startMidi: 48, // C3
                    octaves: 3,
                    onKeyPressed: (midi) {
                      context.read<PianoBloc>().add(PianoKeyPressed(midi));
                    },
                    highlightCorrect: state.highlightCorrect,
                    highlightWrong: state.highlightWrong,
                    highlightHint: state.mode != 'freePlay'
                        ? [] // No hints by default
                        : [],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ─── Mode Selector ──────────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  final String currentMode;
  const _ModeSelector({required this.currentMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ModeChip(
            label: 'Free Play',
            icon: Icons.piano_rounded,
            isSelected: currentMode == 'freePlay',
            onTap: () =>
                context.read<PianoBloc>().add(const ChangePianoMode('freePlay')),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: 'Scales',
            icon: Icons.trending_up_rounded,
            isSelected: currentMode == 'scale',
            onTap: () =>
                context.read<PianoBloc>().add(const ChangePianoMode('scale')),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: 'Intervals',
            icon: Icons.swap_horiz_rounded,
            isSelected: currentMode == 'interval',
            onTap: () =>
                context.read<PianoBloc>().add(const ChangePianoMode('interval')),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: 'Triads',
            icon: Icons.music_note_rounded,
            isSelected: currentMode == 'triad',
            onTap: () =>
                context.read<PianoBloc>().add(const ChangePianoMode('triad')),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }
}

// ─── Challenge Prompt ────────────────────────────────────────────────────────────

class _ChallengePrompt extends StatelessWidget {
  final PianoState state;
  const _ChallengePrompt({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Challenge ${state.completedChallenges + 1} of ${state.totalChallenges}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.xpGold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${state.score} correct',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.xpGold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.completedChallenges / state.totalChallenges,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),

              // Challenge name
              if (state.challengeName != null) ...[
                Text(
                  state.challengeName!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                if (state.challengeDescription != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.challengeDescription!,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],

              // Progress dots (notes played vs expected)
              if (state.expectedNotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(state.expectedNotes.length, (i) {
                    final played = i < state.playedNotes.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: played
                              ? AppColors.success
                              : AppColors.primary.withValues(alpha: 0.15),
                          border: played
                              ? null
                              : Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3)),
                        ),
                      ),
                    );
                  }),
                ),
              ],

              // Next button when challenge is complete
              if (state.challengeComplete) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Correct!',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<PianoBloc>().add(LoadNextChallenge());
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Next'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
