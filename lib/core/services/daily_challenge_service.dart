import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/daily_challenge/models/daily_challenge_model.dart';
import '../../features/daily_challenge/models/daily_schedule_model.dart';
import '../../features/practice/data/practice_exercises.dart';

/// Generates daily challenges — teacher-scheduled overrides take priority,
/// otherwise falls back to deterministic generation from the date.
class DailyChallengeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _scheduleDoc = 'app_config/daily_challenge_schedule';

  // All available lesson keys
  static const _lessonKeys = [
    '1-1', '1-2', '1-3', '1-4', '1-5', '1-6', '1-7',
    '1-8', '1-9', '1-10', '1-11', '1-12', '1-13',
    '2-1', '2-2', '2-3', '2-4', '2-5', '2-6', '2-7', '2-8',
  ];

  static const _gameTypes = [
    'quiz',
    'matching',
    'trueFalse',
    'flashcards',
    'anagrams',
  ];

  /// All available topics for the teacher picker.
  static List<Map<String, dynamic>> get availableTopics {
    return _lessonKeys.map((key) {
      final parts = key.split('-');
      final partNumber = int.parse(parts[0]);
      final chapterNumber = int.parse(parts[1]);
      final exerciseSet =
          PracticeExercises.getForLesson(partNumber, chapterNumber);
      return {
        'key': key,
        'partNumber': partNumber,
        'chapterNumber': chapterNumber,
        'lessonTitle': exerciseSet?.lessonTitle ?? 'Music Theory',
      };
    }).toList();
  }

  /// All available game types.
  static List<String> get gameTypes => List.unmodifiable(_gameTypes);

  // ─── Get Challenge ──────────────────────────────────────────────────────────

  /// Get today's challenge. Returns null if the teacher disabled today.
  Future<DailyChallenge?> getTodaysChallenge() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _resolveChallenge(today);
  }

  /// Get the challenge for a specific date. Returns null if disabled.
  Future<DailyChallenge?> getChallengeForDate(DateTime date) async {
    return _resolveChallenge(DateTime(date.year, date.month, date.day));
  }

  /// Check for a teacher-scheduled override, otherwise use deterministic fallback.
  Future<DailyChallenge?> _resolveChallenge(DateTime date) async {
    final dateKey = _dateKey(date);

    try {
      final scheduled = await getScheduledDay(dateKey);
      if (scheduled != null) {
        if (!scheduled.enabled) return null; // Teacher disabled this day

        final exerciseSet = PracticeExercises.getForLesson(
            scheduled.partNumber, scheduled.chapterNumber);
        final isWeekend = date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;

        return DailyChallenge(
          date: date,
          gameType: scheduled.gameType,
          partNumber: scheduled.partNumber,
          chapterNumber: scheduled.chapterNumber,
          lessonTitle: exerciseSet?.lessonTitle ?? scheduled.lessonTitle,
          xpMultiplier: isWeekend ? 1.5 : 1.0,
        );
      }
    } catch (_) {
      // Firestore unavailable — fall back to deterministic
    }

    return _challengeForDate(date);
  }

  /// Deterministic fallback — generate challenge from date hash.
  DailyChallenge _challengeForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final lessonIndex = seed % _lessonKeys.length;
    final gameIndex = (seed ~/ 7) % _gameTypes.length;

    final key = _lessonKeys[lessonIndex];
    final parts = key.split('-');
    final partNumber = int.parse(parts[0]);
    final chapterNumber = int.parse(parts[1]);

    final exerciseSet =
        PracticeExercises.getForLesson(partNumber, chapterNumber);
    final lessonTitle = exerciseSet?.lessonTitle ?? 'Music Theory';

    final isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    return DailyChallenge(
      date: date,
      gameType: _gameTypes[gameIndex],
      partNumber: partNumber,
      chapterNumber: chapterNumber,
      lessonTitle: lessonTitle,
      xpMultiplier: isWeekend ? 1.5 : 1.0,
    );
  }

  // ─── Teacher Schedule Management ────────────────────────────────────────────

  /// Get a single day's schedule override, if any.
  Future<DailyScheduleEntry?> getScheduledDay(String dateKey) async {
    final doc = await _db.doc(_scheduleDoc).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null || !data.containsKey(dateKey)) return null;
    final dayData = data[dateKey];
    if (dayData is! Map<String, dynamic>) return null;
    return DailyScheduleEntry.fromMap(dateKey, dayData);
  }

  /// Get scheduled entries for a 7-day period starting from [weekStart].
  Future<Map<String, DailyScheduleEntry>> getWeekSchedule(
      DateTime weekStart) async {
    final result = <String, DailyScheduleEntry>{};

    try {
      final doc = await _db.doc(_scheduleDoc).get();
      if (!doc.exists) return result;
      final data = doc.data() ?? {};

      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final key = _dateKey(day);
        if (data.containsKey(key) && data[key] is Map<String, dynamic>) {
          result[key] =
              DailyScheduleEntry.fromMap(key, data[key] as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    return result;
  }

  /// Set or update a single day's schedule.
  Future<void> setDaySchedule(
    String dateKey, {
    required bool enabled,
    required int partNumber,
    required int chapterNumber,
    required String gameType,
    required String lessonTitle,
  }) async {
    await _db.doc(_scheduleDoc).set(
      {
        dateKey: {
          'enabled': enabled,
          'partNumber': partNumber,
          'chapterNumber': chapterNumber,
          'gameType': gameType,
          'lessonTitle': lessonTitle,
        }
      },
      SetOptions(merge: true),
    );
  }

  /// Remove a day's schedule override (reverts to auto-generated).
  Future<void> clearDaySchedule(String dateKey) async {
    await _db.doc(_scheduleDoc).update({
      dateKey: FieldValue.delete(),
    });
  }

  /// Clear an entire week's schedule overrides.
  Future<void> clearWeekSchedule(DateTime weekStart) async {
    final updates = <String, dynamic>{};
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      updates[_dateKey(day)] = FieldValue.delete();
    }
    try {
      await _db.doc(_scheduleDoc).update(updates);
    } catch (_) {
      // Doc might not exist yet — that's fine
    }
  }

  /// Save a full week's schedule (7 days).
  Future<void> saveWeekSchedule(
    DateTime weekStart,
    List<DailyScheduleEntry> entries,
  ) async {
    final updates = <String, dynamic>{};
    for (final entry in entries) {
      updates[entry.dateKey] = entry.toMap();
    }
    await _db.doc(_scheduleDoc).set(updates, SetOptions(merge: true));
  }

  // ─── Completions & Streaks ──────────────────────────────────────────────────

  /// Check if a day's challenge has been completed.
  Future<DailyChallengeCompletion?> getCompletion(
      String uid, String dateKey) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('daily_completions')
        .doc(dateKey)
        .get();
    if (!doc.exists) return null;
    return DailyChallengeCompletion.fromMap(dateKey, doc.data()!);
  }

  /// Mark a day's challenge as completed.
  Future<void> recordCompletion(
    String uid,
    DailyChallengeCompletion completion,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('daily_completions')
        .doc(completion.dateKey)
        .set(completion.toMap());
  }

  /// Get all completions for a given month (for calendar display).
  Future<Map<String, DailyChallengeCompletion>> getMonthCompletions(
    String uid,
    int year,
    int month,
  ) async {
    final startKey = '$year-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final endKey = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('daily_completions')
        .orderBy(FieldPath.documentId)
        .startAt([startKey])
        .endAt([endKey])
        .get();

    final map = <String, DailyChallengeCompletion>{};
    for (final doc in snap.docs) {
      map[doc.id] = DailyChallengeCompletion.fromMap(doc.id, doc.data());
    }
    return map;
  }

  /// Calculate the daily challenge streak (consecutive days completed).
  Future<int> getDailyChallengeStreak(String uid) async {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _dateKey(date);
      final completion = await getCompletion(uid, dateKey);
      if (completion != null) {
        streak++;
      } else {
        // If today hasn't been completed yet, skip it and check yesterday
        if (i == 0) continue;
        break;
      }
    }
    return streak;
  }

  // ─── Display Helpers ────────────────────────────────────────────────────────

  /// Get the game type display name.
  static String gameTypeDisplayName(String gameType) {
    switch (gameType) {
      case 'quiz':
        return 'Quiz';
      case 'matching':
        return 'Matching Pairs';
      case 'trueFalse':
        return 'True or False';
      case 'flashcards':
        return 'Flashcards';
      case 'anagrams':
        return 'Anagrams';
      default:
        return 'Challenge';
    }
  }

  /// Get the icon key for a game type.
  static String gameTypeEmoji(String gameType) {
    switch (gameType) {
      case 'quiz':
        return 'quiz';
      case 'matching':
        return 'link';
      case 'trueFalse':
        return 'check_circle';
      case 'flashcards':
        return 'flip';
      case 'anagrams':
        return 'abc';
      default:
        return 'star';
    }
  }

  // ─── Utilities ──────────────────────────────────────────────────────────────

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
