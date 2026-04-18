import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local notifications for streak reminders and daily challenges.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'daily_challenge';
  static const _channelName = 'Daily Challenge Reminders';
  static const _channelDesc = 'Reminds you to complete your daily challenge';
  static const _prefReminderHour = 'reminder_hour';
  static const _prefReminderMinute = 'reminder_minute';
  static const _prefRemindersEnabled = 'reminders_enabled';

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Schedule a daily reminder at the user's preferred time.
  Future<void> scheduleDailyReminder({int hour = 18, int minute = 0}) async {
    if (!_initialized) await init();

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefReminderHour, hour);
    await prefs.setInt(_prefReminderMinute, minute);
    await prefs.setBool(_prefRemindersEnabled, true);

    // Cancel any existing
    await _plugin.cancel(0);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule daily
    await _plugin.periodicallyShow(
      0,
      "Don't lose your streak!",
      "Complete today's daily challenge to keep your streak going!",
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancel all reminders.
  Future<void> cancelReminders() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefRemindersEnabled, false);
  }

  /// Check if reminders are enabled.
  Future<bool> areRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefRemindersEnabled) ?? false;
  }

  /// Send an immediate notification (e.g. for streak milestones).
  Future<void> showStreakMilestone(int streakDays) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Streak Milestone!',
      'Amazing! You have a $streakDays-day streak! Keep going!',
      details,
    );
  }
}
