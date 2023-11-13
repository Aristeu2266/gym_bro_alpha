import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/exceptions/auth_exceptions.dart';
import 'package:gym_bro_alpha/services/auth_service.dart';
import 'package:gym_bro_alpha/utils/constants.dart';
import 'package:gym_bro_alpha/utils/utils.dart';

import 'my_button.dart';
import 'my_form_field.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(this.sign, {super.key});

  final String sign;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  AnimationController? _enterController;
  Animation<double>? _sizeAnimation;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  AuthException? validateException;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();

    _sizeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _enterController!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _enterController!.dispose();
    super.dispose();
  }

  bool _isSignin() {
    return widget.sign == 'signin';
  }

  Future<void> submitForm() async {
    setState(() => validateException = null);

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    try {
      if (widget.sign == 'signin') {
        await AuthService.signIn(_authData['email']!, _authData['password']!)
            .then(
          (_) => Navigator.pushReplacementNamed(context, PageRoutes.root),
        );
      } else {
        await AuthService.signUp(_authData['email']!, _authData['password']!)
            .then((_) async {
          await AuthService.signIn(_authData['email']!, _authData['password']!);
        }).then(
          (_) => Navigator.pushReplacementNamed(context, PageRoutes.root),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code != 'network-request-failed') {
        setState(() => validateException = AuthException(e.code));
      } else if (context.mounted) {
        Utils.showSnackbar(context, 'Connection failed');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? password) {
    password ??= '';

    if (password.isEmpty) {
      return 'Invalid password';
    } else if (widget.sign == 'signup') {
      if (RegExp(r'^[\s]|[\s]$').hasMatch(password)) {
        return 'Password can\'t begin or end with blanck spaces';
      } else if (!RegExp(r'[A-Za-z\d@$!%*#?&\s]{6,}').hasMatch(password)) {
        return 'Password must be at least 6 characters long';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Hero(
            tag: 'email',
            child: Material(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 80),
                child: MyFormField(
                  controller: _emailController,
                  hintText: 'Email',
                  validator: (email) =>
                      (email ?? '').isEmpty ? 'Invalid email' : null,
                  onSaved: (email) => _authData['email'] = email?.trim() ?? '',
                  errorText: validateException?.key != 'weak-password'
                      ? validateException?.toString()
                      : null,
                ),
              ),
            ),
          ),
          Hero(
            tag: 'password',
            child: Material(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 80, maxHeight: 80),
                child: MyFormField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (password) => _validatePassword(password),
                  onSaved: (password) => _authData['password'] = password ?? '',
                  errorText: validateException?.key != 'weak-password'
                      ? null
                      : validateException?.toString(),
                ),
              ),
            ),
          ),
          if (!_isSignin())
            ScaleTransition(
              scale: _sizeAnimation!,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 72),
                child: MyFormField(
                  hintText: 'Confirm Password',
                  obscureText: true,
                  validator: !_isSignin()
                      ? (password) {
                          return (password ?? '') != _passwordController.text
                              ? 'Passwords doesn\'t match'
                              : null;
                        }
                      : null,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isSignin())
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, PageRoutes.resetPassword,
                        arguments: _emailController.text),
                    child: const Text('Forgot password?'),
                  ),
              ],
            ),
          ),
          Hero(
            tag: 'signbutton',
            child: _isLoading
                ? const CircularProgressIndicator()
                : MyButton(
                    text: _isSignin() ? 'Log In' : 'Sign Up',
                    onTap: submitForm,
                  ),
          ),
        ],
      ),
    );
  }
}
