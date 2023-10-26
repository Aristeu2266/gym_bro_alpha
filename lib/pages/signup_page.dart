import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/app_logo.dart';
import 'package:gym_bro_alpha/components/auth_form.dart';
import 'package:gym_bro_alpha/components/sign_bottom_text.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Hero(
            tag: 'logo',
            child: AppLogo(
              color: colorScheme.onPrimaryContainer,
              iconSize: 60,
              fontSize: 36,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 25,
              ),
              child: Column(
                children: [
                  Spacer(flex: 1),
                  AuthForm('signup'),
                  Spacer(flex: 1),
                ],
              ),
            ),
          ),
          SignBottomText(
            clickable: 'Already have an account?',
            color: colorScheme.primary,
            page: const LoginPage(),
          ),
        ],
      ),
    );
  }
}
