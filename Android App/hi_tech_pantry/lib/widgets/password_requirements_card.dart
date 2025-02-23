import 'package:flutter/material.dart';

import 'password_validation_indicator.dart';

class PasswordRequirementsCard extends StatelessWidget {
  const PasswordRequirementsCard({
    super.key,
    required this.hasDigit,
    required this.isDarkMode,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasSpecialCharacter
  });

  final bool hasDigit;
  final bool isDarkMode;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasSpecialCharacter;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Requirements',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.yellow : Colors.orange),
            ),
            const SizedBox(height: 10.0),
            PasswordValidationIndicator(
              text: 'Minimum 8 characters',
              isValid: hasMinLength,
            ),
            PasswordValidationIndicator(
              text: 'At least 1 uppercase letter',
              isValid: hasUppercase,
            ),
            PasswordValidationIndicator(
              text: 'At least 1 lowercase letter',
              isValid: hasLowercase,
            ),
            PasswordValidationIndicator(
              text: 'At least 1 digit',
              isValid: hasDigit,
            ),
            PasswordValidationIndicator(
              text: 'At least 1 of the symbols: [!@#\$%^&*(),.?":{}|<>]',
              isValid: hasSpecialCharacter,
            ),
          ],
        ),
      ),
    );
  }
}