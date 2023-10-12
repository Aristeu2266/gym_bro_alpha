import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.colorSelected,
    required this.handleColorSelect,
    super.key,
  });

  final void Function(int?) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 10.0),
            child: DropdownMenu<int>(
              label: const Text('Color'),
              trailingIcon: Icon(
                Icons.color_lens_outlined,
                color: widget.colorSelected.color,
              ),
              enableFilter: false,
              dropdownMenuEntries: ColorSeed.values
                  .map((e) => DropdownMenuEntry<int>(
                        value: e.index,
                        label: e.label,
                      ))
                  .toList(),
              inputDecorationTheme: const InputDecorationTheme(filled: true),
              onSelected: (value) {
                widget.handleColorSelect(value);
              },
              width: screenSize.width-16,
              initialSelection: widget.colorSelected.index,
            ),
          ),
        ],
      ),
    );
  }
}
