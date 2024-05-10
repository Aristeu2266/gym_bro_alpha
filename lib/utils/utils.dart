import 'package:flutter/material.dart';

class Utils {
  static void showSnackbar(BuildContext context, String text,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        action: action,
      ),
    );
  }

  static String capitalize(String text) {
    return text.replaceRange(0, 1, text.substring(0, 1).toUpperCase());
  }
}
