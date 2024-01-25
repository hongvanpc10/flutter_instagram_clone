import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input(
      {super.key,
      this.hintText,
      this.textInputType,
      this.obscureText,
      this.controller,
      this.validator});

  final String? hintText;
  final TextInputType? textInputType;
  final bool? obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
      keyboardType: textInputType,
      obscureText: obscureText ?? false,
      validator: validator,
    );
  }
}
