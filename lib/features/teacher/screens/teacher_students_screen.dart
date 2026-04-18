import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() =>
      _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState
    extends State<TeacherStudentsScreen> {
  bool _sortByXp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  24),
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
                        child: const Icon(Icons.people_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Students',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                )),
                            Text('Enrolled class members',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sort toggle
                  Row(
                    children: [
                      _SortChip(
                        label: 'A – Z',
                        icon: Icons.sort_by_alpha_rounded,
                        selected: !_sortByXp,
                        onTap: () => setState(() => _sortByXp = false),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: 'Top XP',
                        icon: Icons.leaderboard_rounded,
                        selected: _sortByXp,
                        onTap: () => setState(() => _sortByXp = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: StreamBuilder<List<UserModel>>(
          stream: UserService().watchAllStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final raw = snapshot.data ?? [];
            if (raw.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 72,
                          color:
                              AppColors.primary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No students yet',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Students will appear here once they register\nand choose the Student role.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Sort
            final students = List<UserModel>.from(raw);
            if (_sortByXp) {
              students.sort((a, b) => b.xp.compareTo(a.xp));
            }
            // else already sorted A-Z by watchAllStudents()

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _StudentCard(
                student: students[i],
                rank: _sortByXp ? i + 1 : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Sort Chip ────────────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? AppColors.primary : Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Student Card ─────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final UserModel student;
  final int? rank; // non-null when sorted by XP

  const _StudentCard({required this.student, this.rank});

  Color get _levelColor {
    switch (student.levelNumber) {
      case 5:
        return AppColors.badgeGold;
      case 4:
        return AppColors.secondary;
      case 3:
        return AppColors.info;
      case 2:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank badge (when sorted by XP)
            if (rank != null) ...[
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: rank! <= 3 ? 16 : 13,
                    color: rank == 1
                        ? AppColors.badgeGold
                        : rank == 2
                            ? Colors.grey.shade400
                            : rank == 3
                                ? const Color(0xFFCD7F32)
                                : AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Avatar with level badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: student.photoUrl != null
                      ? NetworkImage(student.photoUrl!)
                      : null,
                  child: student.photoUrl == null
                      ? Text(
                          student.displayName.isNotEmpty
                              ? student.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _levelColor,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${student.levelNumber}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Name + email + stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(student.email,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.secondary),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  // XP progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: student.levelProgress,
                      minHeight: 5,
                      backgroundColor:
                          _levelColor.withValues(alpha: 0.15),
                      valueColor:
                          AlwaysStoppedAnimation(_levelColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Stats row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _levelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          student.levelName,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _levelColor),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          color: AppColors.xpGold, size: 12),
                      const SizedBox(width: 2),
                      Text('${student.xp} XP',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.xpGold)),
                      if (student.currentStreak > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.streakOrange,
                            size: 12),
                        const SizedBox(width: 2),
                        Text('${student.currentStreak}d',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.streakOrange)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Badges count
            if (student.badges.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.badgeGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: AppColors.badgeGold, size: 18),
                    Text('${student.badges.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.badgeGold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
