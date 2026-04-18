import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/lesson_model.dart';
import '../../../shared/blocs/auth_bloc.dart';
import '../bloc/lessons_bloc.dart';
import '../../practice/data/practice_exercises.dart';
import '../../practice/screens/lesson_practice_hub.dart';

class LessonDetailScreen extends StatelessWidget {
  final LessonModel lesson;
  final bool isCompleted;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonsBloc, LessonsState>(
      listener: (context, state) {
        if (state is LessonCompleted) {
          _showXpPopup(context, state.xpAwarded);
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Hero app bar
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Chapter ${lesson.chapterNumber} · Part ${lesson.partNumber}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completion badge
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 18),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.lessonComplete,
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Key points card
                    if (lesson.content.keyPoints.isNotEmpty) ...[
                      _KeyPointsCard(keyPoints: lesson.content.keyPoints),
                      const SizedBox(height: 24),
                    ],
                    // Lesson text
                    Text(
                      'Lesson Content',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lesson.content.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                          ),
                    ),
                    const SizedBox(height: 32),
                    // Mark complete button
                    if (!isCompleted) _MarkCompleteButton(lesson: lesson),
                    const SizedBox(height: 16),
                    // Practice button
                    _PracticeButton(lesson: lesson),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showXpPopup(BuildContext context, int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.xpGold),
            const SizedBox(width: 8),
            Text(
              '+$xp XP — Lesson Complete! 🎉',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _KeyPointsCard extends StatelessWidget {
  final List<String> keyPoints;
  const _KeyPointsCard({required this.keyPoints});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Key Points',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...keyPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeButton extends StatelessWidget {
  final LessonModel lesson;
  const _PracticeButton({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final exerciseSet = PracticeExercises.getForLesson(
        lesson.partNumber, lesson.chapterNumber);
    if (exerciseSet == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonPracticeHub(exerciseSet: exerciseSet),
          ),
        ),
        icon: const Icon(Icons.sports_esports_rounded),
        label: const Text('Practice This Lesson'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _MarkCompleteButton extends StatelessWidget {
  final LessonModel lesson;
  const _MarkCompleteButton({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonsBloc, LessonsState>(
      builder: (context, state) {
        final isLoading = state is LessonsLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<LessonsBloc>().add(CompleteLesson(
                            uid: authState.user.uid,
                            lessonId: lesson.id,
                          ));
                    }
                  },
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(isLoading ? 'Saving...' : AppStrings.markComplete),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      },
    );
  }
}
