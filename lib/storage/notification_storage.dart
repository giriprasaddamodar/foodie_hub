// lib/storage/notification_storage.dart
import '../db/db_helper.dart';

class NotificationStorage {
  /// Add notification record to local DB
  static Future<void> addNotification({
    required String title,
    required String body,
    required DateTime time,
    String? payload,
  }) async {
    await DBHelper.instance.insertNotification({
      "title": title,
      "body": body,
      "time": time.toIso8601String(),
      "payload": payload ?? "",
    });
  }

  /// Fetch all notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final rows = await DBHelper.instance.getNotifications();

    return rows.map((row) {
      return {
        "id": row["id"],
        "title": row["title"],
        "body": row["body"],
        "time": row["time"], // ISO string
        "payload": row["payload"] ?? "",
      };
    }).toList();
  }

  /// Delete notification by ID
  static Future<void> deleteNotification(int id) async {
    await DBHelper.instance.deleteNotification(id);
  }

  /// Clear all notifications
  static Future<void> clearNotifications() async {
    await DBHelper.instance.clearAllNotifications();
  }
}
