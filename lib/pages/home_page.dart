import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/pages/routines_page.dart';
import 'package:gym_bro_alpha/pages/start_page.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int screenIndex = ScreenSelected.start.value;

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
          },
        ),
      ],
    );
  }

  void handleScreenChanged(int screenSelected) {
    setState(() {
      screenIndex = screenSelected;
    });
  }

  Widget createScreenFor(ScreenSelected screenSelected) {
    switch (screenSelected) {
      case ScreenSelected.statistics:
        return Column(
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {},
              ),
            ),
          ],
        );
      case ScreenSelected.start:
        return const StartPage();
      case ScreenSelected.add:
        return const RoutinesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: createScreenFor(ScreenSelected.values[screenIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: screenIndex,
        destinations: ScreenSelected.values
            .map(
              (e) => NavigationDestination(
                icon: e.icon,
                label: e.name,
              ),
            )
            .toList(),
        onDestinationSelected: (value) => handleScreenChanged(value),
      ),
    );
  }
}
