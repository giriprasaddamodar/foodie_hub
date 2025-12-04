import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/user_model.dart';
import '../widgets/background_container.dart';
import '../widgets/custom_textfield.dart';

class UserScreen extends StatefulWidget {
  final User? user; // current user to edit
  final Function refreshList; // refresh function from parent

  const UserScreen({
    super.key,
    this.user,
    required this.refreshList,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final phoneC = TextEditingController();
  final cityC = TextEditingController();

  String gender = "Male";
  bool declaration = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final e = widget.user!;
      nameC.text = e.name;
      gender = e.gender.isNotEmpty ? e.gender : "Male";
      emailC.text = e.email;
      passwordC.text = e.password;
      phoneC.text = e.phone;
      cityC.text = e.city;
      declaration = true;
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    phoneC.dispose();
    cityC.dispose();
    super.dispose();
  }

  Future<void> saveUser() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields properly.")),
      );
      return;
    }

    if (!declaration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please confirm the declaration.")),
      );
      return;
    }

    final updatedUser = User(
      id: widget.user?.id,
      name: nameC.text.trim(),
      email: emailC.text.trim(),
      password: passwordC.text.trim(),
      gender: gender,
      phone: phoneC.text.trim(),
      city: cityC.text.trim(),
    );

    final db = DBHelper.instance;
    final result = await db.updateUser(updatedUser);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account details updated successfully")),
      );
      widget.refreshList();
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Update Profile ️",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Form Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameC,
                            label: "Full Name",
                            textColor: Colors.white,
                            labelColor: Colors.grey,
                            validator: (v) =>
                            v == null || v.isEmpty ? "Enter Name" : null,
                          ),
                          const SizedBox(height: 15),

                          // 🔹 Gender
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Gender",
                              style: TextStyle(color: Colors.grey.shade300),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text("Male",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                  value: "Male",
                                  groupValue: gender,
                                  onChanged: (v) =>
                                      setState(() => gender = v!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text("Female",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                  value: "Female",
                                  groupValue: gender,
                                  onChanged: (v) =>
                                      setState(() => gender = v!),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: emailC,
                            label: "Email Address",
                            keyboardType: TextInputType.emailAddress,
                            textColor: Colors.white,
                            labelColor: Colors.grey,
                            validator: (v) =>
                            v == null || v.isEmpty ? "Enter Email" : null,
                          ),
                          CustomTextField(
                            controller: passwordC,
                            label: "Password",
                            isPassword: true,
                            textColor: Colors.white,
                            labelColor: Colors.grey,
                            validator: (v) =>
                            v == null || v.isEmpty ? "Enter Password" : null,
                          ),
                          CustomTextField(
                            controller: phoneC,
                            label: "Phone Number",
                            keyboardType: TextInputType.number,
                            textColor: Colors.white,
                            labelColor: Colors.grey,
                            validator: (v) => v == null || v.isEmpty
                                ? "Enter Phone Number"
                                : null,
                          ),
                          CustomTextField(
                            controller: cityC,
                            label: "City",
                            textColor: Colors.white,
                            labelColor: Colors.grey,
                            validator: (v) =>
                            v == null || v.isEmpty ? "Enter City" : null,
                          ),

                          // 🔹 Declaration Checkbox
                          CheckboxListTile(
                            title: const Text(
                              "I confirm all details are correct",
                              style: TextStyle(color: Colors.white),
                            ),
                            value: declaration,
                            onChanged: (v) =>
                                setState(() => declaration = v ?? false),
                            activeColor: Colors.deepOrangeAccent,
                          ),
                          const SizedBox(height: 16),

                          // 🔹 Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: declaration ? saveUser : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Update User",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
