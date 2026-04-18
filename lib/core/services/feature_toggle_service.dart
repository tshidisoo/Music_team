import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for toggling student-facing features on/off.
/// Teacher can enable/disable features per week from the dashboard.
class FeatureToggleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _doc = 'app_config/feature_toggles';

  /// Default feature states (all enabled).
  static const _defaults = <String, bool>{
    'piano': true,
    'ear_training': true,
    'daily_challenge': true,
    'battle': true,
  };

  /// Stream of feature toggle states.
  Stream<Map<String, bool>> watchToggles() {
    return _db.doc(_doc).snapshots().map((snap) {
      if (!snap.exists) return Map.of(_defaults);
      final data = snap.data() ?? {};
      return {
        for (final key in _defaults.keys)
          key: data[key] as bool? ?? _defaults[key]!,
      };
    });
  }

  /// Get current toggle states.
  Future<Map<String, bool>> getToggles() async {
    final snap = await _db.doc(_doc).get();
    if (!snap.exists) return Map.of(_defaults);
    final data = snap.data() ?? {};
    return {
      for (final key in _defaults.keys)
        key: data[key] as bool? ?? _defaults[key]!,
    };
  }

  /// Toggle a single feature on/off.
  Future<void> setFeature(String feature, bool enabled) async {
    await _db.doc(_doc).set(
      {feature: enabled},
      SetOptions(merge: true),
    );
  }

  /// Set all toggles at once.
  Future<void> setAll(Map<String, bool> toggles) async {
    await _db.doc(_doc).set(toggles);
  }

  /// Human-readable labels for features.
  static const featureLabels = <String, String>{
    'piano': 'Virtual Piano',
    'ear_training': 'Ear Training',
    'daily_challenge': 'Daily Challenges',
    'battle': 'Quiz Battles',
  };

  /// Icons for features.
  static const featureIcons = <String, int>{
    'piano': 0xe3b5, // Icons.piano_rounded
    'ear_training': 0xe370, // Icons.hearing_rounded
    'daily_challenge': 0xe5e1, // Icons.today_rounded
    'battle': 0xea28, // Icons.sports_esports_rounded
  };
}
