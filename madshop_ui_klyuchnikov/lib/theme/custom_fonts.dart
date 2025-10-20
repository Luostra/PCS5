import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryText,
  );

  static const TextStyle searchTitle = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle cartNumber = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle productTitle = TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle startTitle = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 50,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryText,
    height: 54 / 50,
  );

  static const TextStyle helloTitle = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryText,
    height: 26 / 28,
  );

  static const TextStyle startButton = TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.checkoutButtonText,
  );

  static const TextStyle cancelButton = TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryText,
    height: 26 / 15,
  );

  static const TextStyle loginText = TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryText,
    height: 35 / 19,
  );

  static const TextStyle inputHintText = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 13.83,
    color: AppColors.textHint,
    height: 13.83 * 1.4,
  );

  static const TextStyle productPrice = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryText,
  );

  static const TextStyle productPriceInCart = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryText,
  );

  static const TextStyle productDescription = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle productQuantity = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle totalCheckout = TextStyle(
    fontFamily: 'Raleway',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryText,
  );

  static const TextStyle checkoutButton = TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.checkoutButtonText,
  );
}
