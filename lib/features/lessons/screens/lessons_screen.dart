import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/services/lesson_service.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import '../bloc/lessons_bloc.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => LessonsBloc(
        lessonService: LessonService(),
        userService: UserService(),
      )..add(LoadLessons(
          uid: authState.user.uid,
          partNumber: AppConstants.partOne,
        )),
      child: const _LessonsView(),
    );
  }
}

class _LessonsView extends StatelessWidget {
  const _LessonsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.lessons),
        actions: [
          // Part selector chips
          BlocBuilder<LessonsBloc, LessonsState>(
            builder: (context, state) {
              final activePart =
                  state is LessonsLoaded ? state.activePart : 1;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    _PartChip(
                      label: AppStrings.partOne,
                      isActive: activePart == 1,
                      onTap: () => context
                          .read<LessonsBloc>()
                          .add(SwitchPart(AppConstants.partOne)),
                    ),
                    const SizedBox(width: 8),
                    _PartChip(
                      label: AppStrings.partTwo,
                      isActive: activePart == 2,
                      onTap: () => context
                          .read<LessonsBloc>()
                          .add(SwitchPart(AppConstants.partTwo)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LessonsBloc, LessonsState>(
        builder: (context, state) {
          if (state is LessonsLoading || state is LessonsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LessonsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<LessonsBloc>().add(
                              LoadLessons(
                                uid: authState.user.uid,
                                partNumber: AppConstants.partOne,
                              ),
                            );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is LessonsLoaded) {
            return _LessonsList(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LessonsList extends StatelessWidget {
  final LessonsLoaded state;
  const _LessonsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No lessons yet for this part.',
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Ask your teacher to add lessons!',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Progress header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: _ProgressHeader(state: state),
          ),
        ),
        // Lesson cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lesson = state.lessons[index];
                final progress = state.progress[lesson.id];
                final isCompleted = progress?.completed ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LessonCard(
                    lesson: lesson,
                    isCompleted: isCompleted,
                    index: index,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<LessonsBloc>(),
                          child: LessonDetailScreen(
                            lesson: lesson,
                            isCompleted: isCompleted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: state.lessons.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final LessonsLoaded state;
  const _ProgressHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AB Guide — Part ${state.activePart}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.completedCount} of ${state.lessons.length} lessons complete',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.completionPercent,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(state.completionPercent * 100).toStringAsFixed(0)}% complete',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final bool isCompleted;
  final int index;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Chapter icon / check badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 24)
                      : Icon(
                          _iconFromName(lesson.iconName),
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Title + key points preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter ${lesson.chapterNumber}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lesson.content.keyPoints.length} key points',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Maps the iconName string stored in Firestore to a real IconData
IconData _iconFromName(String? name) {
  switch (name) {
    case 'music_note':      return Icons.music_note_rounded;
    case 'timer':           return Icons.timer_rounded;
    case 'pause':           return Icons.pause_rounded;
    case 'grid_on':         return Icons.grid_on_rounded;
    case 'format_list_numbered': return Icons.format_list_numbered_rounded;
    case 'radio_button_checked': return Icons.radio_button_checked_rounded;
    case 'tune':            return Icons.tune_rounded;
    case 'equalizer':       return Icons.equalizer_rounded;
    case 'tag':             return Icons.tag_rounded;
    case 'swap_vert':       return Icons.swap_vert_rounded;
    case 'queue_music':     return Icons.queue_music_rounded;
    case 'speed':           return Icons.speed_rounded;
    case 'graphic_eq':      return Icons.graphic_eq_rounded;
    case 'library_music':   return Icons.library_music_rounded;
    case 'auto_stories':    return Icons.auto_stories_rounded;
    case 'piano':           return Icons.piano_rounded;
    case 'stop':            return Icons.stop_rounded;
    case 'timeline':        return Icons.timeline_rounded;
    case 'music_video':     return Icons.music_video_rounded;
    case 'refresh':         return Icons.refresh_rounded;
    case 'more_time':       return Icons.more_time_rounded;
    case 'loop':            return Icons.loop_rounded;
    case 'book':            return Icons.book_rounded;
    case 'auto_awesome':    return Icons.auto_awesome_rounded;
    case 'mic':             return Icons.mic_rounded;
    case 'account_tree':    return Icons.account_tree_rounded;
    default:                return Icons.menu_book_rounded;
  }
}

class _PartChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PartChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
