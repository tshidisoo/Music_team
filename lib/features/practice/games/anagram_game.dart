import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_models.dart';
import 'results_screen.dart';

class AnagramGame extends StatefulWidget {
  final LessonExerciseSet exerciseSet;

  const AnagramGame({super.key, required this.exerciseSet});

  @override
  State<AnagramGame> createState() => _AnagramGameState();
}

class _AnagramGameState extends State<AnagramGame> {
  late List<AnagramChallenge> _challenges;
  int _current = 0;
  int _score = 0;

  // Current puzzle state
  late List<String> _scrambledLetters; // pool of letters to tap
  late List<String?> _answerSlots;      // built answer (nulls = empty)
  bool? _correct;

  @override
  void initState() {
    super.initState();
    _challenges = List.from(widget.exerciseSet.anagrams);
    _loadChallenge();
  }

  void _loadChallenge() {
    final word = _challenges[_current].answer.toUpperCase();
    final letters = word.split('');
    // Shuffle until different from answer
    do {
      letters.shuffle(Random());
    } while (letters.join() == word && letters.length > 1);
    setState(() {
      _scrambledLetters = letters;
      _answerSlots = List.filled(word.length, null);
      _correct = null;
    });
  }

  void _tapScrambled(int i) {
    if (_correct != null) return;
    final letter = _scrambledLetters[i];
    if (letter.isEmpty) return; // already used
    final emptySlot = _answerSlots.indexWhere((s) => s == null);
    if (emptySlot == -1) return;
    setState(() {
      _answerSlots[emptySlot] = letter;
      _scrambledLetters[i] = ''; // mark as used
    });
    _checkAnswer();
  }

  void _tapAnswer(int i) {
    if (_correct != null) return;
    final letter = _answerSlots[i];
    if (letter == null) return;
    // Find first empty slot in scrambled
    final emptyScrambled = _scrambledLetters.indexWhere((l) => l.isEmpty);
    setState(() {
      if (emptyScrambled != -1) {
        _scrambledLetters[emptyScrambled] = letter;
      } else {
        _scrambledLetters.add(letter);
      }
      _answerSlots[i] = null;
    });
  }

  void _checkAnswer() {
    final filled = _answerSlots.every((s) => s != null);
    if (!filled) return;
    final guess = _answerSlots.join();
    final answer = _challenges[_current].answer.toUpperCase();
    final isCorrect = guess == answer;
    setState(() => _correct = isCorrect);
    if (isCorrect) _score++;

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_current < _challenges.length - 1) {
        setState(() => _current++);
        _loadChallenge();
      } else {
        final perfect = _score == _challenges.length;
        final xp = _score * 5 + (perfect ? 20 : 0);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              gameTitle: 'Anagram',
              score: _score,
              total: _challenges.length,
              xpEarned: xp,
              perfect: perfect,
            ),
          ),
        );
      }
    });
  }

  void _clearAnswer() {
    if (_correct != null) return;
    final usedLetters = _answerSlots.where((s) => s != null).cast<String>().toList();
    setState(() {
      _answerSlots = List.filled(_challenges[_current].answer.length, null);
      // Return letters to scrambled pool
      for (var i = 0; i < _scrambledLetters.length; i++) {
        if (_scrambledLetters[i].isEmpty && usedLetters.isNotEmpty) {
          _scrambledLetters[i] = usedLetters.removeAt(0);
        }
      }
    });
  }

  static const List<Color> _tileColors = [
    Color(0xFF6C3FE8),
    Color(0xFFFF8C00),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
    Color(0xFF6366F1),
  ];

  Color _letterColor(int index) =>
      _tileColors[index % _tileColors.length];

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_current];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseSet.lessonTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _clearAnswer,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Clear'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Word ${_current + 1} of ${_challenges.length}',
                      style: theme.textTheme.bodySmall),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.xpGold, size: 16),
                      const SizedBox(width: 4),
                      Text('$_score solved',
                          style: const TextStyle(
                              color: AppColors.xpGold,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_current + 1) / _challenges.length,
                  minHeight: 6,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.secondary),
                ),
              ),
              const SizedBox(height: 32),

              // Game icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sort_by_alpha_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),

              Text(
                'UNSCRAMBLE IT!',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded,
                        color: AppColors.info, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '💡 ${challenge.hint}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Answer slots
              if (_correct != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _correct!
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _correct! ? AppColors.success : AppColors.error),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _correct! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: _correct! ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _correct!
                            ? '🎉 Correct! "${challenge.answer}"'
                            : '❌ The answer is "${challenge.answer}"',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _correct! ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Answer slots row
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _answerSlots.length,
                  (i) => GestureDetector(
                    onTap: () => _tapAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _answerSlots[i] != null
                            ? (_correct == true
                                ? AppColors.success
                                : _correct == false
                                    ? AppColors.error
                                    : AppColors.primary)
                            : AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _answerSlots[i] != null
                              ? Colors.transparent
                              : AppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _answerSlots[i] != null
                            ? Text(
                                _answerSlots[i]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : Container(
                                width: 20,
                                height: 2,
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Scrambled letter tiles
              Text(
                'TAP LETTERS TO BUILD YOUR ANSWER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _scrambledLetters.length,
                  (i) {
                    final letter = _scrambledLetters[i];
                    return GestureDetector(
                      onTap: letter.isNotEmpty
                          ? () => _tapScrambled(i)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 52,
                        decoration: BoxDecoration(
                          color: letter.isNotEmpty
                              ? _letterColor(i)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: letter.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: _letterColor(i).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: letter.isNotEmpty
                              ? Text(
                                  letter,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
