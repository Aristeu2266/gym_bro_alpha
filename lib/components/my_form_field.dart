import 'package:flutter/material.dart';

class MyFormField extends StatelessWidget {
  const MyFormField({
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.errorText,
    this.contentPadding,
    this.leading,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final String? errorText;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? leading;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      decoration: InputDecoration(
          errorMaxLines: 2,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.surface),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onSurface),
              gapPadding: 0),
          hintText: hintText,
          filled: true,
          errorText: errorText,
          contentPadding: contentPadding,
          prefixIcon: leading),
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}
