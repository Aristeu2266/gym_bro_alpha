import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    this.text,
    required this.onTap,
    this.leadingWidget,
    super.key,
  });

  final String? text;
  final void Function() onTap;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.onBackground,
        foregroundColor: colorScheme.background,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingWidget != null) leadingWidget!,
          if (leadingWidget != null) const SizedBox(width: 6),
          if (text != null)
            Text(
              text!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
