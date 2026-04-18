import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/services/audio_engine.dart';
import '../data/piano_challenges.dart';
import 'piano_event.dart';
import 'piano_state.dart';

class PianoBloc extends Bloc<PianoEvent, PianoState> {
  final AudioEngine _audio = AudioEngine();

  PianoBloc() : super(const PianoState()) {
    on<ChangePianoMode>(_onChangeMode);
    // Use concurrent transformer for key presses so rapid presses
    // are never queued behind each other.
    on<PianoKeyPressed>(_onKeyPressed,
        transformer: (events, mapper) => events.asyncExpand(mapper));
    on<LoadNextChallenge>(_onNextChallenge);
    on<ResetChallenge>(_onReset);

    _audio.init();
  }

  void _onChangeMode(ChangePianoMode event, Emitter<PianoState> emit) {
    emit(PianoState(mode: event.mode));
    if (event.mode != 'freePlay') {
      add(LoadNextChallenge());
    }
  }

  void _onNextChallenge(LoadNextChallenge event, Emitter<PianoState> emit) {
    if (state.completedChallenges >= state.totalChallenges) {
      emit(state.copyWith(allDone: true));
      return;
    }

    switch (state.mode) {
      case 'scale':
        final challenge = PianoChallenges.randomScale();
        emit(state.copyWith(
          challengeName: challenge.name,
          challengeDescription: challenge.description,
          expectedNotes: challenge.notes,
          playedNotes: [],
          highlightCorrect: [],
          highlightWrong: [],
          challengeComplete: false,
        ));
      case 'interval':
        final challenge = PianoChallenges.randomInterval();
        emit(state.copyWith(
          challengeName: challenge.name,
          challengeDescription:
              'Play ${AudioEngine.noteNameFromMidi(challenge.rootNote)} then ${AudioEngine.noteNameFromMidi(challenge.targetNote)}',
          expectedNotes: challenge.expectedNotes,
          playedNotes: [],
          highlightCorrect: [],
          highlightWrong: [],
          challengeComplete: false,
        ));
      case 'triad':
        final challenge = PianoChallenges.randomTriad();
        emit(state.copyWith(
          challengeName: challenge.name,
          challengeDescription: challenge.description,
          expectedNotes: challenge.notes,
          playedNotes: [],
          highlightCorrect: [],
          highlightWrong: [],
          challengeComplete: false,
        ));
    }
  }

  Future<void> _onKeyPressed(
    PianoKeyPressed event,
    Emitter<PianoState> emit,
  ) async {
    // Play the sound — fire and forget, don't block the handler
    _audio.playNote(event.midiNote);

    // In free play mode, just play the sound — no validation
    if (state.mode == 'freePlay') return;

    // Don't accept input if challenge is complete
    if (state.challengeComplete) return;

    final nextIndex = state.playedNotes.length;
    final expected = state.expectedNotes;

    if (nextIndex >= expected.length) return;

    if (state.mode == 'triad') {
      // For triads, order doesn't matter — check if the note is in the expected set
      // and hasn't been played yet
      if (expected.contains(event.midiNote) &&
          !state.playedNotes.contains(event.midiNote)) {
        final newPlayed = [...state.playedNotes, event.midiNote];
        final newCorrect = [...state.highlightCorrect, event.midiNote];

        if (newPlayed.length == expected.length) {
          // Challenge complete!
          emit(state.copyWith(
            playedNotes: newPlayed,
            highlightCorrect: newCorrect,
            challengeComplete: true,
            score: state.score + 1,
            completedChallenges: state.completedChallenges + 1,
          ));
        } else {
          emit(state.copyWith(
            playedNotes: newPlayed,
            highlightCorrect: newCorrect,
          ));
        }
      } else {
        // Wrong note
        emit(state.copyWith(
          highlightWrong: [...state.highlightWrong, event.midiNote],
        ));
        await Future.delayed(const Duration(milliseconds: 500));
        if (!isClosed) {
          emit(state.copyWith(highlightWrong: []));
        }
      }
    } else {
      // For scales and intervals — sequential order matters
      if (event.midiNote == expected[nextIndex]) {
        final newPlayed = [...state.playedNotes, event.midiNote];
        final newCorrect = [...state.highlightCorrect, event.midiNote];

        if (newPlayed.length == expected.length) {
          emit(state.copyWith(
            playedNotes: newPlayed,
            highlightCorrect: newCorrect,
            challengeComplete: true,
            score: state.score + 1,
            completedChallenges: state.completedChallenges + 1,
          ));
        } else {
          emit(state.copyWith(
            playedNotes: newPlayed,
            highlightCorrect: newCorrect,
          ));
        }
      } else {
        emit(state.copyWith(
          highlightWrong: [...state.highlightWrong, event.midiNote],
        ));
        await Future.delayed(const Duration(milliseconds: 500));
        if (!isClosed) {
          emit(state.copyWith(highlightWrong: []));
        }
      }
    }
  }

  void _onReset(ResetChallenge event, Emitter<PianoState> emit) {
    emit(state.copyWith(
      playedNotes: [],
      highlightCorrect: [],
      highlightWrong: [],
      challengeComplete: false,
    ));
  }

  @override
  Future<void> close() {
    _audio.stopAll();
    return super.close();
  }
}
