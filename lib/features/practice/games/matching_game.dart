import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_models.dart';
import 'results_screen.dart';

class MatchingGame extends StatefulWidget {
  final LessonExerciseSet exerciseSet;

  const MatchingGame({super.key, required this.exerciseSet});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  late List<MatchingPair> _pairs;
  late List<String> _terms;
  late List<String> _definitions;

  String? _selectedTerm;
  String? _selectedDef;
  final Set<String> _matchedTerms = {};
  final Set<String> _matchedDefs = {};
  int _mistakes = 0;
  int _matchedCount = 0;

  @override
  void initState() {
    super.initState();
    _pairs = List.from(widget.exerciseSet.matching);
    if (_pairs.length > 5) _pairs = _pairs.sublist(0, 5);
    _terms = _pairs.map((p) => p.term).toList()..shuffle();
    _definitions = _pairs.map((p) => p.definition).toList()..shuffle();
  }

  void _selectTerm(String term) {
    if (_matchedTerms.contains(term)) return;
    setState(() {
      _selectedTerm = term;
      _selectedDef = null;
    });
    _tryMatch();
  }

  void _selectDef(String def) {
    if (_matchedDefs.contains(def)) return;
    setState(() => _selectedDef = def);
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedTerm == null || _selectedDef == null) return;
    final pair = _pairs.firstWhere(
      (p) => p.term == _selectedTerm,
      orElse: () => const MatchingPair(term: '', definition: ''),
    );
    final isCorrect = pair.definition == _selectedDef;

    if (isCorrect) {
      setState(() {
        _matchedTerms.add(_selectedTerm!);
        _matchedDefs.add(_selectedDef!);
        _matchedCount++;
        _selectedTerm = null;
        _selectedDef = null;
      });
      if (_matchedCount == _pairs.length) {
        Future.delayed(const Duration(milliseconds: 600), _finish);
      }
    } else {
      setState(() => _mistakes++);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() {
          _selectedTerm = null;
          _selectedDef = null;
        });
      });
    }
  }

  void _finish() {
    final xp = _matchedCount * 5 + (_mistakes == 0 ? 10 : 0);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          gameTitle: 'Matching Pairs',
          score: _matchedCount,
          total: _pairs.length,
          xpEarned: xp,
          perfect: _mistakes == 0,
        ),
      ),
    );
  }

  Color _termColor(String term) {
    if (_matchedTerms.contains(term)) return AppColors.success;
    if (_selectedTerm == term) return AppColors.primary;
    return AppColors.primary.withValues(alpha: 0.08);
  }

  Color _defColor(String def) {
    if (_matchedDefs.contains(def)) return AppColors.success;
    if (_selectedDef == def) return AppColors.secondary;
    return AppColors.secondary.withValues(alpha: 0.08);
  }

  Color _termTextColor(String term) {
    if (_matchedTerms.contains(term)) return Colors.white;
    if (_selectedTerm == term) return Colors.white;
    return AppColors.primary;
  }

  Color _defTextColor(String def) {
    if (_matchedDefs.contains(def)) return Colors.white;
    if (_selectedDef == def) return Colors.white;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseSet.lessonTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.check_circle_rounded,
                  label: '$_matchedCount/${_pairs.length} matched',
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.close_rounded,
                  label: '$_mistakes mistakes',
                  color: _mistakes > 0 ? AppColors.error : AppColors.info,
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_rounded,
                      color: AppColors.info, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap a TERM (left), then tap its DEFINITION (right)',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Columns
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Terms column
                  Expanded(
                    child: Column(
                      children: [
                        Text('TERMS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: AppColors.primary.withValues(alpha: 0.6),
                            )),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _terms.map((term) => _MatchTile(
                                    text: term,
                                    color: _termColor(term),
                                    textColor: _termTextColor(term),
                                    isMatched: _matchedTerms.contains(term),
                                    onTap: () => _selectTerm(term),
                                  )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Line connectors (decorative)
                  Column(
                    children: [
                      const SizedBox(height: 32),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              _pairs.length,
                              (i) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 22),
                                child: Icon(
                                  Icons.link_rounded,
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Definitions column
                  Expanded(
                    child: Column(
                      children: [
                        Text('DEFINITIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: AppColors.secondary.withValues(alpha: 0.6),
                            )),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _definitions.map((def) => _MatchTile(
                                    text: def,
                                    color: _defColor(def),
                                    textColor: _defTextColor(def),
                                    isMatched: _matchedDefs.contains(def),
                                    onTap: () => _selectDef(def),
                                  )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool isMatched;
  final VoidCallback onTap;

  const _MatchTile({
    required this.text,
    required this.color,
    required this.textColor,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isMatched ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMatched
                      ? AppColors.success
                      : color.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  if (isMatched)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 16),
                    ),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
