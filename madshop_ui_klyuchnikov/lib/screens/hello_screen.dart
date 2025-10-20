import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'shop_screen.dart';
import '../theme/colors.dart';
import '../theme/custom_fonts.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/password_bubbles.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: double.infinity),
          Positioned(
            left: 20,
            right: 20,
            top: 238,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Hello!', style: AppTextStyles.helloTitle),
                const SizedBox(height: 30),
                Text('Type your password', style: AppTextStyles.loginText),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 84,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 82.63),
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
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    child: Text('Start', style: AppTextStyles.startButton),
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

InputDecoration inputDecoration(String hint, {Widget? prefix, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: 13.83,
      color: AppColors.textHint,
    ),
    filled: true,
    fillColor: AppColors.backgroundInput,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 19.76,
      vertical: 15.81,
    ),
    prefixIcon: prefix,
    suffixIcon: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(52.37),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(52.37),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(52.37),
      borderSide: BorderSide.none,
    ),
  );
}
