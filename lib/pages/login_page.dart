import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/app_logo.dart';
import 'package:gym_bro_alpha/components/sign_bottom_text.dart';
import 'package:gym_bro_alpha/services/auth_service.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/utils.dart';

import '../components/auth_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

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
                        flex: 16,
                        child: Hero(
                          tag: 'logo',
                          child: AppLogo(
                            color: colorScheme.onSurface,
                            iconSize: 60,
                            fontSize: 36,
                          ),
                        ),
                      ),
                      // Formulário
                      const AuthForm('signin'),

                      const Spacer(flex: 1),

                      const Hero(
                        tag: 'orcontinue',
                        child: Material(
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('Or continue with'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      SizedBox(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Hero(
                                tag: 'googlepic',
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await AuthService.signInWithGoogle();
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      Utils.showSnackbar(
                                        context,
                                        'Connection failed',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/google.png',
                                          height: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Log in with Google'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const Spacer(flex: 2),
                      if (!_isLoading)
                        Hero(
                          tag: 'anonymous',
                          child: TextButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              Navigator.pushReplacementNamed(
                                context,
                                PageRoutes.home,
                              );
                            },
                            style: TextButton.styleFrom(
                              minimumSize: const Size(250, 40),
                            ),
                            child: Text('Continue without an account',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    overflow: TextOverflow.visible),
                                maxLines: 1,
                                overflow: TextOverflow.visible),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              SignBottomText(
                color: colorScheme.primary,
                text: 'Don\'t have an account? ',
                clickable: 'Sign Up.',
                onTap: () => Navigator.of(context).pushNamed(PageRoutes.signup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
