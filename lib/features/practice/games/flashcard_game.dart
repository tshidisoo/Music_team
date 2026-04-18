import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_models.dart';
import 'results_screen.dart';

class FlashcardGame extends StatefulWidget {
  final LessonExerciseSet exerciseSet;

  const FlashcardGame({super.key, required this.exerciseSet});

  @override
  State<FlashcardGame> createState() => _FlashcardGameState();
}

class _FlashcardGameState extends State<FlashcardGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _isFront = true;
  int _currentIndex = 0;
  int _knownCount = 0;
  List<FlashCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.exerciseSet.flashcards);
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flip() async {
    if (_flipCtrl.isAnimating) return;
    if (_isFront) {
      await _flipCtrl.forward();
    } else {
      await _flipCtrl.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _answer(bool known) {
    if (known) _knownCount++;
    if (_isFront == false) {
      _flipCtrl.reverse();
    }
    setState(() => _isFront = true);

    if (_currentIndex < _cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      final xp = _knownCount * 2 + (_knownCount == _cards.length ? 10 : 0);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            gameTitle: 'Flashcards',
            score: _knownCount,
            total: _cards.length,
            xpEarned: xp,
            perfect: _knownCount == _cards.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseSet.lessonTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Card ${_currentIndex + 1} of ${_cards.length}',
                        style: Theme.of(context).textTheme.bodySmall),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 4),
                        Text('$_knownCount known',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Flip instruction
          Text(
            _isFront ? 'TAP CARD TO REVEAL ANSWER' : 'TAP CARD TO FLIP BACK',
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (context, child) {
                    final angle = _flipAnim.value * pi;
                    final isShowingFront = angle <= pi / 2;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isShowingFront
                          ? _CardFace(
                              text: card.front,
                              label: '❓ QUESTION',
                              gradient: AppColors.primaryGradient,
                              textColor: Colors.white,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _CardFace(
                                text: card.back,
                                label: '✅ ANSWER',
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Know it / Not yet buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isFront ? null : () => _answer(false),
                    icon: const Icon(Icons.close_rounded, color: AppColors.error),
                    label: const Text('Not Yet',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: _isFront
                              ? AppColors.error.withValues(alpha: 0.2)
                              : AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isFront ? null : () => _answer(true),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Know It!'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isFront
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final String label;
  final Gradient gradient;
  final Color textColor;

  const _CardFace({
    required this.text,
    required this.label,
    required this.gradient,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
