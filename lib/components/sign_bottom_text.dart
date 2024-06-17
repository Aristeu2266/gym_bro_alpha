import 'package:flutter/material.dart';

class SignBottomText extends StatelessWidget {
  SignBottomText({
    this.text,
    required this.color,
    this.clickable,
    this.onTap,
    super.key,
  }) {
    assert(text != null || clickable != null);
    assert((clickable != null && onTap != null) ||
        (clickable == null && onTap == null));
  }

  final String? text;
  final Color color;
  final String? clickable;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Column(
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (text != null) Text(text!),
                if (clickable != null)
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      clickable!,
                      style: TextStyle(
                        color: color,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
