import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Get a single user ────────────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ─── Update display name ──────────────────────────────────────────────────

  Future<void> updateDisplayName(String uid, String displayName) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'displayName': displayName});
    await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
  }

  // ─── XP & Gamification ───────────────────────────────────────────────────

  Future<void> awardXp(String uid, int amount) async {
    final ref = _db.collection(AppConstants.usersCollection).doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final currentXp = (snap.data()?['xp'] ?? 0) as int;
      tx.update(ref, {'xp': currentXp + amount});
    });
  }

  Future<void> updateStreak(String uid) async {
    final ref = _db.collection(AppConstants.usersCollection).doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final lastActive = data['lastActiveDate'] != null
          ? (data['lastActiveDate'] as Timestamp).toDate()
          : null;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int currentStreak = (data['currentStreak'] ?? 0) as int;
      int longestStreak = (data['longestStreak'] ?? 0) as int;

      if (lastActive != null) {
        final lastDay =
            DateTime(lastActive.year, lastActive.month, lastActive.day);
        final diff = today.difference(lastDay).inDays;
        if (diff == 0) return;
        if (diff == 1) {
          currentStreak += 1;
        } else {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }

      if (currentStreak > longestStreak) longestStreak = currentStreak;

      tx.update(ref, {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': Timestamp.fromDate(now),
      });
    });
  }

  Future<void> unlockBadge(String uid, String badgeId) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).update({
      'badges': FieldValue.arrayUnion([badgeId]),
    });
  }

  // ─── Leaderboard (sorted client-side — no composite index needed) ─────────

  Stream<List<UserModel>> watchLeaderboard({int limit = 10}) {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleStudent)
        .snapshots()
        .map((snap) {
          final users =
              snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
          users.sort((a, b) => b.xp.compareTo(a.xp));
          return users.take(limit).toList();
        });
  }

  // ─── Teacher: get all students (sorted client-side) ───────────────────────

  Future<List<UserModel>> getAllStudents() async {
    final snap = await _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleStudent)
        .get();
    final students =
        snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
    students.sort((a, b) => a.displayName.compareTo(b.displayName));
    return students;
  }

  Stream<List<UserModel>> watchAllStudents() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleStudent)
        .snapshots()
        .map((snap) {
          final students =
              snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
          students.sort((a, b) => a.displayName.compareTo(b.displayName));
          return students;
        });
  }
}
