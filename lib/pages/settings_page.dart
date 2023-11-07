import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/services/auth_service.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.themeSelected,
    required this.handleThemeSelect,
    super.key,
  });

  final int themeSelected;
  final void Function(int?) handleThemeSelect;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ThemeSelectMenu(
                themeSelected: themeSelected,
                colorScheme: colorScheme,
                handleThemeSelect: handleThemeSelect,
                screenSize: screenSize,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                AuthService.signOut().then(
                  (_) =>
                      Navigator.pushReplacementNamed(context, PageRoutes.root),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onInverseSurface,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: const AlignmentDirectional(-1, 0),
                padding: const EdgeInsets.only(left: 12),
              ),
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSelectMenu extends StatelessWidget {
  const ThemeSelectMenu({
    super.key,
    required this.themeSelected,
    required this.colorScheme,
    required this.handleThemeSelect,
    required this.screenSize,
  });

  final int themeSelected;
  final ColorScheme colorScheme;
  final void Function(int? p1) handleThemeSelect;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      enableSearch: false,
      label: const Text('Theme'),
      trailingIcon: Icon(
        themeSelected == Brightness.light.index
            ? Icons.light_mode
            : themeSelected != 2
                ? Icons.dark_mode
                : Icons.brightness_auto_sharp,
        color: colorScheme.onPrimaryContainer,
      ),
      enableFilter: false,
      dropdownMenuEntries: [
        DropdownMenuEntry<int>(
          value: 1,
          label: 'Light',
          trailingIcon: Icon(
            Icons.light_mode,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        DropdownMenuEntry<int>(
          value: 0,
          label: 'Dark',
          trailingIcon: Icon(
            Icons.dark_mode,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        DropdownMenuEntry<int>(
          value: 2,
          label: 'Auto',
          trailingIcon: Icon(
            Icons.brightness_auto_sharp,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
      inputDecorationTheme: const InputDecorationTheme(filled: true),
      onSelected: (value) {
        handleThemeSelect(value);
      },
      width: screenSize.width - 16,
      initialSelection: themeSelected,
    );
  }
}
