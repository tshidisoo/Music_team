import 'package:cloud_firestore/cloud_firestore.dart';

class BattleModel {
  final String id;
  final String player1Uid;
  final String player2Uid;
  final String player1Name;
  final String player2Name;
  final String status; // 'waiting', 'active', 'completed', 'cancelled'
  final List<BattleQuestion> questions;
  final Map<String, int> scores; // uid → score
  final Map<String, List<int>> answers; // uid → list of answer indices
  final int currentQuestionIndex;
  final DateTime? questionStartedAt;
  final String? winnerUid;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BattleModel({
    required this.id,
    required this.player1Uid,
    required this.player2Uid,
    required this.player1Name,
    required this.player2Name,
    required this.status,
    required this.questions,
    required this.scores,
    required this.answers,
    this.currentQuestionIndex = 0,
    this.questionStartedAt,
    this.winnerUid,
    required this.createdAt,
    this.completedAt,
  });

  factory BattleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BattleModel(
      id: doc.id,
      player1Uid: data['player1Uid'] ?? '',
      player2Uid: data['player2Uid'] ?? '',
      player1Name: data['player1Name'] ?? '',
      player2Name: data['player2Name'] ?? '',
      status: data['status'] ?? 'waiting',
      questions: (data['questions'] as List? ?? [])
          .map((q) => BattleQuestion.fromMap(q as Map<String, dynamic>))
          .toList(),
      scores: Map<String, int>.from(data['scores'] ?? {}),
      answers: (data['answers'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, List<int>.from(v ?? [])),
      ),
      currentQuestionIndex: (data['currentQuestionIndex'] ?? 0) as int,
      questionStartedAt: data['questionStartedAt'] != null
          ? (data['questionStartedAt'] as Timestamp).toDate()
          : null,
      winnerUid: data['winnerUid'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'player1Uid': player1Uid,
        'player2Uid': player2Uid,
        'player1Name': player1Name,
        'player2Name': player2Name,
        'status': status,
        'questions': questions.map((q) => q.toMap()).toList(),
        'scores': scores,
        'answers': answers,
        'currentQuestionIndex': currentQuestionIndex,
        'questionStartedAt': questionStartedAt != null
            ? Timestamp.fromDate(questionStartedAt!)
            : null,
        'winnerUid': winnerUid,
        'createdAt': Timestamp.fromDate(createdAt),
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };

  int get player1Score => scores[player1Uid] ?? 0;
  int get player2Score => scores[player2Uid] ?? 0;
  bool get isComplete => status == 'completed';
  bool get isWaiting => status == 'waiting';
  bool get isActive => status == 'active';

  int answersCountFor(String uid) => answers[uid]?.length ?? 0;
}

class BattleQuestion {
  final String question;
  final String answer;
  final List<String> options;

  const BattleQuestion({
    required this.question,
    required this.answer,
    required this.options,
  });

  factory BattleQuestion.fromMap(Map<String, dynamic> map) {
    return BattleQuestion(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      options: List<String>.from(map['options'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'answer': answer,
        'options': options,
      };
}
