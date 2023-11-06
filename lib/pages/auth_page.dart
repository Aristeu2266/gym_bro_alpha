import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/pages/home_page.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';
import 'package:gym_bro_alpha/pages/verify_email_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({required this.refreshTheme, super.key});

  final Future<void> Function() refreshTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (FirebaseAuth.instance.currentUser!.emailVerified) {
              return HomePage(refreshTheme: refreshTheme);
            }
            return const VerifyEmailPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
