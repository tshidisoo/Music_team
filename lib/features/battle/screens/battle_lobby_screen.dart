import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import '../bloc/battle_bloc.dart';
import '../bloc/battle_event.dart';
import '../models/battle_model.dart';
import '../services/battle_service.dart';
import 'battle_game_screen.dart';

class BattleLobbyScreen extends StatelessWidget {
  const BattleLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Battle'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Challenge'),
              Tab(text: 'Invitations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ChallengeTab(currentUser: user),
            _InvitationsTab(currentUser: user),
          ],
        ),
      ),
    );
  }
}

// ─── Challenge Tab ──────────────────────────────────────────────────────────────

class _ChallengeTab extends StatelessWidget {
  final UserModel currentUser;
  const _ChallengeTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFFF6B35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 36),
              const SizedBox(height: 8),
              const Text(
                'Challenge a Classmate!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '8 questions • Real-time scoring • Winner gets 30 XP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Student list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select an opponent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: UserService().watchAllStudents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final students = snapshot.data!
                  .where((s) => s.uid != currentUser.uid)
                  .toList();

              if (students.isEmpty) {
                return const Center(
                  child: Text('No other students available'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: students.length,
                itemBuilder: (context, i) {
                  final student = students[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          student.displayName.isNotEmpty
                              ? student.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        student.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${student.levelName} • ${student.xp} XP',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: FilledButton(
                        onPressed: () => _challengeStudent(
                            context, currentUser, student),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Challenge',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _challengeStudent(
    BuildContext context,
    UserModel me,
    UserModel opponent,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              BattleBloc(myUid: me.uid, myName: me.displayName)
                ..add(CreateBattle(
                  opponentUid: opponent.uid,
                  opponentName: opponent.displayName,
                )),
          child: const BattleGameScreen(),
        ),
      ),
    );
  }
}

// ─── Invitations Tab ────────────────────────────────────────────────────────────

class _InvitationsTab extends StatelessWidget {
  final UserModel currentUser;
  const _InvitationsTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BattleModel>>(
      stream: BattleService().watchPendingBattles(currentUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final battles = snapshot.data!;
        if (battles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('No pending invitations',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Challenge a classmate or wait to be challenged!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: battles.length,
          itemBuilder: (context, i) {
            final battle = battles[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_esports_rounded,
                      color: AppColors.error),
                ),
                title: Text(
                  '${battle.player1Name} challenged you!',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${battle.questions.length} questions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.error),
                      onPressed: () =>
                          BattleService().cancelBattle(battle.id),
                    ),
                    FilledButton(
                      onPressed: () => _acceptBattle(
                          context, currentUser, battle),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Accept',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _acceptBattle(
    BuildContext context,
    UserModel me,
    BattleModel battle,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              BattleBloc(myUid: me.uid, myName: me.displayName)
                ..add(AcceptBattle(battle.id)),
          child: const BattleGameScreen(),
        ),
      ),
    );
  }
}
