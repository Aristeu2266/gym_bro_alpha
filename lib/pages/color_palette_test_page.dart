import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/custom_schemes.dart';

class ColorPaletteTestPage extends StatelessWidget {
  const ColorPaletteTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme myLightScheme = CustomSchemes.greyScheme(Brightness.light);
    ColorScheme myDarkScheme = CustomSchemes.greyScheme(Brightness.dark);
    ColorScheme lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff6750a4),
      brightness: Brightness.light,
    );
    ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff6750a4),
      brightness: Brightness.dark,
    );

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Light'),
                Text('Dark'),
              ],
            ),
            Row(
              children: [
                GridColors(lightScheme),
                const Spacer(flex: 1),
                GridColors(myLightScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GridColors extends StatelessWidget {
  const GridColors(
    this.scheme, {
    super.key,
  });

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Column(
        children: [
          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              GridTile(
                child: Container(
                  color: scheme.primary,
                  child: Text(
                    'primary',
                    style: TextStyle(
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onPrimary,
                  child: Text(
                    'onPrimary',
                    style: TextStyle(
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.primaryContainer,
                  child: Text(
                    'primaryContainer',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onPrimaryContainer,
                  child: Text(
                    'onPrimaryContainer',
                    style: TextStyle(
                      color: scheme.primaryContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.secondary,
                  child: Text(
                    'secondary',
                    style: TextStyle(
                      color: scheme.onSecondary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onSecondary,
                  child: Text(
                    'onSecondary',
                    style: TextStyle(
                      color: scheme.secondary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.secondaryContainer,
                  child: Text(
                    'secondaryContainer',
                    style: TextStyle(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onSecondaryContainer,
                  child: Text(
                    'onSecondaryContainer',
                    style: TextStyle(
                      color: scheme.secondaryContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.tertiary,
                  child: Text(
                    'tertiary',
                    style: TextStyle(
                      color: scheme.onTertiary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onTertiary,
                  child: Text(
                    'onTertiary',
                    style: TextStyle(
                      color: scheme.tertiary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.tertiaryContainer,
                  child: Text(
                    'tertiaryContainer',
                    style: TextStyle(
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onTertiaryContainer,
                  child: Text(
                    'onTertiaryContainer',
                    style: TextStyle(
                      color: scheme.tertiaryContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.error,
                  child: Text(
                    'error',
                    style: TextStyle(
                      color: scheme.onError,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.errorContainer,
                  child: Text(
                    'errorContainer',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onError,
                  child: Text(
                    'onError',
                    style: TextStyle(
                      color: scheme.error,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onErrorContainer,
                  child: Text(
                    'onErrorContainer',
                    style: TextStyle(
                      color: scheme.errorContainer,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.background,
                  child: Text(
                    'background',
                    style: TextStyle(
                      color: scheme.onBackground,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.inversePrimary,
                  child: Text(
                    'inversePrimary',
                    style: TextStyle(
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.inverseSurface,
                  child: Text(
                    'inverseSurface',
                    style: TextStyle(
                      color: scheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onBackground,
                  child: Text(
                    'onBackground',
                    style: TextStyle(
                      color: scheme.background,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onInverseSurface,
                  child: Text(
                    'onInverseSurface',
                    style: TextStyle(
                      color: scheme.inverseSurface,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onSurface,
                  child: Text(
                    'onSurface',
                    style: TextStyle(
                      color: scheme.surface,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.onSurfaceVariant,
                  child: Text(
                    'onSurfaceVariant',
                    style: TextStyle(
                      color: scheme.surfaceVariant,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.outline,
                  child: const Text(
                    'outline*',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.outlineVariant,
                  child: const Text(
                    'outlineVariant*',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.scrim,
                  child: const Text(
                    'scrim*',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.shadow,
                  child: const Text(
                    'shadow*',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.surface,
                  child: Text(
                    'surface',
                    style: TextStyle(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.surfaceTint,
                  child: const Text(
                    'surfaceTint*',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GridTile(
                child: Container(
                  color: scheme.surfaceVariant,
                  child: Text(
                    'surfaceVariant',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
