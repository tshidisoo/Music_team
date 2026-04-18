import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/blocs/auth_bloc.dart';

class ResultsScreen extends StatefulWidget {
  final String gameTitle;
  final int score;
  final int total;
  final int xpEarned;
  final bool perfect;

  const ResultsScreen({
    super.key,
    required this.gameTitle,
    required this.score,
    required this.total,
    required this.xpEarned,
    required this.perfect,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _awardXp();
  }

  Future<void> _awardXp() async {
    if (widget.xpEarned <= 0) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await UserService().awardXp(authState.user.uid, widget.xpEarned);
      await UserService().updateStreak(authState.user.uid);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _trophyColor {
    final pct = widget.total == 0 ? 0.0 : widget.score / widget.total;
    if (pct >= 1.0) return AppColors.xpGold;
    if (pct >= 0.7) return AppColors.success;
    if (pct >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  IconData get _trophyIcon {
    final pct = widget.total == 0 ? 0.0 : widget.score / widget.total;
    if (pct >= 1.0) return Icons.emoji_events_rounded;
    if (pct >= 0.7) return Icons.star_rounded;
    if (pct >= 0.5) return Icons.thumb_up_rounded;
    return Icons.refresh_rounded;
  }

  String get _message {
    final pct = widget.total == 0 ? 0.0 : widget.score / widget.total;
    if (pct >= 1.0) return 'Perfect Score! 🎉';
    if (pct >= 0.8) return 'Excellent Work! 🌟';
    if (pct >= 0.6) return 'Good Job! Keep Going!';
    if (pct >= 0.4) return 'Not Bad — Try Again!';
    return 'Keep Practising! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _trophyColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(_trophyIcon, color: _trophyColor, size: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    widget.gameTitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    _message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Score card
                FadeTransition(
                  opacity: _fade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultStat(
                          label: 'Score',
                          value: '${widget.score}/${widget.total}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        Container(
                            width: 1,
                            height: 48,
                            color: Colors.white.withValues(alpha: 0.2)),
                        _ResultStat(
                          label: 'XP Earned',
                          value: '+${widget.xpEarned}',
                          icon: Icons.star_rounded,
                          color: AppColors.xpGold,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Perfect bonus badge
                if (widget.perfect)
                  FadeTransition(
                    opacity: _fade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.xpGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: AppColors.xpGold.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: AppColors.xpGold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Perfect! +50 XP Bonus',
                            style: TextStyle(
                              color: AppColors.xpGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // Buttons
                FadeTransition(
                  opacity: _fade,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context)
                        ..pop() // results
                        ..pop(), // game itself
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Back to Practice',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _fade,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(), // results only
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Try Again',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            )),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }
}
