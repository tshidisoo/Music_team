/// Represents a teacher-configured daily challenge schedule entry.
class DailyScheduleEntry {
  final String dateKey;
  final bool enabled;
  final int partNumber;
  final int chapterNumber;
  final String gameType;
  final String lessonTitle;

  const DailyScheduleEntry({
    required this.dateKey,
    required this.enabled,
    required this.partNumber,
    required this.chapterNumber,
    required this.gameType,
    required this.lessonTitle,
  });

  factory DailyScheduleEntry.fromMap(String dateKey, Map<String, dynamic> data) {
    return DailyScheduleEntry(
      dateKey: dateKey,
      enabled: data['enabled'] as bool? ?? true,
      partNumber: (data['partNumber'] ?? 1) as int,
      chapterNumber: (data['chapterNumber'] ?? 1) as int,
      gameType: data['gameType'] as String? ?? 'quiz',
      lessonTitle: data['lessonTitle'] as String? ?? 'Music Theory',
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'partNumber': partNumber,
        'chapterNumber': chapterNumber,
        'gameType': gameType,
        'lessonTitle': lessonTitle,
      };
}
