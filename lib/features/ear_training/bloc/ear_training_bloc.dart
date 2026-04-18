import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/services/audio_engine.dart';
import '../data/ear_training_data.dart';
import 'ear_training_event.dart';
import 'ear_training_state.dart';

class EarTrainingBloc extends Bloc<EarTrainingEvent, EarTrainingState> {
  final AudioEngine _audio = AudioEngine();

  // Current question data
  IntervalInfo? _currentInterval;
  ChordInfo? _currentChord;
  int _currentRoot = 60;

  EarTrainingBloc() : super(const EarTrainingState()) {
    on<StartEarTraining>(_onStart);
    on<ReplaySound>(_onReplay);
    // SubmitAnswer uses concurrent transformer so it's never blocked
    // by audio playback from ReplaySound or NextQuestion.
    on<SubmitAnswer>(_onSubmit,
        transformer: (events, mapper) => events.asyncExpand(mapper));
    on<NextQuestion>(_onNext);

    _audio.init();
  }

  Future<void> _onStart(
    StartEarTraining event,
    Emitter<EarTrainingState> emit,
  ) async {
    emit(EarTrainingState(
      category: event.category,
      difficulty: event.difficulty,
    ));
    await _generateQuestion(emit);
  }

  Future<void> _generateQuestion(Emitter<EarTrainingState> emit) async {
    if (isClosed) return;

    _currentRoot = EarTrainingData.randomRoot();

    if (state.category == 'intervals') {
      final pool = EarTrainingData.intervalsForDifficulty(state.difficulty);
      final shuffled = List.of(pool)..shuffle();
      _currentInterval = shuffled.first;
      _currentChord = null;

      final options =
          EarTrainingData.intervalOptions(_currentInterval!, pool);

      emit(state.copyWith(
        correctAnswer: _currentInterval!.name,
        options: options,
        answered: false,
        selectedAnswer: null,
      ));
    } else {
      // chords
      final pool = EarTrainingData.chordsForDifficulty(state.difficulty);
      final shuffled = List.of(pool)..shuffle();
      _currentChord = shuffled.first;
      _currentInterval = null;

      final options = EarTrainingData.chordOptions(_currentChord!);

      emit(state.copyWith(
        correctAnswer: _currentChord!.name,
        options: options,
        answered: false,
        selectedAnswer: null,
      ));
    }

    // Auto-play the sound
    await _playCurrentSound(emit);
  }

  Future<void> _playCurrentSound(Emitter<EarTrainingState> emit) async {
    if (isClosed) return;
    emit(state.copyWith(isPlaying: true));

    try {
      if (_currentInterval != null) {
        // Play root then interval
        await _audio.playSequence(
          [_currentRoot, _currentRoot + _currentInterval!.semitones],
          delay: const Duration(milliseconds: 600),
        );
      } else if (_currentChord != null) {
        // Play chord (simultaneous notes)
        final notes = _currentChord!.midiNotes(_currentRoot);
        await _audio.playChord(notes);
      }
    } catch (e) {
      debugPrint('EarTrainingBloc: audio playback error — $e');
    }

    if (!isClosed) {
      emit(state.copyWith(isPlaying: false));
    }
  }

  Future<void> _onReplay(
    ReplaySound event,
    Emitter<EarTrainingState> emit,
  ) async {
    await _playCurrentSound(emit);
  }

  void _onSubmit(SubmitAnswer event, Emitter<EarTrainingState> emit) {
    if (state.answered) return;
    if (state.correctAnswer == null) return; // Guard: question not loaded yet

    final correct = event.answer == state.correctAnswer;
    emit(state.copyWith(
      selectedAnswer: event.answer,
      answered: true,
      score: correct ? state.score + 1 : state.score,
    ));
  }

  Future<void> _onNext(
    NextQuestion event,
    Emitter<EarTrainingState> emit,
  ) async {
    final nextQ = state.currentQuestion + 1;
    if (nextQ >= state.totalQuestions) {
      emit(state.copyWith(sessionComplete: true));
      return;
    }

    emit(state.copyWith(
      currentQuestion: nextQ,
      answered: false,
      selectedAnswer: null,
    ));

    await _generateQuestion(emit);
  }

  @override
  Future<void> close() {
    _audio.stopAll();
    return super.close();
  }
}
