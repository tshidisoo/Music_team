/// Represents today's daily challenge — deterministically generated from the date.
class DailyChallenge {
  final DateTime date;
  final String gameType; // 'quiz', 'matching', 'trueFalse', 'flashcards', 'anagrams'
  final int partNumber;
  final int chapterNumber;
  final String lessonTitle;
  final double xpMultiplier;

  const DailyChallenge({
    required this.date,
    required this.gameType,
    required this.partNumber,
    required this.chapterNumber,
    required this.lessonTitle,
    this.xpMultiplier = 1.0,
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Tracks completion of a daily challenge.
class DailyChallengeCompletion {
  final String dateKey;
  final DateTime completedAt;
  final int xpEarned;
  final String gameType;
  final int score;
  final int total;

  const DailyChallengeCompletion({
    required this.dateKey,
    required this.completedAt,
    required this.xpEarned,
    required this.gameType,
    required this.score,
    required this.total,
  });

  factory DailyChallengeCompletion.fromMap(String dateKey, Map<String, dynamic> data) {
    return DailyChallengeCompletion(
      dateKey: dateKey,
      completedAt: (data['completedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      xpEarned: (data['xpEarned'] ?? 0) as int,
      gameType: data['gameType'] ?? '',
      score: (data['score'] ?? 0) as int,
      total: (data['total'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'completedAt': completedAt,
        'xpEarned': xpEarned,
        'gameType': gameType,
        'score': score,
        'total': total,
      };
}
