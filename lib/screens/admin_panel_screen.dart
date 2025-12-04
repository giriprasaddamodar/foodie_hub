// lib/screens/admin_panel_screen.dart
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../services/notification_service.dart';
import '../storage/notification_storage.dart';
import '../widgets/background_container.dart';
import 'schedules_screen.dart';
import 'entry_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  TimeOfDay? pickedTime;
  final TextEditingController idController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => pickedTime = t);
  }

  Future<void> _addOrUpdateSchedule() async {
    if (pickedTime == null || titleController.text.isEmpty || bodyController.text.isEmpty) return;

    final int id = int.tryParse(idController.text) ?? DateTime.now().millisecondsSinceEpoch;

    final schedule = {
      'id': id,
      'title': titleController.text,
      'body': bodyController.text,
      'hour': pickedTime!.hour,
      'minute': pickedTime!.minute,
    };

    final scheduledTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      pickedTime!.hour,
      pickedTime!.minute,
    );

    final finalScheduledTime = scheduledTime.isBefore(DateTime.now())
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    final existingSchedules = await DBHelper.instance.getSchedules();
    final exists = existingSchedules.any((s) => s['id'] == id);

    if (exists) {
      await DBHelper.instance.updateSchedule(schedule);
      await NotificationService.rescheduleNotification(
        oldNotifId: id,
        newNotifId: id,
        title: schedule['title'] as String,
        body: schedule['body'] as String,
        scheduledUtc: finalScheduledTime.toUtc(),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule updated')));
    } else {
      await DBHelper.instance.insertSchedule(schedule);
      await NotificationService.scheduleNotification(
        notifId: id,
        title: schedule['title'] as String,
        body: schedule['body'] as String,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule added')));
    }

    // Save history
    await NotificationStorage.addNotification(title: schedule['title'] as String, body: schedule['body'] as String, time: DateTime.now());

    // Clear fields
    idController.clear();
    titleController.clear();
    bodyController.clear();
    pickedTime = null;
    setState(() {});
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const EntryScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Admin: Notification Manager', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.red,), onPressed: _logout),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: idController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Notification ID'), style: TextStyle(color: Colors.white),),
              const SizedBox(height: 8),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title'), style: TextStyle(color: Colors.white),),
              const SizedBox(height: 8),
              TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Body'), style: TextStyle(color: Colors.white),),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _pickTime, child: Text(pickedTime == null ? 'Pick Time' : pickedTime!.format(context), style: TextStyle(color: Colors.white),), style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _addOrUpdateSchedule, child: const Text('Add / Update Schedule', style: TextStyle(color: Colors.white),), style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchedulesScreen())),
                  child: const Text('View Schedules', style: TextStyle(color: Colors.white),), style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              )),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
