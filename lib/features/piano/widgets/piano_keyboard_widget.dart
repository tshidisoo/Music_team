import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/services/audio_engine.dart';

/// A responsive piano keyboard widget spanning 2 octaves.
class PianoKeyboardWidget extends StatelessWidget {
  final int startMidi; // Default: 48 (C3)
  final int octaves;
  final ValueChanged<int> onKeyPressed;
  final List<int> highlightCorrect;
  final List<int> highlightWrong;
  final List<int> highlightHint;

  const PianoKeyboardWidget({
    super.key,
    this.startMidi = 48,
    this.octaves = 2,
    required this.onKeyPressed,
    this.highlightCorrect = const [],
    this.highlightWrong = const [],
    this.highlightHint = const [],
  });

  @override
  Widget build(BuildContext context) {
    final totalSemitones = octaves * 12 + 1; // Include final C
    final whiteKeys = <int>[];
    final blackKeys = <int>[];

    for (int i = 0; i < totalSemitones; i++) {
      final midi = startMidi + i;
      if (AudioEngine.isBlackKey(midi)) {
        blackKeys.add(midi);
      } else {
        whiteKeys.add(midi);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final whiteKeyWidth = constraints.maxWidth / whiteKeys.length;
        final whiteKeyHeight = constraints.maxHeight;
        final blackKeyWidth = whiteKeyWidth * 0.6;
        final blackKeyHeight = whiteKeyHeight * 0.6;

        return Stack(
          children: [
            // White keys
            Row(
              children: whiteKeys.map((midi) {
                return _WhiteKey(
                  midi: midi,
                  width: whiteKeyWidth,
                  height: whiteKeyHeight,
                  isCorrect: highlightCorrect.contains(midi),
                  isWrong: highlightWrong.contains(midi),
                  isHint: highlightHint.contains(midi),
                  onTap: () => onKeyPressed(midi),
                );
              }).toList(),
            ),
            // Black keys — positioned between white keys
            ...blackKeys.map((midi) {
              final position = _blackKeyPosition(
                midi, startMidi, whiteKeyWidth, blackKeyWidth,
              );
              return Positioned(
                left: position,
                top: 0,
                child: _BlackKey(
                  midi: midi,
                  width: blackKeyWidth,
                  height: blackKeyHeight,
                  isCorrect: highlightCorrect.contains(midi),
                  isWrong: highlightWrong.contains(midi),
                  isHint: highlightHint.contains(midi),
                  onTap: () => onKeyPressed(midi),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  double _blackKeyPosition(
    int midi, int startMidi, double whiteKeyWidth, double blackKeyWidth,
  ) {
    // Count white keys before this black key
    int whiteCount = 0;
    for (int i = startMidi; i < midi; i++) {
      if (!AudioEngine.isBlackKey(i)) whiteCount++;
    }
    return whiteCount * whiteKeyWidth - blackKeyWidth / 2;
  }
}

class _WhiteKey extends StatefulWidget {
  final int midi;
  final double width;
  final double height;
  final bool isCorrect;
  final bool isWrong;
  final bool isHint;
  final VoidCallback onTap;

  const _WhiteKey({
    required this.midi,
    required this.width,
    required this.height,
    required this.isCorrect,
    required this.isWrong,
    required this.isHint,
    required this.onTap,
  });

  @override
  State<_WhiteKey> createState() => _WhiteKeyState();
}

class _WhiteKeyState extends State<_WhiteKey> {
  bool _pressed = false;

  Color get _color {
    if (widget.isWrong) return AppColors.error.withValues(alpha: 0.3);
    if (widget.isCorrect) return AppColors.success.withValues(alpha: 0.3);
    if (widget.isHint) return AppColors.info.withValues(alpha: 0.2);
    if (_pressed) return AppColors.primary.withValues(alpha: 0.15);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final noteName = AudioEngine.noteNameFromMidi(widget.midi);
    final isC = widget.midi % 12 == 0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(6),
          ),
          boxShadow: _pressed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: isC
                ? Text(
                    noteName,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _BlackKey extends StatefulWidget {
  final int midi;
  final double width;
  final double height;
  final bool isCorrect;
  final bool isWrong;
  final bool isHint;
  final VoidCallback onTap;

  const _BlackKey({
    required this.midi,
    required this.width,
    required this.height,
    required this.isCorrect,
    required this.isWrong,
    required this.isHint,
    required this.onTap,
  });

  @override
  State<_BlackKey> createState() => _BlackKeyState();
}

class _BlackKeyState extends State<_BlackKey> {
  bool _pressed = false;

  Color get _color {
    if (widget.isWrong) return AppColors.error;
    if (widget.isCorrect) return AppColors.success;
    if (widget.isHint) return AppColors.info;
    if (_pressed) return Colors.grey.shade800;
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(4),
          ),
          boxShadow: _pressed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
      ),
    );
  }
}
