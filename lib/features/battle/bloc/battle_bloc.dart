import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/user_service.dart';
import '../models/battle_model.dart';
import '../services/battle_service.dart';
import 'battle_event.dart';
import 'battle_state.dart';

class BattleBloc extends Bloc<BattleEvent, BattleState> {
  final String myUid;
  final String myName;
  final BattleService _service = BattleService();
  final UserService _userService = UserService();
  StreamSubscription? _battleSub;
  String? _currentBattleId;

  BattleBloc({required this.myUid, required this.myName})
      : super(BattleInitial()) {
    on<CreateBattle>(_onCreate);
    on<AcceptBattle>(_onAccept);
    on<WatchBattle>(_onWatch);
    on<SubmitBattleAnswer>(_onAnswer);
    on<BattleUpdated>(_onUpdated);
  }

  Future<void> _onCreate(
    CreateBattle event,
    Emitter<BattleState> emit,
  ) async {
    emit(BattleLoading());
    try {
      final battleId = await _service.createBattle(
        player1Uid: myUid,
        player1Name: myName,
        player2Uid: event.opponentUid,
        player2Name: event.opponentName,
      );
      _currentBattleId = battleId;
      emit(BattleWaiting(
        battleId: battleId,
        opponentName: event.opponentName,
      ));
      // Start watching
      _watchBattle(battleId);
    } catch (e) {
      emit(BattleError(e.toString()));
    }
  }

  Future<void> _onAccept(
    AcceptBattle event,
    Emitter<BattleState> emit,
  ) async {
    emit(BattleLoading());
    try {
      await _service.acceptBattle(event.battleId);
      _currentBattleId = event.battleId;
      _watchBattle(event.battleId);
    } catch (e) {
      emit(BattleError(e.toString()));
    }
  }

  void _onWatch(WatchBattle event, Emitter<BattleState> emit) {
    _currentBattleId = event.battleId;
    _watchBattle(event.battleId);
  }

  void _watchBattle(String battleId) {
    _battleSub?.cancel();
    _battleSub = _service.watchBattle(battleId).listen(
      (battle) => add(BattleUpdated(battle)),
    );
  }

  void _onUpdated(BattleUpdated event, Emitter<BattleState> emit) {
    final battle = event.battle as BattleModel;

    if (battle.isComplete) {
      // Award XP
      _awardBattleXp(battle);
      emit(BattleComplete(battle: battle, myUid: myUid));
      _battleSub?.cancel();
      return;
    }

    if (battle.isActive) {
      // Check if I've already answered the current question
      final myAnswers = battle.answers[myUid] ?? [];
      final answered = myAnswers.length > battle.currentQuestionIndex;

      emit(BattleInProgress(
        battle: battle,
        myUid: myUid,
        myAnswerSubmitted: answered,
        myAnswerIndex: answered ? myAnswers[battle.currentQuestionIndex] : null,
      ));
      return;
    }

    if (battle.isWaiting) {
      final opponentName =
          myUid == battle.player1Uid ? battle.player2Name : battle.player1Name;
      emit(BattleWaiting(battleId: battle.id, opponentName: opponentName));
    }
  }

  Future<void> _onAnswer(
    SubmitBattleAnswer event,
    Emitter<BattleState> emit,
  ) async {
    if (_currentBattleId == null) return;
    if (state is! BattleInProgress) return;
    final current = state as BattleInProgress;
    if (current.myAnswerSubmitted) return;

    // Optimistic UI update
    emit(BattleInProgress(
      battle: current.battle,
      myUid: myUid,
      myAnswerSubmitted: true,
      myAnswerIndex: event.answerIndex,
    ));

    await _service.submitAnswer(
      battleId: _currentBattleId!,
      uid: myUid,
      answerIndex: event.answerIndex,
    );
  }

  Future<void> _awardBattleXp(BattleModel battle) async {
    final isWinner = battle.winnerUid == myUid;
    final isDraw = battle.winnerUid == null;

    int xp;
    if (isWinner) {
      xp = 30;
    } else if (isDraw) {
      xp = 15;
    } else {
      xp = 10;
    }

    await _userService.awardXp(myUid, xp);
    await _userService.updateStreak(myUid);

    // Check for battle badges
    // (In a production app, you'd track win count in Firestore)
  }

  @override
  Future<void> close() {
    _battleSub?.cancel();
    return super.close();
  }
}
