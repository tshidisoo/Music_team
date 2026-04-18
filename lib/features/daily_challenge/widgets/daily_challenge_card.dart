import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../models/daily_challenge_model.dart';

/// A card for the home screen showing today's daily challenge status.
class DailyChallengeCard extends StatelessWidget {
  final DailyChallenge? challenge;
  final bool isCompleted;
  final int challengeStreak;
  final VoidCallback onTap;

  const DailyChallengeCard({
    super.key,
    required this.challenge,
    required this.isCompleted,
    required this.challengeStreak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.08),
                      AppColors.success.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.streakOrange.withValues(alpha: 0.08),
                      AppColors.secondary.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.streakOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.local_fire_department_rounded,
                  color: isCompleted
                      ? AppColors.success
                      : AppColors.streakOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted
                          ? 'Daily Challenge Complete!'
                          : "Today's Challenge",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.streakOrange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (challenge != null)
                      Text(
                        isCompleted
                            ? 'Come back tomorrow for more!'
                            : '${DailyChallengeService.gameTypeDisplayName(challenge!.gameType)} — ${challenge!.lessonTitle}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (challengeStreak > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: AppColors.streakOrange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$challengeStreak day streak',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.streakOrange,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow / XP multiplier
              if (!isCompleted && challenge?.xpMultiplier != null && challenge!.xpMultiplier > 1.0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${challenge!.xpMultiplier}x XP',
                    style: const TextStyle(
                      color: AppColors.xpGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
