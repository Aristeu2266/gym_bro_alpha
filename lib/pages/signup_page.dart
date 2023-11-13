import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/app_logo.dart';
import 'package:gym_bro_alpha/components/auth_form.dart';
import 'package:gym_bro_alpha/components/sign_bottom_text.dart';
import 'package:gym_bro_alpha/pages/login_page.dart';
import 'package:gym_bro_alpha/services/auth_service.dart';
import 'package:gym_bro_alpha/services/store.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/utils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  bool _isLoading = false;
  bool _showName = true;
  late Future _nameChange;

  void _changeShowName() {
    setState(() {
      _showName = !_showName;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _nameChange = Future.delayed(
      const Duration(milliseconds: 400),
      _changeShowName,
    );
  }

  @override
  void dispose() {
    _nameChange.ignore();
    _controller!.dispose();
    super.dispose();
  }

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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: AppLogo(
                key: UniqueKey(),
                color: colorScheme.onPrimaryContainer,
                iconSize: 60,
                fontSize: 36,
                showText: _showName,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  FadeTransition(
                    opacity: _fadeAnimation!,
                    child: const Row(
                      children: [
                        Text(
                          'Create\nAccount',
                          style: TextStyle(
                            fontSize: 48,
                            height: 1.1,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  const AuthForm('signup'),
                  const Spacer(flex: 2),
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
                  SizedBox(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'googlepic',
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await AuthService.signInWithGoogle();
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        Utils.showSnackbar(
                                          context,
                                          'Connection failed',
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      padding: const EdgeInsets.all(10)),
                                  child: Image.asset(
                                    fit: BoxFit.fill,
                                    'assets/images/google.png',
                                    height: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Hero(
                                tag: 'anonymous',
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await Store.updateSignInDate('null').then(
                                      (_) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          PageRoutes.home,
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      padding: const EdgeInsets.all(10)),
                                  child: Image.asset(
                                    fit: BoxFit.fill,
                                    'assets/images/anonymous.png',
                                    height: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
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
