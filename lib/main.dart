import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_bro_alpha/models/routine_list_model.dart';
import 'package:gym_bro_alpha/pages/add_exercises_page.dart';
import 'package:gym_bro_alpha/pages/exercise_page.dart';
import 'package:gym_bro_alpha/pages/filter_page.dart';
import 'package:gym_bro_alpha/pages/routine_page.dart';
import 'package:gym_bro_alpha/services/local_storage.dart';
import 'package:gym_bro_alpha/pages/auth_page.dart';
import 'package:gym_bro_alpha/pages/home_page.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';
import 'package:gym_bro_alpha/pages/reset_password_page.dart';
import 'package:gym_bro_alpha/pages/workout_page.dart';
import 'package:gym_bro_alpha/pages/settings_page.dart';
import 'package:gym_bro_alpha/pages/signup_page.dart';
import 'package:gym_bro_alpha/services/store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/custom_schemes.dart';
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
  int? themeSelected;

  @override
  void initState() {
    super.initState();

    loadTheme().catchError((error) {
      setState(() {
        themeSelected = 2;
      });
    });
  }

  Future<void> loadTheme([bool? uid]) async {
    db = await DB.instance.database;

    var result = await db.query(
      TableNames.userPrefs,
      where: 'uid = ?',
      whereArgs: [
        uid ?? false
            ? FirebaseAuth.instance.currentUser?.uid ?? 'null'
            : await Store.latestUId
      ],
    );

    if (result.isNotEmpty) {
      setState(() {
        themeSelected = result[0]['theme'] as int;
      });
    } else {
      setState(() {
        themeSelected = 2;
      });
      await db.insert(
        TableNames.userPrefs,
        {
          'uId': FirebaseAuth.instance.currentUser?.uid ?? 'null',
          'theme': 2,
        },
      ).catchError((_) {
        return 0;
      });
    }
  }

  Future<void> handleThemeSelect(int? value) async {
    setState(() {
      themeSelected = value ?? themeSelected;
    });
    db = await DB.instance.database;
    Map<String, dynamic> data = {
      'theme': themeSelected,
    };
    await db.update(
      TableNames.userPrefs,
      data,
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid ?? 'null'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoutineListModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gym Bro Alpha',
        // theme: themeSelected != null
        //     ? ThemeData(
        //         colorScheme: ColorScheme.fromSeed(
        //           seedColor: const Color(0xff6750a4),
        //           brightness: Brightness.light,
        //         ),
        //         brightness: Brightness.light,
        //         useMaterial3: true,
        //         fontFamily: 'Roboto',
        //       )
        //     : null,
        theme: themeSelected != null
            ? ThemeData(
                colorScheme: CustomSchemes.greyScheme(themeSelected != 2
                    ? Brightness.values[themeSelected!]
                    : Brightness.light),
                brightness: themeSelected != 2
                    ? Brightness.values[themeSelected!]
                    : Brightness.light,
                useMaterial3: true,
                fontFamily: 'Roboto',
              )
            : null,
        // darkTheme: themeSelected == 2
        //     ? ThemeData(
        //         colorScheme: ColorScheme.fromSeed(
        //           seedColor: const Color(0xff6750a4),
        //           brightness: Brightness.dark,
        //         ),
        //         brightness: Brightness.dark,
        //         useMaterial3: true,
        //         fontFamily: 'Roboto',
        //       )
        //     : null,
        darkTheme: themeSelected == 2
            ? ThemeData(
                colorScheme: CustomSchemes.greyScheme(Brightness.dark),
                brightness: Brightness.dark,
                useMaterial3: true,
                fontFamily: 'Roboto',
              )
            : null,
        routes: {
          // TODO: Loading page
          PageRoutes.root: (_) => themeSelected == null
              ? const Text('Loading')
              : AuthPage(refreshTheme: loadTheme),
          PageRoutes.login: (_) => const LoginPage(),
          PageRoutes.signup: (_) => const SignupPage(),
          PageRoutes.resetPassword: (_) => const ResetPasswordPage(),
          PageRoutes.home: (_) => HomePage(refreshTheme: loadTheme),
          PageRoutes.settings: (_) => SettingsPage(
                themeSelected: themeSelected ?? 2,
                handleThemeSelect: handleThemeSelect,
              ),
          PageRoutes.routine: (_) => const RoutinePage(),
          PageRoutes.workout: (_) => const WorkoutPage(),
          PageRoutes.addExercise: (_) => const AddExercisesPage(),
          PageRoutes.filter: (_) => const FilterPage(),
          PageRoutes.exercise: (_) => const ExercisePage(),
        },
      ),
    );
  }
}
