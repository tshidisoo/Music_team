import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthFormEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthFormEvent {
  final String displayName;
  final String email;
  final String password;
  RegisterSubmitted({
    required this.displayName,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [displayName, email, password];
}

class GoogleSignInRequested extends AuthFormEvent {}

class RoleSelected extends AuthFormEvent {
  final String uid;
  final String displayName;
  final String email;
  final String role;
  final String? passcode;
  final String? photoUrl;
  RoleSelected({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.passcode,
    this.photoUrl,
  });
  @override
  List<Object?> get props => [uid, role, passcode];
}

class ForgotPasswordRequested extends AuthFormEvent {
  final String email;
  ForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthFormInitial extends AuthFormState {}

class AuthFormLoading extends AuthFormState {}

class AuthFormSuccess extends AuthFormState {
  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool needsRoleSelection;
  AuthFormSuccess({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.needsRoleSelection = false,
  });
  @override
  List<Object?> get props => [uid, needsRoleSelection];
}

class AuthFormRoleCreated extends AuthFormState {}

class AuthFormPasswordResetSent extends AuthFormState {}

class AuthFormError extends AuthFormState {
  final String message;
  AuthFormError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  final AuthService _authService;

  AuthFormBloc(this._authService) : super(AuthFormInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<RoleSelected>(_onRoleSelected);
    on<ForgotPasswordRequested>(_onForgotPassword);
  }

  Future<void> _onLogin(
      LoginSubmitted event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    try {
      await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthFormSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthFormError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFormError(AppStrings.errorGeneric));
    }
  }

  Future<void> _onRegister(
      RegisterSubmitted event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    try {
      final credential = await _authService.registerWithEmail(
        email: event.email,
        password: event.password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(event.displayName);
      emit(AuthFormSuccess(
        uid: uid,
        displayName: event.displayName,
        email: event.email,
        needsRoleSelection: true,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthFormError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFormError(AppStrings.errorGeneric));
    }
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInRequested event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        emit(AuthFormInitial());
        return;
      }
      final uid = credential.user!.uid;
      final exists = await _authService.userDocumentExists(uid);
      if (exists) {
        emit(AuthFormSuccess());
      } else {
        emit(AuthFormSuccess(
          uid: uid,
          displayName: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          photoUrl: credential.user!.photoURL,
          needsRoleSelection: true,
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFormError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFormError(AppStrings.errorGeneric));
    }
  }

  Future<void> _onRoleSelected(
      RoleSelected event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    try {
      if (event.role == AppConstants.roleTeacher) {
        if (event.passcode != AppConstants.teacherPasscode) {
          emit(AuthFormError(AppStrings.errorWrongPasscode));
          return;
        }
      }
      await _authService.createUserDocument(
        uid: event.uid,
        displayName: event.displayName,
        email: event.email,
        role: event.role,
        photoUrl: event.photoUrl,
      );
      emit(AuthFormRoleCreated());
    } catch (e) {
      emit(AuthFormError(AppStrings.errorGeneric));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordRequested event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(AuthFormPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthFormError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFormError(AppStrings.errorGeneric));
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return AppStrings.errorWeakPassword;
      case 'invalid-email':
        return AppStrings.errorInvalidEmail;
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return AppStrings.errorNoInternet;
      default:
        return AppStrings.errorGeneric;
    }
  }
}
