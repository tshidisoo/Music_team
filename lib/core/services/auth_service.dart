import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lazy-init: only create GoogleSignIn on mobile platforms.
  // On web, Firebase's signInWithPopup is used instead.
  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _mobileGoogleSignIn =>
      _googleSignIn ??= GoogleSignIn(scopes: ['email']);

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Register with email/password ─────────────────────────────────────────

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─── Sign in with email/password ──────────────────────────────────────────

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: use Firebase's built-in popup — no google_sign_in needed
      final provider = GoogleAuthProvider();
      return await _auth.signInWithPopup(provider);
    }
    // Mobile: use google_sign_in v6 — proven reliable on Android
    final GoogleSignInAccount? account = await _mobileGoogleSignIn.signIn();
    if (account == null) return null; // user cancelled
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
  }

  // ─── Create user document in Firestore ────────────────────────────────────

  Future<void> createUserDocument({
    required String uid,
    required String displayName,
    required String email,
    required String role,
    String? photoUrl,
  }) async {
    final user = UserModel(
      uid: uid,
      displayName: displayName,
      email: email,
      role: role,
      photoUrl: photoUrl,
      xp: 0,
      currentStreak: 0,
      longestStreak: 0,
      badges: [],
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(user.toFirestore());
  }

  // ─── Check if user document exists ────────────────────────────────────────

  Future<bool> userDocumentExists(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    return doc.exists;
  }

  // ─── Get user model ───────────────────────────────────────────────────────

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── Password reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
