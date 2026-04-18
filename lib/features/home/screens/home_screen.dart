import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../../core/services/feature_toggle_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import '../../daily_challenge/models/daily_challenge_model.dart';
import '../../daily_challenge/widgets/daily_challenge_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh handled by StreamBuilder below
        },
        child: CustomScrollView(
          slivers: [
            // Gradient header
            SliverToBoxAdapter(
              child: _HomeHeader(user: user),
            ),
            // Content cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _StreakXpCard(user: user),
                  const SizedBox(height: 12),
                  _DailyChallengeHomeCardWrapper(uid: user.uid),
                  const SizedBox(height: 16),
                  _QuickAccessGrid(user: user),
                  const SizedBox(height: 16),
                  _LeaderboardPreview(uid: user.uid),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final UserModel user;
  const _HomeHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.displayName.split(' ').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.xpGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            user.levelName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Avatar circle
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Streak + XP Card ─────────────────────────────────────────────────────────

class _StreakXpCard extends StatelessWidget {
  final UserModel user;
  const _StreakXpCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP level name + bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user.levelName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _levelColor(user.levelName),
                      fontWeight: FontWeight.w800,
                    )),
                Text(
                  '${user.xp} XP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: user.levelProgress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _nextLevelText(user),
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 28),
            // Streak row
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.streakOrange, size: 28),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.currentStreak} day streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user.currentStreak > 0
                          ? 'Longest: ${user.longestStreak} days'
                          : AppStrings.noStreakYet,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'Maestro':
        return AppColors.levelMaestro;
      case 'Musician':
        return AppColors.levelMusician;
      case 'Student':
        return AppColors.levelStudent;
      case 'Apprentice':
        return AppColors.levelApprentice;
      default:
        return AppColors.levelNovice;
    }
  }

  String _nextLevelText(UserModel user) {
    final thresholds = [0, 100, 300, 700, 1500];
    final names = AppConstants.levelThresholds.keys.toList();
    final xp = user.xp;
    for (int i = 0; i < thresholds.length - 1; i++) {
      if (xp < thresholds[i + 1]) {
        final remaining = thresholds[i + 1] - xp;
        return '$remaining XP to ${names[i + 1]}';
      }
    }
    return 'Maximum level reached — Maestro!';
  }
}

// ─── Daily Challenge Wrapper (respects teacher toggle) ───────────────────────

class _DailyChallengeHomeCardWrapper extends StatelessWidget {
  final String uid;
  const _DailyChallengeHomeCardWrapper({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, bool>>(
      stream: FeatureToggleService().watchToggles(),
      builder: (context, snapshot) {
        final toggles = snapshot.data ?? {'daily_challenge': true};
        if (!(toggles['daily_challenge'] ?? true)) {
          return const SizedBox.shrink();
        }
        return _DailyChallengeHomeCard(uid: uid);
      },
    );
  }
}

// ─── Daily Challenge Card (Home) ──────────────────────────────────────────────

class _DailyChallengeHomeCard extends StatefulWidget {
  final String uid;
  const _DailyChallengeHomeCard({required this.uid});

  @override
  State<_DailyChallengeHomeCard> createState() =>
      _DailyChallengeHomeCardState();
}

class _DailyChallengeHomeCardState extends State<_DailyChallengeHomeCard> {
  final _service = DailyChallengeService();
  bool _isCompleted = false;
  bool _isDisabled = false;
  int _streak = 0;
  DailyChallenge? _challenge;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final challenge = await _service.getTodaysChallenge();
    if (challenge == null) {
      if (mounted) setState(() => _isDisabled = true);
      return;
    }
    final completion =
        await _service.getCompletion(widget.uid, challenge.dateKey);
    final streak = await _service.getDailyChallengeStreak(widget.uid);
    if (mounted) {
      setState(() {
        _challenge = challenge;
        _isCompleted = completion != null;
        _streak = streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisabled) return const SizedBox.shrink();
    return DailyChallengeCard(
      challenge: _challenge,
      isCompleted: _isCompleted,
      challengeStreak: _streak,
      onTap: () => context.go(AppRoutes.studentDailyChallenge),
    );
  }
}

// ─── Quick Access Grid ────────────────────────────────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  final UserModel user;
  const _QuickAccessGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, bool>>(
      stream: FeatureToggleService().watchToggles(),
      builder: (context, snapshot) {
        final toggles = snapshot.data ??
            {'piano': true, 'ear_training': true, 'daily_challenge': true, 'battle': true};

        final cards = <Widget>[
          _QuickCard(
            icon: Icons.menu_book_rounded,
            label: AppStrings.lessons,
            color: AppColors.primary,
            onTap: () => context.go(AppRoutes.studentLessons),
          ),
          _QuickCard(
            icon: Icons.gamepad_rounded,
            label: AppStrings.practice,
            color: AppColors.secondary,
            onTap: () => context.go(AppRoutes.studentPractice),
          ),
          if (toggles['piano'] ?? true)
            _QuickCard(
              icon: Icons.piano_rounded,
              label: 'Piano',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.go(AppRoutes.studentPiano),
            ),
          if (toggles['ear_training'] ?? true)
            _QuickCard(
              icon: Icons.hearing_rounded,
              label: 'Ear Training',
              color: const Color(0xFF06B6D4),
              onTap: () => context.go(AppRoutes.studentEarTraining),
            ),
          if (toggles['battle'] ?? true)
            _QuickCard(
              icon: Icons.sports_esports_rounded,
              label: 'Battle',
              color: AppColors.error,
              onTap: () => context.go(AppRoutes.studentBattle),
            ),
          _QuickCard(
            icon: Icons.assignment_rounded,
            label: AppStrings.projects,
            color: AppColors.info,
            onTap: () => context.go(AppRoutes.studentProjects),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Access',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: cards,
            ),
          ],
        );
      },
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
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
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Leaderboard Preview ──────────────────────────────────────────────────────

class _LeaderboardPreview extends StatelessWidget {
  final String uid;
  const _LeaderboardPreview({required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.leaderboard,
                style: theme.textTheme.headlineSmall),
            TextButton(
              onPressed: () => context.go(AppRoutes.studentProfile),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<UserModel>>(
          stream: UserService().watchLeaderboard(limit: 5),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: users.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final u = entry.value;
                    final isMe = u.uid == uid;
                    return ListTile(
                      leading: _RankBadge(rank: rank),
                      title: Text(
                        u.displayName,
                        style: TextStyle(
                          fontWeight:
                              isMe ? FontWeight.w800 : FontWeight.w600,
                          color: isMe ? AppColors.primary : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.xpGold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${u.xp} XP',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isMe ? AppColors.primary : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (rank) {
      case 1:
        color = AppColors.badgeGold;
      case 2:
        color = AppColors.badgeSilver;
      case 3:
        color = AppColors.badgeBronze;
      default:
        color = AppColors.textSecondaryLight;
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
