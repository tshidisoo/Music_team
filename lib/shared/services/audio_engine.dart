import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_audio/just_audio.dart';

/// Shared audio engine for piano and ear training.
/// Uses a pool of AudioPlayer instances for polyphonic playback.
class AudioEngine {
  static final AudioEngine _instance = AudioEngine._();
  factory AudioEngine() => _instance;
  AudioEngine._();

  // Pool of players for polyphony (max 6 simultaneous notes)
  static const _poolSize = 6;
  final List<AudioPlayer> _pool = [];
  int _nextPlayer = 0;
  bool _initialized = false;

  /// Note name → asset path mapping for 3 octaves (C3–B5)
  static const _noteNames = [
    'C', 'Cs', 'D', 'Ds', 'E', 'F', 'Fs', 'G', 'Gs', 'A', 'As', 'B'
  ];

  /// Cache of already-loaded asset paths per player index to skip reloads.
  final Map<int, String> _loadedAssets = {};

  Future<void> init() async {
    if (_initialized) return;
    for (int i = 0; i < _poolSize; i++) {
      _pool.add(AudioPlayer());
    }
    _initialized = true;
  }

  /// Play a single note by MIDI number (60 = Middle C = C4).
  /// Returns immediately after starting playback — does NOT wait for the
  /// note to finish playing. This keeps the UI responsive.
  Future<void> playNote(int midiNote) async {
    if (!_initialized) await init();

    final playerIndex = _nextPlayer % _poolSize;
    final player = _pool[playerIndex];
    _nextPlayer++;

    final octave = (midiNote ~/ 12) - 1;
    final noteIndex = midiNote % 12;
    final noteName = _noteNames[noteIndex];
    final assetPath = 'assets/audio/piano/$noteName$octave.mp3';

    try {
      // Only reload the asset if it changed (avoids slow re-fetch on web)
      if (_loadedAssets[playerIndex] != assetPath) {
        await player.stop();
        await player.setAsset(assetPath);
        _loadedAssets[playerIndex] = assetPath;
      } else {
        // Same asset — just seek to start for instant replay
        await player.stop();
        await player.seek(Duration.zero);
      }
      // Fire-and-forget: start playback but don't wait for it to finish
      player.play();
    } catch (e) {
      debugPrint('AudioEngine: failed to play $assetPath — $e');
    }
  }

  /// Play a note by name (e.g., 'C4', 'Fs3', 'Bb5').
  Future<void> playNoteByName(String noteName, int octave) async {
    final noteIndex = _noteNames.indexOf(noteName);
    if (noteIndex == -1) return;
    final midi = (octave + 1) * 12 + noteIndex;
    await playNote(midi);
  }

  /// Play multiple notes simultaneously (chord).
  Future<void> playChord(List<int> midiNotes) async {
    await Future.wait(midiNotes.map((n) => playNote(n)));
  }

  /// Play notes in sequence with a delay between them (for intervals/scales).
  /// The delay is between note *starts*, not between note ends.
  Future<void> playSequence(List<int> midiNotes,
      {Duration delay = const Duration(milliseconds: 500)}) async {
    for (int i = 0; i < midiNotes.length; i++) {
      await playNote(midiNotes[i]);
      if (i < midiNotes.length - 1) {
        await Future.delayed(delay);
      }
    }
  }

  /// Pre-load a set of notes so subsequent plays are instant.
  /// Call this at init time for frequently used notes.
  Future<void> preloadNotes(List<int> midiNotes) async {
    if (!_initialized) await init();
    for (final midi in midiNotes) {
      final octave = (midi ~/ 12) - 1;
      final noteIndex = midi % 12;
      final noteName = _noteNames[noteIndex];
      final assetPath = 'assets/audio/piano/$noteName$octave.mp3';
      // Pre-load into a temporary player just to cache the asset
      try {
        final tempPlayer = AudioPlayer();
        await tempPlayer.setAsset(assetPath);
        await tempPlayer.dispose();
      } catch (_) {
        // Some assets may not exist — that's OK
      }
    }
  }

  /// Stop all playing audio.
  Future<void> stopAll() async {
    for (final player in _pool) {
      try {
        await player.stop();
      } catch (_) {}
    }
  }

  /// Dispose all players.
  Future<void> dispose() async {
    for (final player in _pool) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _pool.clear();
    _loadedAssets.clear();
    _initialized = false;
  }

  // ─── Music Theory Helpers ──────────────────────────────────────────────────

  /// Get the MIDI note number for a note name + octave.
  static int midiForNote(String noteName, int octave) {
    final idx = _noteNames.indexOf(noteName);
    if (idx == -1) return 60; // fallback to middle C
    return (octave + 1) * 12 + idx;
  }

  /// Get note display name from MIDI number.
  static String noteNameFromMidi(int midi) {
    final octave = (midi ~/ 12) - 1;
    final noteIndex = midi % 12;
    const displayNames = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
    ];
    return '${displayNames[noteIndex]}$octave';
  }

  /// Check if a MIDI note is a black key.
  static bool isBlackKey(int midi) {
    final n = midi % 12;
    return n == 1 || n == 3 || n == 6 || n == 8 || n == 10;
  }
}
