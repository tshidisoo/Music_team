/// Ear training exercise definitions: intervals, chords, and rhythms.
class EarTrainingData {
  EarTrainingData._();

  // ─── Intervals ─────────────────────────────────────────────────────────────

  static const allIntervals = <IntervalInfo>[
    IntervalInfo(name: 'Unison', semitones: 0, difficulty: 1),
    IntervalInfo(name: 'Minor 2nd', semitones: 1, difficulty: 3),
    IntervalInfo(name: 'Major 2nd', semitones: 2, difficulty: 2),
    IntervalInfo(name: 'Minor 3rd', semitones: 3, difficulty: 2),
    IntervalInfo(name: 'Major 3rd', semitones: 4, difficulty: 2),
    IntervalInfo(name: 'Perfect 4th', semitones: 5, difficulty: 1),
    IntervalInfo(name: 'Tritone', semitones: 6, difficulty: 3),
    IntervalInfo(name: 'Perfect 5th', semitones: 7, difficulty: 1),
    IntervalInfo(name: 'Minor 6th', semitones: 8, difficulty: 3),
    IntervalInfo(name: 'Major 6th', semitones: 9, difficulty: 3),
    IntervalInfo(name: 'Minor 7th', semitones: 10, difficulty: 3),
    IntervalInfo(name: 'Major 7th', semitones: 11, difficulty: 3),
    IntervalInfo(name: 'Octave', semitones: 12, difficulty: 1),
  ];

  /// Get intervals filtered by difficulty level (1=beginner, 2=intermediate, 3=advanced).
  static List<IntervalInfo> intervalsForDifficulty(int maxDifficulty) {
    return allIntervals
        .where((i) => i.difficulty <= maxDifficulty)
        .toList();
  }

  // ─── Chords ────────────────────────────────────────────────────────────────

  static const chordTypes = <ChordInfo>[
    ChordInfo(
      name: 'Major',
      intervals: [0, 4, 7],
      difficulty: 1,
      description: 'Root + Major 3rd + Perfect 5th — bright and happy',
    ),
    ChordInfo(
      name: 'Minor',
      intervals: [0, 3, 7],
      difficulty: 1,
      description: 'Root + Minor 3rd + Perfect 5th — sad and dark',
    ),
    ChordInfo(
      name: 'Diminished',
      intervals: [0, 3, 6],
      difficulty: 2,
      description: 'Root + Minor 3rd + Diminished 5th — tense',
    ),
    ChordInfo(
      name: 'Augmented',
      intervals: [0, 4, 8],
      difficulty: 2,
      description: 'Root + Major 3rd + Augmented 5th — dreamy',
    ),
  ];

  static List<ChordInfo> chordsForDifficulty(int maxDifficulty) {
    return chordTypes.where((c) => c.difficulty <= maxDifficulty).toList();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Random root note between C3 (48) and G4 (67).
  static int randomRoot() {
    const roots = [48, 50, 52, 53, 55, 57, 59, 60, 62, 64, 65, 67];
    return (roots.toList()..shuffle()).first;
  }

  /// Generate wrong interval options for a quiz (ensuring the correct answer is included).
  static List<String> intervalOptions(
    IntervalInfo correct,
    List<IntervalInfo> pool,
  ) {
    final options = <String>{correct.name};
    final shuffled = List.of(pool)..shuffle();
    for (final interval in shuffled) {
      if (options.length >= 4) break;
      options.add(interval.name);
    }
    // If not enough, pad with remaining
    while (options.length < 4) {
      options.add(allIntervals[options.length].name);
    }
    return options.toList()..shuffle();
  }

  /// Generate wrong chord options for a quiz.
  static List<String> chordOptions(ChordInfo correct) {
    final options = <String>{correct.name};
    final shuffled = List.of(chordTypes)..shuffle();
    for (final chord in shuffled) {
      if (options.length >= 4) break;
      options.add(chord.name);
    }
    return options.toList()..shuffle();
  }
}

class IntervalInfo {
  final String name;
  final int semitones;
  final int difficulty; // 1=beginner, 2=intermediate, 3=advanced

  const IntervalInfo({
    required this.name,
    required this.semitones,
    required this.difficulty,
  });
}

class ChordInfo {
  final String name;
  final List<int> intervals; // semitones from root
  final int difficulty;
  final String description;

  const ChordInfo({
    required this.name,
    required this.intervals,
    required this.difficulty,
    required this.description,
  });

  /// Get MIDI notes for this chord given a root.
  List<int> midiNotes(int rootMidi) {
    return intervals.map((i) => rootMidi + i).toList();
  }
}
