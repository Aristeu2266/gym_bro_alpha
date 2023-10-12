import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_bro_alpha/pages/home_page.dart';
import 'package:gym_bro_alpha/pages/settings_page.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ColorSeed colorSelected = ColorSeed.baseColor;

  void handleColorSelect(int? value) {
    setState(() {
      colorSelected = value != null ? ColorSeed.values[value] : colorSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Bro Alpha',
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
      ),
      routes: {
        PageRoutes.home: (ctx) => const HomePage(),
        PageRoutes.settings: (ctx) => SettingsPage(
          colorSelected: colorSelected,
              handleColorSelect: handleColorSelect,
            ),
      },
    );
  }
}
