import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'ear_training_game_screen.dart';

class EarTrainingHubScreen extends StatelessWidget {
  const EarTrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ear Training'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.hearing_rounded,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Train Your Ear',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Listen carefully and identify what you hear',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Intervals section
            Text('Intervals', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Hear two notes played one after another — identify the distance',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _DifficultyCard(
              title: 'Beginner',
              subtitle: 'Unison, P4, P5, Octave',
              color: AppColors.success,
              icon: Icons.looks_one_rounded,
              onTap: () => _startTraining(context, 'intervals', 1),
            ),
            const SizedBox(height: 8),
            _DifficultyCard(
              title: 'Intermediate',
              subtitle: '+ Major 2nd, Minor 3rd, Major 3rd',
              color: AppColors.warning,
              icon: Icons.looks_two_rounded,
              onTap: () => _startTraining(context, 'intervals', 2),
            ),
            const SizedBox(height: 8),
            _DifficultyCard(
              title: 'Advanced',
              subtitle: 'All 13 intervals including Tritone, 6ths, 7ths',
              color: AppColors.error,
              icon: Icons.looks_3_rounded,
              onTap: () => _startTraining(context, 'intervals', 3),
            ),
            const SizedBox(height: 24),

            // Chords section
            Text('Chords', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Hear multiple notes at once — identify the chord type',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _DifficultyCard(
              title: 'Beginner',
              subtitle: 'Major and Minor triads',
              color: AppColors.success,
              icon: Icons.looks_one_rounded,
              onTap: () => _startTraining(context, 'chords', 1),
            ),
            const SizedBox(height: 8),
            _DifficultyCard(
              title: 'Intermediate',
              subtitle: '+ Diminished and Augmented',
              color: AppColors.warning,
              icon: Icons.looks_two_rounded,
              onTap: () => _startTraining(context, 'chords', 2),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _startTraining(BuildContext context, String category, int difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EarTrainingGameScreen(
          category: category,
          difficulty: difficulty,
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_filled_rounded, color: color, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
