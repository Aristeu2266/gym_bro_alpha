import 'package:flutter/material.dart';

class CustomSchemes {
  static ColorScheme greyScheme(Brightness brightness) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff6750a4),
      brightness: brightness,
    );

    ColorScheme newScheme = brightness == Brightness.light
        ? colorScheme.copyWith()
        : colorScheme.copyWith(
            // onSurfaceVariant: Colors.amber,
            );

    // ColorScheme newScheme = brightness == Brightness.light
    //     ? colorScheme.copyWith(
    //         primary: colorScheme.secondary,
    //         onPrimary: colorScheme.inversePrimary, //colorScheme.onSecondary,
    //         primaryContainer: colorScheme.secondaryContainer,
    //         onPrimaryContainer: colorScheme.onSecondaryContainer,
    //         secondary: Colors.white,
    //         onSecondary: const Color(0xff1c1b1e),
    //         inversePrimary: colorScheme.inverseSurface)
    //     : colorScheme.copyWith(
    //         primary: colorScheme.secondary,
    //         onPrimary: colorScheme.onSecondary,
    //         primaryContainer: colorScheme.secondaryContainer,
    //         onPrimaryContainer: colorScheme.onSecondaryContainer,
    //         secondary: Colors.white,
    //         onSecondary: const Color(0xff1c1b1e),
    //         inversePrimary: colorScheme.inverseSurface);

    return newScheme;
  }
}
