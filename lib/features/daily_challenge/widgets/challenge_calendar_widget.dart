import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/daily_challenge_model.dart';

class ChallengeCalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, DailyChallengeCompletion> completions;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const ChallengeCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.completions,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: onPreviousMonth,
                ),
                Text(
                  '${_monthName(month)} $year',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  // Disable future months
                  onPressed: (year < now.year ||
                          (year == now.year && month < now.month))
                      ? onNextMonth
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            d,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox();

                final day = index - startWeekday + 1;
                final dateKey =
                    '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                final isCompleted = completions.containsKey(dateKey);
                final isToday = year == now.year &&
                    month == now.month &&
                    day == now.day;
                final isFuture = DateTime(year, month, day).isAfter(now);

                return Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.15)
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : null,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.success, size: 16)
                          : Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isToday ? FontWeight.w800 : FontWeight.w500,
                                color: isFuture
                                    ? AppColors.textSecondaryLight
                                        .withValues(alpha: 0.4)
                                    : isToday
                                        ? AppColors.primary
                                        : null,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month];
  }
}
