import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_models.dart';
import 'results_screen.dart';

class QuizGame extends StatefulWidget {
  final LessonExerciseSet exerciseSet;

  const QuizGame({super.key, required this.exerciseSet});

  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  late List<ExerciseQuestion> _questions;
  late List<String> _shuffledOptions;
  int _current = 0;
  int _score = 0;
  int _timeLeft = 25;
  Timer? _timer;
  String? _selected;
  bool _answered = false;

  static const _optionColors = [
    Color(0xFF6C3FE8),
    Color(0xFFFF8C00),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
  ];

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.exerciseSet.quiz)..shuffle();
    _shuffledOptions = List<String>.from(_questions[0].options)..shuffle();
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 25;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _handleAnswer(''); // time out = wrong
      }
    });
  }

  void _handleAnswer(String answer) {
    if (_answered) return;
    _timer?.cancel();
    final correct = answer == _questions[_current].answer;
    if (correct) _score++;
    setState(() {
      _selected = answer;
      _answered = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), _nextQuestion);
  }

  void _nextQuestion() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
        _shuffledOptions = List<String>.from(_questions[_current].options)..shuffle();
      });
      _startTimer();
    } else {
      final perfect = _score == _questions.length;
      final xp = _score * 5 + (perfect ? 50 : 0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            gameTitle: 'Quiz',
            score: _score,
            total: _questions.length,
            xpEarned: xp,
            perfect: perfect,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _buttonColor(String option, int idx) {
    if (!_answered) return _optionColors[idx % _optionColors.length];
    final isCorrect = option == _questions[_current].answer;
    final isSelected = option == _selected;
    if (isCorrect) return AppColors.success;
    if (isSelected && !isCorrect) return AppColors.error;
    return _optionColors[idx % _optionColors.length].withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    final opts = _shuffledOptions;
    final timerFraction = _timeLeft / 25;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Question ${_current + 1} of ${_questions.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_current + 1) / _questions.length,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Timer
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: timerFraction,
                          strokeWidth: 4,
                          backgroundColor:
                              AppColors.error.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(
                            _timeLeft > 10
                                ? AppColors.success
                                : _timeLeft > 5
                                    ? AppColors.warning
                                    : AppColors.error,
                          ),
                        ),
                        Text(
                          '$_timeLeft',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _timeLeft <= 5
                                ? AppColors.error
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.xpGold, size: 18),
                  const SizedBox(width: 4),
                  Text('$_score correct',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.xpGold)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question card
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_rounded,
                          color: Colors.white70, size: 28),
                      const SizedBox(height: 16),
                      Text(
                        q.question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Answer options
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: opts.length > 4 ? 4 : opts.length,
                  itemBuilder: (ctx, i) {
                    final opt = opts[i];
                    final isCorrect =
                        _answered && opt == q.answer;
                    final isWrong = _answered &&
                        opt == _selected &&
                        opt != q.answer;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () => _handleAnswer(opt),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _buttonColor(opt, i),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    _buttonColor(opt, i).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  opt,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (isCorrect)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                                ),
                              if (isWrong)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.cancel_rounded,
                                      color: Colors.white, size: 18),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
