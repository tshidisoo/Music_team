import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/feature_toggle_service.dart';
import '../../../core/services/lesson_service.dart';
import '../../../core/services/project_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/user_model.dart';
import '../../../app/router.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 20, 20, 28),
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
                        child: const Icon(Icons.dashboard_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teacher Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              )),
                          Text('Manage your music class',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Class stats ───────────────────────────────────────────
                _ClassStatsCard(),
                const SizedBox(height: 16),

                // ── Feature Management ──────────────────────────────────
                Text('Feature Management',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Enable or disable features for students this week',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                const _FeatureTogglesCard(),
                const SizedBox(height: 16),

                // ── Daily Challenge Schedule ────────────────────────────
                Text('Daily Challenge Schedule',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Set topics and game types for each day of the week',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                _DailyScheduleCard(),
                const SizedBox(height: 16),

                // ── Quick actions ─────────────────────────────────────────
                Text('Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                _QuickActionsGrid(),
                const SizedBox(height: 16),

                // ── Class Activity ──────────────────────────────────────
                Text('Class Activity',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const _ClassActivityCard(),
                const SizedBox(height: 16),

                // ── Admin tools ───────────────────────────────────────────
                Text('Admin Tools',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                _SeedLessonsCard(),
                const SizedBox(height: 12),
                _SeedProjectsCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Class Stats ──────────────────────────────────────────────────────────────

class _ClassStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: UserService().watchAllStudents(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];
        final totalXp = students.fold<int>(0, (sum, s) => sum + s.xp);
        final avgXp =
            students.isEmpty ? 0 : (totalXp / students.length).round();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.teacherStudents),
                      child: _StatItem(
                        icon: Icons.people_rounded,
                        color: AppColors.primary,
                        value: '${students.length}',
                        label: 'Students',
                        tappable: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.teacherStudents),
                      child: _StatItem(
                        icon: Icons.star_rounded,
                        color: AppColors.xpGold,
                        value: '$avgXp',
                        label: 'Avg XP',
                        tappable: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.streakOrange,
                      value: students.isEmpty
                          ? '0'
                          : '${students.where((s) => s.currentStreak > 0).length}',
                      label: 'Active streaks',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool tappable;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
          if (tappable) ...[
            const SizedBox(height: 2),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 10, color: color.withValues(alpha: 0.5)),
          ],
        ],
      ),
    );
  }
}

// ─── Feature Toggles ─────────────────────────────────────────────────────────

class _FeatureTogglesCard extends StatelessWidget {
  const _FeatureTogglesCard();

  @override
  Widget build(BuildContext context) {
    final service = FeatureToggleService();
    return StreamBuilder<Map<String, bool>>(
      stream: service.watchToggles(),
      builder: (context, snapshot) {
        final toggles = snapshot.data ??
            {
              'piano': true,
              'ear_training': true,
              'daily_challenge': true,
              'battle': true,
            };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FeatureToggleRow(
                  icon: Icons.piano_rounded,
                  label: 'Virtual Piano',
                  description: 'Scales, intervals, and triad challenges',
                  color: const Color(0xFF6C3FE8),
                  enabled: toggles['piano'] ?? true,
                  onChanged: (v) => service.setFeature('piano', v),
                ),
                const Divider(height: 24),
                _FeatureToggleRow(
                  icon: Icons.hearing_rounded,
                  label: 'Ear Training',
                  description: 'Interval and chord recognition exercises',
                  color: const Color(0xFFFF8C00),
                  enabled: toggles['ear_training'] ?? true,
                  onChanged: (v) => service.setFeature('ear_training', v),
                ),
                const Divider(height: 24),
                _FeatureToggleRow(
                  icon: Icons.today_rounded,
                  label: 'Daily Challenges',
                  description: 'Daily quizzes with streak rewards',
                  color: const Color(0xFF22C55E),
                  enabled: toggles['daily_challenge'] ?? true,
                  onChanged: (v) => service.setFeature('daily_challenge', v),
                ),
                const Divider(height: 24),
                _FeatureToggleRow(
                  icon: Icons.sports_esports_rounded,
                  label: 'Quiz Battles',
                  description: 'Head-to-head multiplayer quiz challenges',
                  color: const Color(0xFFEF4444),
                  enabled: toggles['battle'] ?? true,
                  onChanged: (v) => service.setFeature('battle', v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _FeatureToggleRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.12 : 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: enabled ? color : color.withValues(alpha: 0.3), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: enabled ? null : Colors.grey,
                  )),
              Text(description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? null
                            : Colors.grey.withValues(alpha: 0.6),
                      )),
            ],
          ),
        ),
        Switch.adaptive(
          value: enabled,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }
}

// ─── Daily Schedule Card ─────────────────────────────────────────────────────

class _DailyScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go(AppRoutes.teacherDailySchedule),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly Schedule',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      'Pick topics, game types, and active days for each day of the week',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Class Activity ──────────────────────────────────────────────────────────

class _ClassActivityCard extends StatelessWidget {
  const _ClassActivityCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: UserService().watchAllStudents(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('No students yet',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        }

        // Top 5 students by XP
        final sorted = List.of(students)
          ..sort((a, b) => b.xp.compareTo(a.xp));
        final top = sorted.take(5).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.xpGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.leaderboard_rounded,
                          color: AppColors.xpGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Top Performers',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...top.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final student = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            rank <= 3
                                ? ['', '1st', '2nd', '3rd'][rank]
                                : '${rank}th',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: rank == 1
                                  ? AppColors.xpGold
                                  : rank == 2
                                      ? Colors.grey.shade500
                                      : rank == 3
                                          ? const Color(0xFFCD7F32)
                                          : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            student.displayName.isNotEmpty
                                ? student.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(student.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.xpGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${student.xp} XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.xpGold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (student.currentStreak > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  color: AppColors.streakOrange, size: 14),
                              Text(
                                '${student.currentStreak}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: AppColors.streakOrange,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.teacherStudents),
                    child: const Text('View All Students'),
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

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _ActionCard(
          icon: Icons.people_rounded,
          label: 'View Students',
          color: AppColors.primary,
          onTap: () => context.go(AppRoutes.teacherStudents),
        ),
        _ActionCard(
          icon: Icons.assignment_rounded,
          label: 'Projects',
          color: AppColors.secondary,
          onTap: () => context.go(AppRoutes.teacherProjects),
        ),
        _ActionCard(
          icon: Icons.rate_review_rounded,
          label: 'Submissions',
          color: AppColors.info,
          onTap: () => context.go(AppRoutes.teacherSubmissions),
        ),
        _ActionCard(
          icon: Icons.leaderboard_rounded,
          label: 'Leaderboard',
          color: AppColors.badgeGold,
          onTap: () => context.go(AppRoutes.teacherStudents),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Seed Lessons Card ────────────────────────────────────────────────────────

class _SeedLessonsCard extends StatefulWidget {
  @override
  State<_SeedLessonsCard> createState() => _SeedLessonsCardState();
}

class _SeedLessonsCardState extends State<_SeedLessonsCard> {
  bool _loading = false;
  String? _result;

  Future<void> _seed() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      await LessonService().seedLessons();
      setState(() => _result = 'All lessons seeded successfully!');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.library_add_rounded,
                      color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seed Lesson Content',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                          'Populate Firestore with all AB Guide chapters (Parts I & II)',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _result!.startsWith('Error')
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _result!.startsWith('Error')
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      color: _result!.startsWith('Error')
                          ? AppColors.error
                          : AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_result!,
                          style: TextStyle(
                            color: _result!.startsWith('Error')
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _seed,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload_rounded),
                label: Text(_loading ? 'Seeding...' : 'Seed All Lessons'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Seed Projects Card ───────────────────────────────────────────────────────

class _SeedProjectsCard extends StatefulWidget {
  @override
  State<_SeedProjectsCard> createState() => _SeedProjectsCardState();
}

class _SeedProjectsCardState extends State<_SeedProjectsCard> {
  bool _loading = false;
  String? _result;

  Future<void> _seed(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _result = 'Error: Not logged in');
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      await ProjectService().seedProjects(uid);
      setState(() => _result = '10 projects seeded successfully!');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seed Project Content',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                          'Load 10 pre-built projects (theory + Maestro tasks)',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _result!.startsWith('Error')
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _result!.startsWith('Error')
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      color: _result!.startsWith('Error')
                          ? AppColors.error
                          : AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_result!,
                          style: TextStyle(
                            color: _result!.startsWith('Error')
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : () => _seed(context),
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download_rounded),
                label: Text(_loading ? 'Seeding...' : 'Seed 10 Projects'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
