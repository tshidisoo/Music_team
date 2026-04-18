import 'package:equatable/equatable.dart';

abstract class PianoEvent extends Equatable {
  const PianoEvent();
  @override
  List<Object?> get props => [];
}

/// Switch between piano modes: freePlay, scale, interval, triad.
class ChangePianoMode extends PianoEvent {
  final String mode; // 'freePlay', 'scale', 'interval', 'triad'
  const ChangePianoMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

/// A key was pressed — validate in challenge mode.
class PianoKeyPressed extends PianoEvent {
  final int midiNote;
  const PianoKeyPressed(this.midiNote);
  @override
  List<Object?> get props => [midiNote];
}

/// Load the next challenge in the current mode.
class LoadNextChallenge extends PianoEvent {}

/// Reset the current challenge attempt.
class ResetChallenge extends PianoEvent {}
