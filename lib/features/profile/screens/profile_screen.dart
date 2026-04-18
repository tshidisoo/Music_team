import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/theme_notifier.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/blocs/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final uid = authState.user.uid;

    return StreamBuilder<UserModel?>(
      stream: UserService().watchUser(uid),
      builder: (context, snapshot) {
        final user = snapshot.data ?? authState.user;
        return _ProfileView(user: user);
      },
    );
  }
}

class _ProfileView extends StatelessWidget {
  final UserModel user;
  const _ProfileView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────────────
          SliverToBoxAdapter(child: _ProfileHeader(user: user)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // ── XP / Level card ─────────────────────────────────────
                _XpCard(user: user),
                const SizedBox(height: 16),

                // ── Stats row ────────────────────────────────────────────
                _StatsRow(user: user),
                const SizedBox(height: 16),

                // ── Badges ───────────────────────────────────────────────
                _BadgesSection(user: user),
                const SizedBox(height: 16),

                // ── Settings ─────────────────────────────────────────────
                _SettingsSection(user: user),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 32),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${user.levelNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.xpGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  user.levelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Card ──────────────────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  final UserModel user;
  const _XpCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${user.xp} XP',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: user.levelProgress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user.levelName,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(_nextLevelText(user),
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _nextLevelText(UserModel user) {
    final thresholds = AppConstants.levelThresholds.values.toList();
    final names = AppConstants.levelThresholds.keys.toList();
    for (int i = 0; i < thresholds.length - 1; i++) {
      if (user.xp < thresholds[i + 1]) {
        return '${thresholds[i + 1] - user.xp} XP to ${names[i + 1]}';
      }
    }
    return 'Max level reached!';
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.streakOrange,
          value: '${user.currentStreak}',
          label: 'Day streak',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.badgeGold,
          value: '${user.badges.length}',
          label: 'Badges',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.xpGold,
          value: '${user.xp}',
          label: 'Total XP',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Badges ───────────────────────────────────────────────────────────────────

class _BadgesSection extends StatelessWidget {
  final UserModel user;
  const _BadgesSection({required this.user});

  static const _allBadges = [
    _BadgeDef(
        id: 'first_note',
        icon: Icons.music_note_rounded,
        label: 'First Note',
        desc: 'Complete your first lesson',
        color: AppColors.primary),
    _BadgeDef(
        id: 'perfect_pitch',
        icon: Icons.stars_rounded,
        label: 'Perfect Pitch',
        desc: 'Score 100% on a quiz',
        color: AppColors.badgeGold),
    _BadgeDef(
        id: 'on_a_roll',
        icon: Icons.local_fire_department_rounded,
        label: 'On A Roll',
        desc: '7-day streak',
        color: AppColors.streakOrange),
    _BadgeDef(
        id: 'project_star',
        icon: Icons.assignment_turned_in_rounded,
        label: 'Project Star',
        desc: 'Submit your first project',
        color: AppColors.info),
    _BadgeDef(
        id: 'leaderboard_king',
        icon: Icons.emoji_events_rounded,
        label: 'Top 3',
        desc: 'Reach top 3 on leaderboard',
        color: AppColors.badgeGold),
    _BadgeDef(
        id: 'ten_lessons',
        icon: Icons.menu_book_rounded,
        label: 'Scholar',
        desc: 'Complete 10 lessons',
        color: AppColors.levelMusician),
    _BadgeDef(
        id: 'maestro',
        icon: Icons.workspace_premium_rounded,
        label: 'Maestro',
        desc: 'Reach Maestro level',
        color: AppColors.levelMaestro),
    _BadgeDef(
        id: 'early_bird',
        icon: Icons.wb_sunny_rounded,
        label: 'Early Bird',
        desc: 'Log in for 30 days',
        color: AppColors.secondary),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _allBadges.map((badge) {
            final earned = user.badges.contains(badge.id);
            return _BadgeTile(badge: badge, earned: earned);
          }).toList(),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final _BadgeDef badge;
  final bool earned;
  const _BadgeTile({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: earned ? badge.desc : 'Locked: ${badge.desc}',
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: earned
                  ? badge.color.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: earned
                    ? badge.color.withValues(alpha: 0.5)
                    : Theme.of(context).dividerColor,
                width: 1.5,
              ),
            ),
            child: Icon(
              badge.icon,
              color: earned
                  ? badge.color
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: earned
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BadgeDef {
  final String id;
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  const _BadgeDef({
    required this.id,
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
  });
}

// ─── Settings Section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final UserModel user;
  const _SettingsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              // Edit name
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: AppColors.primary, size: 20),
                ),
                title: const Text('Display Name',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(user.displayName),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => _showEditNameDialog(context, user),
              ),
              const Divider(height: 1, indent: 56),

              // Theme toggle
              ListenableBuilder(
                listenable: ThemeNotifier.instance,
                builder: (context, _) {
                  final isDark = ThemeNotifier.instance.isDark;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    title: const Text('Theme',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(isDark ? 'Dark mode' : 'Light mode'),
                    trailing: Switch(
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (_) => ThemeNotifier.instance.toggle(),
                    ),
                    onTap: () => ThemeNotifier.instance.toggle(),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),

              // Logout
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 20),
                ),
                title: const Text('Log Out',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.error)),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, UserModel user) {
    final controller = TextEditingController(text: user.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Your name',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await UserService().updateDisplayName(user.uid, newName);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name updated!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content:
            const Text('Are you sure you want to log out of Music Team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthSignedOut());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
