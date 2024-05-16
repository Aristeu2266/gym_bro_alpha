import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/components/my_button.dart';
import 'package:gym_bro_alpha/components/my_form_field.dart';
import 'package:gym_bro_alpha/utils/utils.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? firebaseException;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() => firebaseException = null);
    bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: _emailController.text.trim(),
      )
          .then(
        (_) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Utils.showSnackbar(
            context,
            'Password reset email sent.',
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code != 'network-request-failed') {
        setState(() {
          firebaseException = 'Invalid email';
        });
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          'Connection failed',
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = _emailController.text.isEmpty
        ? ModalRoute.of(context)?.settings.arguments as String
        : _emailController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.0),
                child: Text(
                  'Receive an email to reset your password.',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: MyFormField(
                  controller: _emailController,
                  hintText: 'Email',
                  validator: (email) =>
                      (email ?? '').isEmpty ? 'Insert an email' : null,
                  errorText: firebaseException,
                ),
              ),
              const SizedBox(height: 12),
              MyButton(
                text: !_isLoading ? 'Resend Email' : null,
                leadingWidget: !_isLoading
                    ? const Icon(Icons.email_outlined)
                    : const CircularProgressIndicator(),
                onTap: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
