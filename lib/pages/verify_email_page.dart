import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/services/auth_service.dart';
import 'package:gym_bro_alpha/utils/page_routes.dart';
import 'package:gym_bro_alpha/utils/utils.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage>
    with SingleTickerProviderStateMixin {
  User? currentUser;
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? timer;
  Timer? resendTimer;
  int resendDelay = 60;
  Future? resendWait;

  AnimationController? _controller;
  Animation<Offset>? _heightAnimation;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;

    _isEmailVerified =
        currentUser!.isAnonymous ? true : currentUser!.emailVerified;

    if (!_isEmailVerified) {
      _sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => checkEmailVerified(),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _heightAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.8)).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    resendWait?.ignore();
    timer?.cancel();
    resendTimer?.cancel();
    _controller!.dispose();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    try {
      await currentUser!.reload();

      setState(() {
        _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

      if (_isEmailVerified) {
        timer?.cancel();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, PageRoutes.home);
        }
      }
    } catch (_) {
      AuthService.signOut().then((_) {
        Navigator.pushReplacementNamed(context, PageRoutes.root);
      });

      if (context.mounted) {
        Utils.showTextSnackbar(context, 'Connection failed');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _canResendEmail = false);
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    await currentUser!.sendEmailVerification().catchError(
      (e) {
        Utils.showTextSnackbar(context, 'Too many attempts');
      },
    );

    resendWait = Future.delayed(
      Duration(seconds: resendDelay),
      () {
        resendTimer?.cancel();
        setState(() => _canResendEmail = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AuthService.signOut().then((_) {
              Navigator.pushReplacementNamed(context, PageRoutes.root);
            });
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: LayoutBuilder(builder: (context, constraint) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 5),
                SlideTransition(
                  position: _heightAnimation!,
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: constraint.biggest.width < constraint.biggest.height
                        ? constraint.biggest.width * 0.3
                        : constraint.biggest.height * 0.3,
                  ),
                ),
                Text(
                  'A verification link has been sent to ${FirebaseAuth.instance.currentUser!.email}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _canResendEmail ? _sendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    resendTimer == null || !resendTimer!.isActive
                        ? 'Resend Email'
                        : '${resendDelay - resendTimer!.tick}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => AuthService.signOut().then((_) {
                    Navigator.pushReplacementNamed(context, PageRoutes.root);
                  }),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Spacer(flex: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}
