import 'package:flutter/material.dart';
import 'package:gym_bro_alpha/utils/dumbbell_icon.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Dumbbell.dumbell,
                size: 60,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                'GymBro',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              ),
            ],
          ),
          Form(
            child: Column(
              children: [
                TextFormField(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
