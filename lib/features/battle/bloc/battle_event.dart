import 'package:equatable/equatable.dart';

abstract class BattleEvent extends Equatable {
  const BattleEvent();
  @override
  List<Object?> get props => [];
}

/// Challenge a classmate to a battle.
class CreateBattle extends BattleEvent {
  final String opponentUid;
  final String opponentName;
  const CreateBattle({required this.opponentUid, required this.opponentName});
  @override
  List<Object?> get props => [opponentUid, opponentName];
}

/// Accept a pending battle invitation.
class AcceptBattle extends BattleEvent {
  final String battleId;
  const AcceptBattle(this.battleId);
  @override
  List<Object?> get props => [battleId];
}

/// Join and start watching a battle.
class WatchBattle extends BattleEvent {
  final String battleId;
  const WatchBattle(this.battleId);
  @override
  List<Object?> get props => [battleId];
}

/// Submit an answer in the current battle.
class SubmitBattleAnswer extends BattleEvent {
  final int answerIndex;
  const SubmitBattleAnswer(this.answerIndex);
  @override
  List<Object?> get props => [answerIndex];
}

/// Battle data updated from Firestore listener.
class BattleUpdated extends BattleEvent {
  final dynamic battle;
  const BattleUpdated(this.battle);
  @override
  List<Object?> get props => [battle];
}
