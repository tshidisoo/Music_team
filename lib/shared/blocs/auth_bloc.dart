import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/user_model.dart';
import '../../core/constants/app_constants.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignedIn extends AuthEvent {
  final User firebaseUser;
  AuthSignedIn(this.firebaseUser);
  @override
  List<Object?> get props => [firebaseUser];
}

class AuthSignedOut extends AuthEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;
  Timer? _timeoutTimer;

  AuthBloc() : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignedIn>(_onSignedIn);
    on<AuthSignedOut>(_onSignedOut);
    add(AuthStarted());
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    _authSubscription?.cancel();

    // Safety timeout — if Firebase auth doesn't respond in 8s, navigate to login
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (state is AuthLoading || state is AuthInitial) {
        debugPrint('[AuthBloc] Timeout — Firebase auth did not respond. Forcing login.');
        add(AuthSignedOut());
      }
    });

    debugPrint('[AuthBloc] Listening to authStateChanges...');
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        _timeoutTimer?.cancel();
        debugPrint('[AuthBloc] authStateChanges fired — user: ${user?.uid ?? 'null'}');
        if (user != null) {
          add(AuthSignedIn(user));
        } else {
          add(AuthSignedOut());
        }
      },
      onError: (error) {
        _timeoutTimer?.cancel();
        debugPrint('[AuthBloc] authStateChanges error: $error');
        // On error, fall through to login so the app is never stuck
        add(AuthSignedOut());
      },
    );
  }

  Future<void> _onSignedIn(
      AuthSignedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      debugPrint('[AuthBloc] Fetching Firestore user doc for ${event.firebaseUser.uid}');
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(event.firebaseUser.uid)
          .get();
      if (doc.exists) {
        debugPrint('[AuthBloc] User doc found → AuthAuthenticated');
        emit(AuthAuthenticated(UserModel.fromFirestore(doc)));
      } else {
        // Firebase user exists but no Firestore profile yet — needs role selection
        debugPrint('[AuthBloc] No Firestore doc → AuthUnauthenticated (role selection needed)');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Firestore failed (e.g. permission denied) — still let user reach login
      debugPrint('[AuthBloc] Firestore error: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignedOut(
      AuthSignedOut event, Emitter<AuthState> emit) async {
    debugPrint('[AuthBloc] → AuthUnauthenticated');
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _timeoutTimer?.cancel();
    return super.close();
  }
}
