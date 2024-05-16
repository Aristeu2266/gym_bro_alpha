import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    required this.text,
    required this.addCallback,
    super.key,
  });

  final String text;
  final void Function() addCallback;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => addCallback(),
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
