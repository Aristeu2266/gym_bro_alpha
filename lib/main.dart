import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_bro_alpha/data/store.dart';
import 'package:gym_bro_alpha/pages/auth_page.dart';
import 'package:gym_bro_alpha/pages/home_page.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';
import 'package:gym_bro_alpha/pages/reset_password_page.dart';
import 'package:gym_bro_alpha/pages/settings_page.dart';
import 'package:gym_bro_alpha/pages/signup_page.dart';
import 'package:gym_bro_alpha/utils/custom_schemes.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int themeSelected = 2;

  @override
  void initState() {
    super.initState();
    Store.getInt('theme').then((value) {
      setState(() {
        themeSelected = value ?? 2;
      });
    }).catchError((error) {
      setState(() {
        themeSelected = 2;
      });
    });
  }

  void handleThemeSelect(int? value) {
    setState(() {
      themeSelected = value ?? themeSelected;
    });
    Store.saveInt('theme', themeSelected);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Bro Alpha',
      theme: ThemeData(
        colorScheme: CustomSchemes.greyScheme(themeSelected != 2
            ? Brightness.values[themeSelected]
            : Brightness.light),
        brightness: themeSelected != 2
            ? Brightness.values[themeSelected]
            : Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: themeSelected == 2
          ? ThemeData(
              colorScheme: CustomSchemes.greyScheme(Brightness.dark),
              brightness: Brightness.dark,
              useMaterial3: true,
              fontFamily: 'Roboto',
            )
          : null,
      routes: {
        PageRoutes.root: (ctx) => const AuthPage(),
        PageRoutes.login: (ctx) => const LoginPage(),
        PageRoutes.signup: (ctx) => const SignupPage(),
        PageRoutes.resetPassword: (ctx) => const ResetPasswordPage(),
        PageRoutes.home: (ctx) => const HomePage(),
        PageRoutes.settings: (ctx) => SettingsPage(
              themeSelected: themeSelected,
              handleThemeSelect: handleThemeSelect,
            ),
      },
    );
  }
}
