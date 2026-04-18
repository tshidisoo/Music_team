import 'package:equatable/equatable.dart';
import '../models/battle_model.dart';

abstract class BattleState extends Equatable {
  const BattleState();
  @override
  List<Object?> get props => [];
}

class BattleInitial extends BattleState {}

class BattleLoading extends BattleState {}

class BattleWaiting extends BattleState {
  final String battleId;
  final String opponentName;
  const BattleWaiting({required this.battleId, required this.opponentName});
  @override
  List<Object?> get props => [battleId, opponentName];
}

class BattleInProgress extends BattleState {
  final BattleModel battle;
  final String myUid;
  final bool myAnswerSubmitted; // have I answered the current question?
  final int? myAnswerIndex; // what I answered

  const BattleInProgress({
    required this.battle,
    required this.myUid,
    this.myAnswerSubmitted = false,
    this.myAnswerIndex,
  });

  int get myScore => battle.scores[myUid] ?? 0;
  String get opponentUid =>
      myUid == battle.player1Uid ? battle.player2Uid : battle.player1Uid;
  int get opponentScore => battle.scores[opponentUid] ?? 0;
  String get opponentName =>
      myUid == battle.player1Uid ? battle.player2Name : battle.player1Name;

  @override
  List<Object?> get props => [battle, myUid, myAnswerSubmitted, myAnswerIndex];
}

class BattleComplete extends BattleState {
  final BattleModel battle;
  final String myUid;

  const BattleComplete({required this.battle, required this.myUid});

  int get myScore => battle.scores[myUid] ?? 0;
  String get opponentUid =>
      myUid == battle.player1Uid ? battle.player2Uid : battle.player1Uid;
  int get opponentScore => battle.scores[opponentUid] ?? 0;
  String get opponentName =>
      myUid == battle.player1Uid ? battle.player2Name : battle.player1Name;
  bool get isWinner => battle.winnerUid == myUid;
  bool get isDraw => battle.winnerUid == null;

  @override
  List<Object?> get props => [battle, myUid];
}

class BattleError extends BattleState {
  final String message;
  const BattleError(this.message);
  @override
  List<Object?> get props => [message];
}
