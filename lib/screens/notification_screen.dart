import 'package:flutter/material.dart';
import 'package:foodie_hub/widgets/background_container.dart';
import '../storage/notification_storage.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await NotificationStorage.getNotifications();

    // Convert UTC to local and sort by time ascending
    data.sort((a, b) {
      final t1 = DateTime.parse(a['time']).toLocal();
      final t2 = DateTime.parse(b['time']).toLocal();
      return t1.compareTo(t2);
    });

    setState(() => notifications = data);
  }

  String _formatTime(String isoTime) {
    final utcTime = DateTime.parse(isoTime);
    final localTime = utcTime.toLocal();
    // return DateFormat('dd MMM yyyy, hh:mm a').format(localTime);
    return '${localTime.hour.toString().padLeft(2,'0')}:${localTime.minute.toString().padLeft(2,'0')} , ${localTime.day.toString().padLeft(2,'0')}-${localTime.month.toString().padLeft(2,'0')}-${localTime.year.toString().padLeft(2,'0')}';

  }



  Future<void> _clearAll() async {
    await NotificationStorage.clearNotifications();
    setState(() => notifications.clear());
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red,),
            onPressed: _clearAll,
          )
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications yet!"))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Card(
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(item['title'], style: TextStyle(color: Colors.white),),
              subtitle: Text(item['body'], style: TextStyle(color: Colors.grey),),
              trailing: Text(
                _formatTime(item['time']),
                style: const TextStyle(color:Colors.grey, fontSize: 12),
              ),
            ),
          );
        },

      )
        ),
    );
  }
}
