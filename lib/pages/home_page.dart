import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/workout_list_model.dart';
import 'package:gym_bro_alpha/pages/workout_list_page.dart';
import 'package:gym_bro_alpha/pages/start_page.dart';
import 'package:gym_bro_alpha/services/store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.refreshTheme, super.key});

  final Future<void> Function([bool?]) refreshTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int screenIndex = ScreenSelected.start.value;
  late PageController pageController;
  late WorkoutListModel workoutListModel =
      Provider.of<WorkoutListModel>(context, listen: false);

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: screenIndex);
    _init();
  }

  Future<void> _init() async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (await Store.firstTimeUser) {
        await Store.loadUserData();
      }
      Connectivity().onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          Store.uploadMissing();
        }
      });
    }

    widget.refreshTheme(true);
    await workoutListModel.load();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  PreferredSizeWidget appBar() {
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
    if (screenSelected != screenIndex) {
      pageController.animateToPage(screenSelected,
          duration: const Duration(milliseconds: 1), curve: Curves.ease);
      setState(() {
        screenIndex = screenSelected;
      });
    } else if (screenSelected == 2) {
      Navigator.pushNamed(context, PageRoutes.workout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) => setState(() => screenIndex = value),
        children: [
          Column(
            children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.bar_chart),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const StartPage(),
          const WorkoutListPage(),
        ],
      ),
      extendBody: false,
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
