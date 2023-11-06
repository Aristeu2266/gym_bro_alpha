import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_bro_alpha/models/workout_list_model.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/pages/auth_page.dart';
import 'package:gym_bro_alpha/pages/home_page.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';
import 'package:gym_bro_alpha/pages/reset_password_page.dart';
import 'package:gym_bro_alpha/pages/workout_page.dart';
import 'package:gym_bro_alpha/pages/settings_page.dart';
import 'package:gym_bro_alpha/pages/signup_page.dart';
import 'package:gym_bro_alpha/utils/custom_schemes.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
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
  late Database db;
  int themeSelected = 2;

  @override
  void initState() {
    super.initState();

    loadTheme().catchError((error) {
      setState(() {
        themeSelected = 2;
      });
    });
  }

  Future<void> loadTheme() async {
    db = await DB.instance.database;
    var result = await db.query(
      'user_prefs',
      limit: 1,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
    );

    if (result.isNotEmpty) {
      setState(() {
        themeSelected = result[0]['theme'] as int;
      });
    } else {
      setState(() {
        themeSelected = 2;
      });
    }
  }

  Future<void> handleThemeSelect(int? value) async {
    setState(() {
      themeSelected = value ?? themeSelected;
    });
    db = await DB.instance.database;
    Map<String, dynamic> data = {
      'uid': FirebaseAuth.instance.currentUser?.uid ?? 'null',
      'theme': themeSelected,
    };
    db
        .insert(
      'user_prefs',
      data,
    )
        .catchError((id) {
      return db.update(
        'user_prefs',
        data,
        where: 'uid = ?',
        whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutListModel(),
      child: MaterialApp(
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
          PageRoutes.root: (ctx) => AuthPage(refreshTheme: loadTheme),
          PageRoutes.login: (ctx) => const LoginPage(),
          PageRoutes.signup: (ctx) => const SignupPage(),
          PageRoutes.resetPassword: (ctx) => const ResetPasswordPage(),
          PageRoutes.home: (ctx) => HomePage(refreshTheme: loadTheme),
          PageRoutes.settings: (ctx) => SettingsPage(
              themeSelected: themeSelected,
              handleThemeSelect: handleThemeSelect),
          PageRoutes.workout: (ctx) => const WorkoutPage(),
        },
      ),
    );
  }
}
