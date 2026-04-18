import 'package:equatable/equatable.dart';

class PianoState extends Equatable {
  final String mode; // 'freePlay', 'scale', 'interval', 'triad'
  final String? challengeName;
  final String? challengeDescription;
  final List<int> expectedNotes; // MIDI notes to play in sequence
  final List<int> playedNotes; // notes the user has played so far
  final List<int> highlightCorrect; // notes to highlight green
  final List<int> highlightWrong; // notes to highlight red
  final int score;
  final int totalChallenges;
  final int completedChallenges;
  final bool challengeComplete; // current challenge done
  final bool allDone; // all challenges in session done

  const PianoState({
    this.mode = 'freePlay',
    this.challengeName,
    this.challengeDescription,
    this.expectedNotes = const [],
    this.playedNotes = const [],
    this.highlightCorrect = const [],
    this.highlightWrong = const [],
    this.score = 0,
    this.totalChallenges = 5,
    this.completedChallenges = 0,
    this.challengeComplete = false,
    this.allDone = false,
  });

  PianoState copyWith({
    String? mode,
    String? challengeName,
    String? challengeDescription,
    List<int>? expectedNotes,
    List<int>? playedNotes,
    List<int>? highlightCorrect,
    List<int>? highlightWrong,
    int? score,
    int? totalChallenges,
    int? completedChallenges,
    bool? challengeComplete,
    bool? allDone,
  }) {
    return PianoState(
      mode: mode ?? this.mode,
      challengeName: challengeName ?? this.challengeName,
      challengeDescription: challengeDescription ?? this.challengeDescription,
      expectedNotes: expectedNotes ?? this.expectedNotes,
      playedNotes: playedNotes ?? this.playedNotes,
      highlightCorrect: highlightCorrect ?? this.highlightCorrect,
      highlightWrong: highlightWrong ?? this.highlightWrong,
      score: score ?? this.score,
      totalChallenges: totalChallenges ?? this.totalChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      challengeComplete: challengeComplete ?? this.challengeComplete,
      allDone: allDone ?? this.allDone,
    );
  }

  @override
  List<Object?> get props => [
        mode, challengeName, challengeDescription,
        expectedNotes, playedNotes, highlightCorrect, highlightWrong,
        score, totalChallenges, completedChallenges,
        challengeComplete, allDone,
      ];
}
