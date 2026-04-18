/// Piano challenge definitions: scales, intervals, and triads.
class PianoChallenges {
  PianoChallenges._();

  // ─── Scales ────────────────────────────────────────────────────────────────

  static const scales = <ScaleChallenge>[
    ScaleChallenge(
      name: 'C Major Scale',
      notes: [60, 62, 64, 65, 67, 69, 71, 72], // C4 D4 E4 F4 G4 A4 B4 C5
      description: 'All white keys from C to C',
    ),
    ScaleChallenge(
      name: 'G Major Scale',
      notes: [67, 69, 71, 72, 74, 76, 78, 79], // G4 A4 B4 C5 D5 E5 F#5 G5
      description: 'One sharp: F#',
    ),
    ScaleChallenge(
      name: 'D Major Scale',
      notes: [62, 64, 66, 67, 69, 71, 73, 74], // D4 E4 F#4 G4 A4 B4 C#5 D5
      description: 'Two sharps: F# and C#',
    ),
    ScaleChallenge(
      name: 'F Major Scale',
      notes: [65, 67, 69, 70, 72, 74, 76, 77], // F4 G4 A4 Bb4 C5 D5 E5 F5
      description: 'One flat: Bb',
    ),
    ScaleChallenge(
      name: 'A Minor Scale (Natural)',
      notes: [57, 59, 60, 62, 64, 65, 67, 69], // A3 B3 C4 D4 E4 F4 G4 A4
      description: 'Relative minor of C Major — all white keys',
    ),
  ];

  // ─── Intervals ─────────────────────────────────────────────────────────────

  static const intervals = <IntervalChallenge>[
    IntervalChallenge(
      name: 'Minor 2nd',
      semitones: 1,
      rootNote: 60,
      description: 'One semitone up from C',
    ),
    IntervalChallenge(
      name: 'Major 2nd',
      semitones: 2,
      rootNote: 60,
      description: 'One tone up from C (a whole step)',
    ),
    IntervalChallenge(
      name: 'Minor 3rd',
      semitones: 3,
      rootNote: 60,
      description: 'Three semitones up from C',
    ),
    IntervalChallenge(
      name: 'Major 3rd',
      semitones: 4,
      rootNote: 60,
      description: 'Four semitones up from C',
    ),
    IntervalChallenge(
      name: 'Perfect 4th',
      semitones: 5,
      rootNote: 60,
      description: 'Five semitones up from C',
    ),
    IntervalChallenge(
      name: 'Perfect 5th',
      semitones: 7,
      rootNote: 60,
      description: 'Seven semitones up from C',
    ),
    IntervalChallenge(
      name: 'Octave',
      semitones: 12,
      rootNote: 60,
      description: 'Twelve semitones — same note, higher pitch',
    ),
  ];

  // ─── Triads ────────────────────────────────────────────────────────────────

  static const triads = <TriadChallenge>[
    TriadChallenge(
      name: 'C Major Triad',
      notes: [60, 64, 67], // C E G
      type: 'Major',
      description: 'Root + Major 3rd + Perfect 5th',
    ),
    TriadChallenge(
      name: 'C Minor Triad',
      notes: [60, 63, 67], // C Eb G
      type: 'Minor',
      description: 'Root + Minor 3rd + Perfect 5th',
    ),
    TriadChallenge(
      name: 'G Major Triad',
      notes: [67, 71, 74], // G B D
      type: 'Major',
      description: 'Root + Major 3rd + Perfect 5th',
    ),
    TriadChallenge(
      name: 'D Minor Triad',
      notes: [62, 65, 69], // D F A
      type: 'Minor',
      description: 'Root + Minor 3rd + Perfect 5th',
    ),
    TriadChallenge(
      name: 'F Major Triad',
      notes: [65, 69, 72], // F A C
      type: 'Major',
      description: 'Root + Major 3rd + Perfect 5th',
    ),
    TriadChallenge(
      name: 'C Diminished Triad',
      notes: [60, 63, 66], // C Eb Gb
      type: 'Diminished',
      description: 'Root + Minor 3rd + Diminished 5th',
    ),
    TriadChallenge(
      name: 'C Augmented Triad',
      notes: [60, 64, 68], // C E G#
      type: 'Augmented',
      description: 'Root + Major 3rd + Augmented 5th',
    ),
  ];

  /// Get a random scale challenge.
  static ScaleChallenge randomScale() {
    final shuffled = List.of(scales)..shuffle();
    return shuffled.first;
  }

  /// Get a random interval challenge with a random root note.
  /// Ensures the target note stays within keyboard range (48–84).
  static IntervalChallenge randomInterval() {
    final shuffled = List.of(intervals)..shuffle();
    final challenge = shuffled.first;
    // Randomize root note — ensure root + semitones <= 84 (C6)
    final maxRoot = 84 - challenge.semitones;
    final roots = [48, 50, 52, 53, 55, 57, 59, 60, 62, 64, 65, 67, 69, 71, 72]
        .where((r) => r <= maxRoot)
        .toList();
    roots.shuffle();
    return IntervalChallenge(
      name: challenge.name,
      semitones: challenge.semitones,
      rootNote: roots.first,
      description: challenge.description,
    );
  }

  /// Get a random triad challenge.
  static TriadChallenge randomTriad() {
    final shuffled = List.of(triads)..shuffle();
    return shuffled.first;
  }
}

class ScaleChallenge {
  final String name;
  final List<int> notes; // MIDI numbers
  final String description;

  const ScaleChallenge({
    required this.name,
    required this.notes,
    required this.description,
  });
}

class IntervalChallenge {
  final String name;
  final int semitones;
  final int rootNote; // MIDI number
  final String description;

  const IntervalChallenge({
    required this.name,
    required this.semitones,
    required this.rootNote,
    required this.description,
  });

  int get targetNote => rootNote + semitones;
  List<int> get expectedNotes => [rootNote, targetNote];
}

class TriadChallenge {
  final String name;
  final List<int> notes; // MIDI numbers
  final String type;
  final String description;

  const TriadChallenge({
    required this.name,
    required this.notes,
    required this.type,
    required this.description,
  });
}
