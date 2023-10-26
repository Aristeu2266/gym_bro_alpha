import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/models/auth.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';

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
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  String? postValidate;

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
    setState(() => postValidate = null);

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    try {
      if (widget.sign == 'signin') {
        await Auth.signIn(_authData['email']!, _authData['password']!);
      } else {
        await Auth.signUp(_authData['email']!, _authData['password']!)
            .then((_) {
          Auth.signIn(_authData['email']!, _authData['password']!);
        }).then((value) =>
                Navigator.pushReplacementNamed(context, PageRoutes.root));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        setState(() => postValidate = 'Email or password provided is wrong');
      } else if (e.code == 'too-many-requests') {
        setState(() => postValidate = 'Too many failed login attempts!');
      } else if (e.code == 'email-already-in-use') {
        setState(() => postValidate = 'Email alredy in use');
      } else {
        print(e.code);
        setState(() => postValidate = 'An error ocurred!');
      }
    }

    setState(() => _isLoading = false);
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
              child: MyTextField(
                hintText: 'Email',
                validator: (email) =>
                    (email ?? '').isEmpty ? 'Invalid email' : null,
                onSaved: (email) => _authData['email'] = email ?? '',
                errorText: postValidate,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Hero(
            tag: 'password',
            child: Material(
              child: MyTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                validator: (password) =>
                    (password ?? '').isEmpty ? 'Invalid password' : null,
                onSaved: (password) => _authData['password'] = password ?? '',
              ),
            ),
          ),
          if (!_isSignin()) const SizedBox(height: 18),
          if (!_isSignin())
            ScaleTransition(
              scale: _sizeAnimation!,
              child: MyTextField(
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isSignin())
                  GestureDetector(
                    onTap: () {},
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

class MyTextField extends StatelessWidget {
  const MyTextField({
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.errorText,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.background),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.onBackground),
            gapPadding: 0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
        ),
        fillColor: colorScheme.primaryContainer,
        filled: true,
        errorText: errorText,
      ),
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      onSaved: onSaved,
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.onBackground,
        foregroundColor: colorScheme.background,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
