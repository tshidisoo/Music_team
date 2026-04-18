import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_models.dart';
import '../games/flashcard_game.dart';
import '../games/quiz_game.dart';
import '../games/matching_game.dart';
import '../games/true_false_game.dart';
import '../games/anagram_game.dart';

class LessonPracticeHub extends StatelessWidget {
  final LessonExerciseSet exerciseSet;

  const LessonPracticeHub({super.key, required this.exerciseSet});

  @override
  Widget build(BuildContext context) {
    final modes = [
      _GameMode(
        title: 'Flashcards',
        subtitle: 'Flip & review key concepts',
        icon: Icons.style_rounded,
        gradient: AppColors.primaryGradient,
        xpHint: '+2 XP per card',
        builder: () => FlashcardGame(exerciseSet: exerciseSet),
      ),
      _GameMode(
        title: 'Quiz',
        subtitle: 'Multiple choice with a timer',
        icon: Icons.quiz_rounded,
        gradient: AppColors.secondaryGradient,
        xpHint: '+5 XP per correct • +50 if perfect',
        builder: () => QuizGame(exerciseSet: exerciseSet),
      ),
      _GameMode(
        title: 'Matching Pairs',
        subtitle: 'Match terms to definitions',
        icon: Icons.compare_arrows_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        xpHint: '+5 XP per pair • bonus for no mistakes',
        builder: () => MatchingGame(exerciseSet: exerciseSet),
      ),
      _GameMode(
        title: 'True or False',
        subtitle: 'Fast-fire true/false statements',
        icon: Icons.check_circle_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        xpHint: '+3 XP per correct answer',
        builder: () => TrueFalseGame(exerciseSet: exerciseSet),
      ),
      _GameMode(
        title: 'Anagram',
        subtitle: 'Unscramble music vocabulary',
        icon: Icons.sort_by_alpha_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        xpHint: '+5 XP per word solved',
        builder: () => AnagramGame(exerciseSet: exerciseSet),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Part ${exerciseSet.partNumber} · Chapter ${exerciseSet.chapterNumber}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exerciseSet.lessonTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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

          // Choose mode section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a game mode',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '5 ways to practise — earn XP for every game you play!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Game mode cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                modes
                    .asMap()
                    .entries
                    .map((entry) => _GameModeCard(
                          mode: entry.value,
                          delay: Duration(
                              milliseconds: entry.key * 60),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameMode {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final String xpHint;
  final Widget Function() builder;

  const _GameMode({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.xpHint,
    required this.builder,
  });
}

class _GameModeCard extends StatefulWidget {
  final _GameMode mode;
  final Duration delay;

  const _GameModeCard({required this.mode, required this.delay});

  @override
  State<_GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<_GameModeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => widget.mode.builder()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: widget.mode.gradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.mode.icon,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mode.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.mode.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.xpGold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.xpGold, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  widget.mode.xpHint,
                                  style: const TextStyle(
                                    color: AppColors.xpGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
