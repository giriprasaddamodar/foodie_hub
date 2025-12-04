// lib/screens/schedules_screen.dart
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../services/notification_service.dart';
import '../widgets/background_container.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});
  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    schedules = await DBHelper.instance.getSchedules();
    setState(() {});
  }

  Future<void> _deleteSchedule(int index) async {
    final int id = schedules[index]['id'] as int;
    await DBHelper.instance.deleteSchedule(id);
    await NotificationService.cancelNotification(id);
    await _loadFromDb();
  }

  Future<void> _editScheduleDialog(int index) async {
    final original = schedules[index];
    final idController = TextEditingController(text: original['id'].toString());
    final titleController = TextEditingController(text: original['title']);
    final bodyController = TextEditingController(text: original['body']);
    TimeOfDay picked = TimeOfDay(hour: original['hour'] as int, minute: original['minute'] as int);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Schedule'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: idController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID')),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Body')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: picked);
                  if (t != null) picked = t;
                  setState(() {});
                },
                child: Text('Pick Time: ${picked.format(context)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final updated = {
                'id': int.tryParse(idController.text) ?? original['id'],
                'title': titleController.text,
                'body': bodyController.text,
                'hour': picked.hour,
                'minute': picked.minute,
              };

              await DBHelper.instance.updateSchedule(updated);

              await NotificationService.rescheduleNotification(
                oldNotifId: original['id'] as int,
                newNotifId: updated['id'] as int,
                title: updated['title'] as String,
                body: updated['body'] as String,
                scheduledUtc: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  updated['hour'],
                  updated['minute'],
                ).toUtc(),
              );

              await _loadFromDb();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Existing Schedules', style: TextStyle(color: Colors.white),), backgroundColor: Colors.transparent),
      body: schedules.isEmpty
          ? const Center(child: Text('No schedules added yet', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (ctx, i) {
          final s = schedules[i];
          return Card(
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Text(_formatTime(s['hour'] as int, s['minute'] as int), style: TextStyle(color: Colors.grey),),
              title: Text(s['title'] as String, style: TextStyle(color: Colors.white),),
              subtitle: Text(s['body'] as String, style: TextStyle(color: Colors.grey),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _editScheduleDialog(i)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSchedule(i)),
                ],
              ),
            ),
          );
        },
      ),
    ),
    );
  }
}
