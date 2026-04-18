import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/services/lesson_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/constants/app_constants.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class LessonsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLessons extends LessonsEvent {
  final String uid;
  final int partNumber;
  LoadLessons({required this.uid, required this.partNumber});
  @override
  List<Object?> get props => [uid, partNumber];
}

class SwitchPart extends LessonsEvent {
  final int partNumber;
  SwitchPart(this.partNumber);
  @override
  List<Object?> get props => [partNumber];
}

class CompleteLesson extends LessonsEvent {
  final String uid;
  final String lessonId;
  CompleteLesson({required this.uid, required this.lessonId});
  @override
  List<Object?> get props => [uid, lessonId];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class LessonsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {}

class LessonsLoading extends LessonsState {}

class LessonsLoaded extends LessonsState {
  final List<LessonModel> lessons;
  final Map<String, LessonProgress> progress;
  final int activePart;

  LessonsLoaded({
    required this.lessons,
    required this.progress,
    required this.activePart,
  });

  int get completedCount =>
      progress.values.where((p) => p.completed).length;

  double get completionPercent =>
      lessons.isEmpty ? 0.0 : completedCount / lessons.length;

  @override
  List<Object?> get props => [lessons, progress, activePart];
}

class LessonsError extends LessonsState {
  final String message;
  LessonsError(this.message);
  @override
  List<Object?> get props => [message];
}

class LessonCompleted extends LessonsState {
  final String lessonId;
  final int xpAwarded;
  LessonCompleted({required this.lessonId, required this.xpAwarded});
  @override
  List<Object?> get props => [lessonId, xpAwarded];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class LessonsBloc extends Bloc<LessonsEvent, LessonsState> {
  final LessonService _lessonService;
  final UserService _userService;

  LessonsBloc({
    required LessonService lessonService,
    required UserService userService,
  })  : _lessonService = lessonService,
        _userService = userService,
        super(LessonsInitial()) {
    on<LoadLessons>(_onLoad);
    on<SwitchPart>(_onSwitchPart);
    on<CompleteLesson>(_onCompleteLesson);
  }

  String? _currentUid;
  int _currentPart = 1;

  Future<void> _onLoad(LoadLessons event, Emitter<LessonsState> emit) async {
    _currentUid = event.uid;
    _currentPart = event.partNumber;
    emit(LessonsLoading());
    try {
      final lessons =
          await _lessonService.getLessonsForPart(event.partNumber);
      final progress =
          await _lessonService.getLessonProgressForUser(event.uid);
      emit(LessonsLoaded(
        lessons: lessons,
        progress: progress,
        activePart: event.partNumber,
      ));
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }

  Future<void> _onSwitchPart(
      SwitchPart event, Emitter<LessonsState> emit) async {
    if (_currentUid == null) return;
    _currentPart = event.partNumber;
    add(LoadLessons(uid: _currentUid!, partNumber: event.partNumber));
  }

  Future<void> _onCompleteLesson(
      CompleteLesson event, Emitter<LessonsState> emit) async {
    try {
      final alreadyDone =
          await _lessonService.isLessonCompleted(event.uid, event.lessonId);
      if (!alreadyDone) {
        await _lessonService.markLessonComplete(event.uid, event.lessonId);
        await _userService.awardXp(event.uid, AppConstants.xpPerLesson);
        await _userService.updateStreak(event.uid);
        emit(LessonCompleted(
            lessonId: event.lessonId, xpAwarded: AppConstants.xpPerLesson));
      }
      // Reload lessons to refresh progress
      add(LoadLessons(uid: event.uid, partNumber: _currentPart));
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }
}
