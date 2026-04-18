import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../features/practice/data/practice_exercises.dart';
import '../models/battle_model.dart';

class BattleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'battles';
  static const _questionsPerBattle = 8;

  /// Create a new battle challenge.
  Future<String> createBattle({
    required String player1Uid,
    required String player1Name,
    required String player2Uid,
    required String player2Name,
  }) async {
    final battleId = const Uuid().v4();
    final questions = _generateRandomQuestions();

    final battle = BattleModel(
      id: battleId,
      player1Uid: player1Uid,
      player2Uid: player2Uid,
      player1Name: player1Name,
      player2Name: player2Name,
      status: 'waiting',
      questions: questions,
      scores: {player1Uid: 0, player2Uid: 0},
      answers: {player1Uid: [], player2Uid: []},
      createdAt: DateTime.now(),
    );

    await _db.collection(_collection).doc(battleId).set(battle.toFirestore());
    return battleId;
  }

  /// Accept a battle challenge (player2 joins).
  Future<void> acceptBattle(String battleId) async {
    await _db.collection(_collection).doc(battleId).update({
      'status': 'active',
      'currentQuestionIndex': 0,
      'questionStartedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Decline/cancel a battle.
  Future<void> cancelBattle(String battleId) async {
    await _db.collection(_collection).doc(battleId).update({
      'status': 'cancelled',
    });
  }

  /// Submit an answer for the current question.
  Future<void> submitAnswer({
    required String battleId,
    required String uid,
    required int answerIndex,
  }) async {
    final ref = _db.collection(_collection).doc(battleId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final battle = BattleModel.fromFirestore(snap);

      // Get the current answers for this player
      final playerAnswers = List<int>.from(battle.answers[uid] ?? []);
      playerAnswers.add(answerIndex);

      // Check if answer is correct
      final qIndex = playerAnswers.length - 1;
      if (qIndex < battle.questions.length) {
        final q = battle.questions[qIndex];
        final selectedOption = q.options[answerIndex];
        final isCorrect = selectedOption == q.answer;

        final newScore = (battle.scores[uid] ?? 0) + (isCorrect ? 1 : 0);

        tx.update(ref, {
          'answers.$uid': playerAnswers,
          'scores.$uid': newScore,
        });

        // Check if both players have answered all questions
        final otherUid =
            uid == battle.player1Uid ? battle.player2Uid : battle.player1Uid;
        final otherAnswers = battle.answers[otherUid] ?? [];

        if (playerAnswers.length >= battle.questions.length &&
            otherAnswers.length >= battle.questions.length) {
          // Battle is complete
          final otherScore = battle.scores[otherUid] ?? 0;
          final finalScore = newScore;
          String? winner;
          if (finalScore > otherScore) {
            winner = uid;
          } else if (otherScore > finalScore) {
            winner = otherUid;
          }

          tx.update(ref, {
            'status': 'completed',
            'winnerUid': winner,
            'completedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Advance question if both answered current one
          if (playerAnswers.length > battle.currentQuestionIndex &&
              otherAnswers.length > battle.currentQuestionIndex) {
            tx.update(ref, {
              'currentQuestionIndex': battle.currentQuestionIndex + 1,
              'questionStartedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    });
  }

  /// Watch a battle in real-time.
  Stream<BattleModel> watchBattle(String battleId) {
    return _db
        .collection(_collection)
        .doc(battleId)
        .snapshots()
        .map((doc) => BattleModel.fromFirestore(doc));
  }

  /// Get pending battle invitations for a user.
  Stream<List<BattleModel>> watchPendingBattles(String uid) {
    return _db
        .collection(_collection)
        .where('player2Uid', isEqualTo: uid)
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BattleModel.fromFirestore(d)).toList());
  }

  /// Get battle history for a user.
  Future<List<BattleModel>> getBattleHistory(String uid) async {
    // Get battles where user is player1 or player2
    final snap1 = await _db
        .collection(_collection)
        .where('player1Uid', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(20)
        .get();

    final snap2 = await _db
        .collection(_collection)
        .where('player2Uid', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(20)
        .get();

    final battles = [
      ...snap1.docs.map((d) => BattleModel.fromFirestore(d)),
      ...snap2.docs.map((d) => BattleModel.fromFirestore(d)),
    ];

    battles.sort((a, b) =>
        (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));

    return battles.take(20).toList();
  }

  /// Generate random questions from the exercise pool.
  List<BattleQuestion> _generateRandomQuestions() {
    final allQuestions = <BattleQuestion>[];

    // Collect questions from all lessons
    final keys = [
      '1-1', '1-2', '1-3', '1-4', '1-5', '1-6', '1-7',
      '1-8', '1-9', '1-10', '1-11', '1-12', '1-13',
      '2-1', '2-2', '2-3', '2-4', '2-5', '2-6', '2-7', '2-8',
    ];

    for (final key in keys) {
      final parts = key.split('-');
      final set = PracticeExercises.getForLesson(
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (set != null) {
        for (final q in set.quiz) {
          allQuestions.add(BattleQuestion(
            question: q.question,
            answer: q.answer,
            options: List.from(q.options)..shuffle(),
          ));
        }
      }
    }

    allQuestions.shuffle();
    return allQuestions.take(_questionsPerBattle).toList();
  }
}
