import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage(
      {super.key});

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      title: const Text('GymBro'),
      centerTitle: true,
      actions: [
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed(PageRoutes.settings);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SettingsPage(
            //       colorSelected: colorSelected,
            //       handleColorSelect: handleColorSelect,
            //     ),
            //   ),
            // );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: null,
    );
  }
}
