class AppConstants {
  AppConstants._();

  // Teacher registration passcode (change this in production!)
  static const String teacherPasscode = 'MUSICTEAM2025';

  // XP values
  static const int xpPerLesson = 10;
  static const int xpPerExercise = 5;
  static const int xpPerProjectSubmission = 20;
  static const int xpPerfectQuiz = 50;

  // Level thresholds (XP required to REACH each level)
  static const Map<String, int> levelThresholds = {
    'Novice': 0,
    'Apprentice': 100,
    'Student': 300,
    'Musician': 700,
    'Maestro': 1500,
  };

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String lessonsCollection = 'lessons';
  static const String lessonProgressCollection = 'lesson_progress';
  static const String exercisesCollection = 'exercises';
  static const String exerciseAttemptsCollection = 'exercise_attempts';
  static const String projectsCollection = 'projects';
  static const String submissionsCollection = 'submissions';
  static const String leaderboardCollection = 'leaderboard';
  static const String feedbackCollection = 'feedback';

  // User roles
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';

  // Exercise types
  static const String exerciseMultipleChoice = 'multiple_choice';
  static const String exerciseEarTraining = 'ear_training';
  static const String exerciseStaff = 'staff';
  static const String exerciseRhythm = 'rhythm';

  // AB Guide parts
  static const int partOne = 1;
  static const int partTwo = 2;

  // Media types
  static const List<String> allowedMediaExtensions = [
    'mp4', 'mov', 'avi',        // video
    'mp3', 'wav', 'm4a', 'aac', // audio
    'pdf',                       // documents
    'jpg', 'jpeg', 'png', 'gif', // images
  ];

  // Storage paths
  static const String submissionsStoragePath = 'submissions';
  static const String profilePhotosStoragePath = 'profile_photos';
  static const String lessonAssetsStoragePath = 'lesson_assets';
  static const String exerciseAudioStoragePath = 'exercise_audio';

  // Daily Challenge
  static const String dailyCompletionsCollection = 'daily_completions';
  static const int xpDailyChallengeBase = 10;
  static const double xpWeekendMultiplier = 1.5;
  static const int streakMilestone7 = 7;
  static const int streakMilestone30 = 30;
  static const int streakMilestone100 = 100;

  // Quiz settings
  static const int quizTimerSeconds = 30;
  static const int quizOptionsCount = 4;

  // Shared prefs keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefThemeMode = 'theme_mode';
}
