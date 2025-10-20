import 'package:flutter/material.dart';
import 'hello_screen.dart';
import '../theme/colors.dart';
import '../theme/custom_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login_bubbles.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: double.infinity),

          Positioned(
            left: 20,
            right: 20,
            bottom: 84,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Login', style: AppTextStyles.startTitle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Good to see you back!',
                      style: AppTextStyles.loginText,
                    ),
                    const SizedBox(width: 10.2),
                    const Icon(
                      Icons.favorite,
                      color: AppColors.secondaryText,
                      size: 15.32,
                    ),
                  ],
                ),
                const SizedBox(height: 17.08),
                TextField(decoration: inputDecoration('Email')),
                const SizedBox(height: 36.7),
                SizedBox(
                  width: double.infinity,
                  height: 61,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordScreen(),
                        ),
                      );
                    },
                    child: Text('LogIn', style: AppTextStyles.startButton),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text('Cancel', style: AppTextStyles.cancelButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
