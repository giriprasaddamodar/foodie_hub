// Updated EntryScreen with added notification logic
// (Your existing code preserved; only required additions included)

import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'admin_panel_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePass = true;

  String? emailError;
  String? passError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.grey.shade800),
    );
  }

  void _validateEmail(String value) {
    setState(() {
      emailError = value.isEmpty
          ? "Please enter email"
          : !value.endsWith('@gmail.com') && value != "admin@foodiehub.com"
          ? "Email must end with @gmail.com"
          : null;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      passError = value.isEmpty ? "Please enter password" : null;
    });
  }

  bool _isAdmin(String email, String password) {
    return email == "admin@foodiehub.com" && password == "admin123";
  }

  // LOGIN
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    _validateEmail(email);
    _validatePassword(password);
    if (emailError != null || passError != null) return;

    setState(() => isLoading = true);

    // ADMIN LOGIN
    if (_isAdmin(email, password)) {
      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
      return;
    }

    // USER LOGIN
    try {
      final user = await DBHelper.instance.getUserByEmailPassword(email, password);

      setState(() => isLoading = false);

      if (user == null) {
        bool exists = await DBHelper.instance.checkUserExists(email);
        if (exists) {
          _showMsg("Invalid password.");
        } else {
          _showMsg("No account found. Switch to register.");
          setState(() => isLogin = false);
        }
        return;
      }

      // FIRST TIME OR RETURN LOGIN NOTIFICATIONS
      bool firstTime = await DBHelper.instance.isFirstTimeUser();

      if (firstTime) {
        await NotificationService.showInstantNotification(
          title: "Welcome to FoodieHub!",
          body: "Thanks for joining 🍔 Enjoy your dishes!",
        );
        await DBHelper.instance.setFirstTime(0);
      } else {
        await NotificationService.showInstantNotification(
          title: "Welcome Back!",
          body: "Glad to see you again 😊",
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      _showMsg("Something went wrong.");
    }
  }

  // REGISTER
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    _validateEmail(email);
    _validatePassword(password);
    if (emailError != null || passError != null) return;

    if (email == "admin@foodiehub.com") {
      _showMsg("This email is reserved for admin.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final exists = await DBHelper.instance.checkUserExists(email);
      if (exists) {
        _showMsg("Email already registered. Please login.");
        setState(() {
          isLogin = true;
          isLoading = false;
        });
        return;
      }

      final newUser = User(
        name: email.split('@')[0],
        email: email,
        password: password,
        gender: '',
        phone: '',
        city: '',
      );

      final inserted = await DBHelper.instance.insertUser(newUser);
      setState(() => isLoading = false);

      if (inserted == -1) {
        _showMsg("Registration failed.");
        return;
      }

      await DBHelper.instance.setFirstTime(1);

      // INSTANT WELCOME NOTIFICATION
      await NotificationService.showInstantNotification(
        title: "Welcome to FoodieHub!",
        body: "Thanks for joining 🍔 Enjoy your dishes!",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(currentUser: newUser)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      _showMsg("Something went wrong.");
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdHelper.showAd();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/logo.png', fit: BoxFit.fill),
          Container(color: Colors.black.withOpacity(0.7)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: _validateEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: emailError,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePass,
                    style: const TextStyle(color: Colors.white),
                    onChanged: _validatePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: passError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePass ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() => obscurePass = !obscurePass),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: isLogin ? login : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isLogin ? "Login" : "Register",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "Don’t have an account? Register"
                          : "Already registered? Login",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}