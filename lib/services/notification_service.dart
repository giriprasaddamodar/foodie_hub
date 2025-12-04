// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../db/db_helper.dart';

typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static NotificationTapCallback? onNotificationTap;

  /// Initialize notifications
  static Future<void> initialize({NotificationTapCallback? onTap}) async {
    tz.initializeTimeZones();
    onNotificationTap = onTap;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (onNotificationTap != null) onNotificationTap!(payload);
      },
    );
  }

  /// Show instant notification
  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final android = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Instant notifications like welcome/order',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: android);

    final id = DateTime.now().millisecondsSinceEpoch.remainder(1000000);

    await _plugin.show(id, title, body, details, payload: payload);

    // Save to DB
    await DBHelper.instance.insertNotification({
      'title': title,
      'body': body,
      'time': DateTime.now().toIso8601String(),
      'opened': 0,
    });
  }

  /// Schedule notification

  static Future<void> scheduleNotification({
    required int notifId,
    required String title,
    required String body,
    DateTime? firstScheduledUtc,
    int daysCount = 100,
    String? payload,
  }) async {
    final android = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications from admin',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: android);

    for (int i = 0; i < daysCount; i++) {
      final scheduledDate = firstScheduledUtc!.add(Duration(days: i));
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        notifId + i,
        title,
        body,
        tzScheduled,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Save each scheduled notification to DB
      await DBHelper.instance.insertNotification({
        'title': title,
        'body': body,
        'time': scheduledDate.toIso8601String(),
      });
    }
  }

  /// Cancel notification
  static Future<void> cancelNotification(int notifId) async {
    await _plugin.cancel(notifId);
  }

  /// Reschedule notification
  static Future<void> rescheduleNotification({
    required int oldNotifId,
    required int newNotifId,
    required String title,
    required String body,
    required DateTime scheduledUtc,
    String? payload,
  }) async {
    await cancelNotification(oldNotifId);
    await scheduleNotification(
      notifId: newNotifId,
      title: title,
      body: body,
      firstScheduledUtc: scheduledUtc,
    );
  }

  /// Schedule all pending notifications from DB at app start
  static Future<void> scheduleAllPending() async {
    final schedules = await DBHelper.instance.getSchedules();
    for (final sched in schedules) {
      try {
        final id = sched['id'] as int;
        final notifId = (sched['notifId'] as int?) ?? id + 1000;
        final title = sched['title'] as String;
        final body = sched['body'] as String;
        final scheduledUtc = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          sched['hour'] as int,
          sched['minute'] as int,
        ).toUtc();

        final finalScheduled = scheduledUtc.isBefore(DateTime.now().toUtc())
            ? scheduledUtc.add(const Duration(days: 1))
            : scheduledUtc;

        await scheduleNotification(
          notifId: notifId,
          title: title,
          body: body,
          firstScheduledUtc: finalScheduled,
        );
      } catch (_) {}
    }
  }
}
