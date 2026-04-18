import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_models.dart';
import 'results_screen.dart';

class TrueFalseGame extends StatefulWidget {
  final LessonExerciseSet exerciseSet;

  const TrueFalseGame({super.key, required this.exerciseSet});

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame>
    with SingleTickerProviderStateMixin {
  late List<TrueFalseQuestion> _questions;
  int _current = 0;
  int _score = 0;
  bool? _lastAnswer; // null = not answered, true = correct, false = wrong
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.exerciseSet.trueFalse)..shuffle();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween(begin: -8.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _answer(bool userSaysTrue) {
    final q = _questions[_current];
    final correct = userSaysTrue == q.isTrue;
    if (correct) {
      _score++;
      setState(() => _lastAnswer = true);
    } else {
      _shakeCtrl.forward(from: 0);
      setState(() => _lastAnswer = false);
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_current < _questions.length - 1) {
        setState(() {
          _current++;
          _lastAnswer = null;
        });
      } else {
        final perfect = _score == _questions.length;
        final xp = _score * 3 + (perfect ? 15 : 0);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              gameTitle: 'True or False',
              score: _score,
              total: _questions.length,
              xpEarned: xp,
              perfect: perfect,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseSet.lessonTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  Text(
                    'Question ${_current + 1} of ${_questions.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.xpGold, size: 16),
                      const SizedBox(width: 4),
                      Text('$_score pts',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.xpGold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_current + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 32),

              // Statement card
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_lastAnswer == false ? _shakeAnim.value : 0, 0),
                    child: child,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: _lastAnswer == null
                          ? null
                          : _lastAnswer!
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                      gradient: _lastAnswer == null
                          ? AppColors.primaryGradient
                          : null,
                      borderRadius: BorderRadius.circular(24),
                      border: _lastAnswer != null
                          ? Border.all(
                              color: _lastAnswer!
                                  ? AppColors.success
                                  : AppColors.error,
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_lastAnswer == null) ...[
                          const Icon(Icons.help_rounded,
                              color: Colors.white70, size: 32),
                          const SizedBox(height: 20),
                          Text(
                            '"${q.statement}"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'TRUE or FALSE?',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            _lastAnswer! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: _lastAnswer! ? AppColors.success : AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _lastAnswer! ? '✅ Correct!' : '❌ Not Quite!',
                            style: TextStyle(
                              color: _lastAnswer! ? AppColors.success : AppColors.error,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            q.explanation,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: q.isTrue
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Answer: ${q.isTrue ? "TRUE ✅" : "FALSE ❌"}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: q.isTrue
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // TRUE / FALSE buttons
              Row(
                children: [
                  Expanded(
                    child: _TFButton(
                      label: 'TRUE',
                      icon: Icons.check_rounded,
                      color: AppColors.success,
                      enabled: _lastAnswer == null,
                      onTap: () => _answer(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TFButton(
                      label: 'FALSE',
                      icon: Icons.close_rounded,
                      color: AppColors.error,
                      enabled: _lastAnswer == null,
                      onTap: () => _answer(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TFButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _TFButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
