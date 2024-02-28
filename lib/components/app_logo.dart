import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/custom_icons.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    required this.color,
    required this.iconSize,
    required this.fontSize,
    this.showText = true,
    this.gap = 4,
    super.key,
  });

  final Color color;
  final double iconSize;
  final double fontSize;
  final double gap;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CustomIcons.logo,
          size: iconSize,
          color: color,
        ),
        if (showText)
          SizedBox(
            width: gap,
          ),
        if (showText)
          DefaultTextStyle(
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              color: color,
            ),
            child: const Text('GymBro'),
          ),
      ],
    );
  }
}
