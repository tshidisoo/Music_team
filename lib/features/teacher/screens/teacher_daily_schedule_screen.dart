import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../daily_challenge/models/daily_schedule_model.dart';

class TeacherDailyScheduleScreen extends StatefulWidget {
  const TeacherDailyScheduleScreen({super.key});

  @override
  State<TeacherDailyScheduleScreen> createState() =>
      _TeacherDailyScheduleScreenState();
}

class _TeacherDailyScheduleScreenState
    extends State<TeacherDailyScheduleScreen> {
  final _service = DailyChallengeService();
  late DateTime _weekStart;
  bool _loading = true;
  bool _saving = false;

  // Per-day state: 7 entries (Mon-Sun)
  final List<bool> _enabled = List.filled(7, true);
  final List<int> _topicIndices = List.filled(7, 0);
  final List<int> _gameTypeIndices = List.filled(7, 0);

  late final List<Map<String, dynamic>> _topics;
  final _gameTypes = DailyChallengeService.gameTypes;

  @override
  void initState() {
    super.initState();
    _topics = DailyChallengeService.availableTopics;
    _weekStart = _mondayOf(DateTime.now());
    _loadWeek();
  }

  DateTime _mondayOf(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadWeek() async {
    setState(() => _loading = true);

    final schedule = await _service.getWeekSchedule(_weekStart);

    for (int i = 0; i < 7; i++) {
      final day = _weekStart.add(Duration(days: i));
      final key = _dateKey(day);
      final entry = schedule[key];

      if (entry != null) {
        _enabled[i] = entry.enabled;
        // Find topic index
        final topicKey = '${entry.partNumber}-${entry.chapterNumber}';
        _topicIndices[i] = _topics.indexWhere((t) => t['key'] == topicKey);
        if (_topicIndices[i] < 0) _topicIndices[i] = 0;
        // Find game type index
        _gameTypeIndices[i] = _gameTypes.indexOf(entry.gameType);
        if (_gameTypeIndices[i] < 0) _gameTypeIndices[i] = 0;
      } else {
        // Default: enabled, first topic, first game type
        _enabled[i] = true;
        _topicIndices[i] = 0;
        _gameTypeIndices[i] = 0;
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveSchedule() async {
    setState(() => _saving = true);

    final entries = <DailyScheduleEntry>[];
    for (int i = 0; i < 7; i++) {
      final day = _weekStart.add(Duration(days: i));
      final topic = _topics[_topicIndices[i]];
      entries.add(DailyScheduleEntry(
        dateKey: _dateKey(day),
        enabled: _enabled[i],
        partNumber: topic['partNumber'] as int,
        chapterNumber: topic['chapterNumber'] as int,
        gameType: _gameTypes[_gameTypeIndices[i]],
        lessonTitle: topic['lessonTitle'] as String,
      ));
    }

    await _service.saveWeekSchedule(_weekStart, entries);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Schedule saved successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearWeek() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Week Schedule?'),
        content: const Text(
            'This will remove all overrides for this week. '
            'Challenges will revert to auto-generated topics.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirm != true) return;

    await _service.clearWeekSchedule(_weekStart);
    await _loadWeek();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Week schedule cleared — auto-mode restored'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _goToPreviousWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
    _loadWeek();
  }

  void _goToNextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
    _loadWeek();
  }

  @override
  Widget build(BuildContext context) {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final weekLabel =
        '${DateFormat('MMM d').format(_weekStart)} – ${DateFormat('MMM d, yyyy').format(weekEnd)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge Schedule'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Week navigator ─────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _goToPreviousWeek,
                      ),
                      Expanded(
                        child: Text(
                          weekLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _goToNextWeek,
                      ),
                    ],
                  ),
                ),

                // ── Day cards ──────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 7,
                    itemBuilder: (context, i) => _DayCard(
                      date: _weekStart.add(Duration(days: i)),
                      enabled: _enabled[i],
                      topicIndex: _topicIndices[i],
                      gameTypeIndex: _gameTypeIndices[i],
                      topics: _topics,
                      gameTypes: _gameTypes,
                      onEnabledChanged: (v) =>
                          setState(() => _enabled[i] = v),
                      onTopicChanged: (v) =>
                          setState(() => _topicIndices[i] = v),
                      onGameTypeChanged: (v) =>
                          setState(() => _gameTypeIndices[i] = v),
                    ),
                  ),
                ),

                // ── Action buttons ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _clearWeek,
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: const Text('Clear Week'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _saveSchedule,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(
                              _saving ? 'Saving...' : 'Save Schedule'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
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

// ─── Day Card ────────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final DateTime date;
  final bool enabled;
  final int topicIndex;
  final int gameTypeIndex;
  final List<Map<String, dynamic>> topics;
  final List<String> gameTypes;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onTopicChanged;
  final ValueChanged<int> onGameTypeChanged;

  const _DayCard({
    required this.date,
    required this.enabled,
    required this.topicIndex,
    required this.gameTypeIndex,
    required this.topics,
    required this.gameTypes,
    required this.onEnabledChanged,
    required this.onTopicChanged,
    required this.onGameTypeChanged,
  });

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get _isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEE').format(date);
    final dayDate = DateFormat('MMM d').format(date);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: _isToday
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? null : Colors.grey.withValues(alpha: 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: day + toggle
            Row(
              children: [
                // Day badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isToday
                        ? AppColors.primary
                        : _isPast
                            ? Colors.grey.shade300
                            : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _isToday
                          ? Colors.white
                          : _isPast
                              ? Colors.grey.shade600
                              : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(dayDate,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (_isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.xpGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('TODAY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.xpGold,
                        )),
                  ),
                ],
                const Spacer(),
                // Active toggle
                Switch.adaptive(
                  value: enabled,
                  onChanged: onEnabledChanged,
                  activeColor: AppColors.success,
                ),
              ],
            ),

            if (!enabled)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'No challenge — day off',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (enabled) ...[
              const SizedBox(height: 10),
              // Topic dropdown
              _LabeledDropdown<int>(
                label: 'Topic',
                icon: Icons.menu_book_rounded,
                value: topicIndex,
                items: topics.asMap().entries.map((e) {
                  final t = e.value;
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      'P${t['partNumber']} Ch.${t['chapterNumber']} — ${t['lessonTitle']}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onTopicChanged(v);
                },
              ),
              const SizedBox(height: 8),
              // Game type dropdown
              _LabeledDropdown<int>(
                label: 'Game',
                icon: Icons.gamepad_rounded,
                value: gameTypeIndex,
                items: gameTypes.asMap().entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      DailyChallengeService.gameTypeDisplayName(e.value),
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onGameTypeChanged(v);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Labeled Dropdown ────────────────────────────────────────────────────────────

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              )),
        ),
        Expanded(
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
