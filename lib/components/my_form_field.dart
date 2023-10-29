import 'package:flutter/material.dart';

class MyFormField extends StatelessWidget {
  const MyFormField({
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.errorText,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      decoration: InputDecoration(
        errorMaxLines: 2,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.background),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.onBackground),
            gapPadding: 0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
        ),
        fillColor: colorScheme.primaryContainer,
        filled: true,
        errorText: errorText,
      ),
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
