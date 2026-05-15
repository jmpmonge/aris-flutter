import 'package:flutter/material.dart';

/// Campo de texto alineado con el tema Aris.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }
}
