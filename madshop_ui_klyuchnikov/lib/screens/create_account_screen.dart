import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'login_screen.dart';
import '../theme/colors.dart';
import 'hello_screen.dart';
import '../theme/custom_fonts.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/create_account_bubbles.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 30,
            top: 78,
            child: Text('Create\nAccount', style: AppTextStyles.startTitle),
          ),
          Positioned(
            left: 30,
            top: 78,
            child: Text('Create\nAccount', style: AppTextStyles.startTitle),
          ),
          SizedBox(height: double.infinity),

          Positioned(
            left: 20,
            right: 20,
            bottom: 95,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: inputDecoration('Email')),
                const SizedBox(height: 7.91),
                TextField(
                  decoration: inputDecoration(
                    'Password',
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 19.76),
                      child: SvgPicture.asset(
                        'assets/icons/eye-slash.svg',
                        width: 15,
                        height: 15,
                        colorFilter: ColorFilter.mode(
                          AppColors.dividerPhone,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7.91),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: inputDecoration(
                    'Your number',
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 19.76),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/flag_ru.png',
                            width: 24,
                            height: 16,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.dividerPhone,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15.81,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 52.1),
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
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text('Done', style: AppTextStyles.startButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
