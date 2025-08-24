import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.obscureText,
  });

  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80, // increased height for better touch target & design match
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 20, // slightly bigger text
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hintText: hintText,
          hintStyle: TextStyle(
            color: cs.onSurface.withOpacity(0.5),
            fontSize: 15,
          ),
          filled: true,
          fillColor: cs.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cs.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cs.outlineVariant, width: 1.5),
          ),
        ),
      ),
    );
  }
}
