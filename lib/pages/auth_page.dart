import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';
import 'package:gym_bro_alpha/pages/verify_email_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({required this.refreshTheme, super.key});

  final Future<void> Function([bool?]) refreshTheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return VerifyEmailPage(refreshTheme: refreshTheme);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
