import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/services/lesson_service.dart';
import '../data/practice_exercises.dart';
import 'lesson_practice_hub.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<LessonModel> _part1 = [];
  List<LessonModel> _part2 = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final p1 = await LessonService().getLessonsForPart(1);
    final p2 = await LessonService().getLessonsForPart(2);
    if (mounted) {
      setState(() {
        _part1 = p1;
        _part2 = p2;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverToBoxAdapter(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sports_esports_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Practice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              )),
                          Text('5 game modes per lesson',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Game mode icons row
                  SizedBox(
                    height: 64,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _ModeChip(icon: Icons.style_rounded, label: 'Flashcards', color: AppColors.primary),
                        _ModeChip(icon: Icons.quiz_rounded, label: 'Quiz', color: AppColors.secondary),
                        _ModeChip(icon: Icons.compare_arrows_rounded, label: 'Matching', color: AppColors.success),
                        _ModeChip(icon: Icons.check_circle_rounded, label: 'True/False', color: AppColors.info),
                        _ModeChip(icon: Icons.sort_by_alpha_rounded, label: 'Anagram', color: Color(0xFFEC4899)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: 'Part I'),
                  Tab(text: 'Part II'),
                ],
              ),
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_part1.isEmpty && _part2.isEmpty)
                ? _EmptyState()
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _LessonList(lessons: _part1),
                      _LessonList(lessons: _part2),
                    ],
                  ),
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  final List<LessonModel> lessons;

  const _LessonList({required this.lessons});

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const _EmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _LessonPracticeCard(lesson: lessons[i]),
    );
  }
}

class _LessonPracticeCard extends StatelessWidget {
  final LessonModel lesson;

  const _LessonPracticeCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final exerciseSet =
        PracticeExercises.getForLesson(lesson.partNumber, lesson.chapterNumber);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: exerciseSet == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LessonPracticeHub(exerciseSet: exerciseSet),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Chapter number badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: lesson.partNumber == 1
                      ? AppColors.primaryGradient
                      : AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${lesson.chapterNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'CH',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    // Game mode dots
                    Row(
                      children: const [
                        _ModeDot(color: AppColors.primary),
                        _ModeDot(color: AppColors.secondary),
                        _ModeDot(color: AppColors.success),
                        _ModeDot(color: AppColors.info),
                        _ModeDot(color: Color(0xFFEC4899)),
                        SizedBox(width: 4),
                        Text('5 modes',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info)),
                      ],
                    ),
                  ],
                ),
              ),
              if (exerciseSet != null)
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.primary)
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Soon',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeDot extends StatelessWidget {
  final Color color;
  const _ModeDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No lessons found',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Ask your teacher to seed the lesson content.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
