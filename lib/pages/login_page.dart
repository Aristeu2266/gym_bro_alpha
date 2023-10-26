import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/app_logo.dart';
import 'package:gym_bro_alpha/components/sign_bottom_text.dart';
import 'package:gym_bro_alpha/pages/signup_page.dart';

import '../components/auth_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      //logo
                      Expanded(
                        flex: 3,
                        child: Hero(
                          tag: 'logo',
                          child: AppLogo(
                            color: colorScheme.onPrimaryContainer,
                            iconSize: 60,
                            fontSize: 36,
                          ),
                        ),
                      ),
                      // Formulário
                      const AuthForm('signin'),
                      const Spacer(
                        flex: 2,
                      )
                    ],
                  ),
                ),
              ),
              SignBottomText(
                color: colorScheme.primary,
                text: 'Don\'t have an account? ',
                clickable: 'Sign Up.',
                page: const SignupPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
