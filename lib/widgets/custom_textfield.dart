import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? errorText;
  final void Function(String)? onChanged;
  final Color textColor;
  final Color labelColor;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.isPassword = false,
    this.errorText,
    this.onChanged,
    this.textColor = Colors.white,
    this.labelColor = Colors.white,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        obscureText: widget.isPassword ? _obscureText : false,
        onChanged: widget.onChanged,
        validator: widget.validator,
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: widget.labelColor),
          border: const OutlineInputBorder(),
          errorText: widget.errorText,
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}
