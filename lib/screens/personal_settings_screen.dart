import 'package:flutter/material.dart';
import 'package:foodie_hub/screens/user_screen.dart';
import '../db/db_helper.dart';
import '../models/user_model.dart';
import '../widgets/background_container.dart';
import 'entry_screen.dart';

class PersonalSettingsScreen extends StatefulWidget {
  final User currentUser;
  const PersonalSettingsScreen({super.key, required this.currentUser});

  @override
  State<PersonalSettingsScreen> createState() => _PersonalSettingsScreenState();
}

class _PersonalSettingsScreenState extends State<PersonalSettingsScreen> {
  final DBHelper dbHelper = DBHelper.instance;
  late User user; //  local copy of the user

  @override
  void initState() {
    super.initState();
    user = widget.currentUser;
    _loadUserData();
  }

  //  Load latest user info from DB
  Future<void> _loadUserData() async {
    final dbUser = await DBHelper.instance
        .getUserByEmailPassword(user.email, user.password);
    if (dbUser != null) {
      setState(() => user = dbUser);
    }
  }

  //  Refresh after user updates info
  Future<void> _refreshUser() async {
    final updatedUser = await dbHelper.getUserById(user.id!);
    if (updatedUser != null) {
      setState(() {
        user = updatedUser;
      });
    }
  }

  //  Open Edit User Screen
  void _openAccountDetails() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserScreen(
          user: user,
          refreshList: _refreshUser,
        ),
      ),
    );

    if (updated == true) {
      await _refreshUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account updated successfully")),
      );
    }
  }

  // Logout confirmation
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () {
              // Remove all previous screens and go to EntryScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const EntryScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/profile.gif'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Account Details',
                    style: TextStyle(color: Colors.white)),
                onTap: _openAccountDetails,
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text('Privacy Settings',
                    style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
