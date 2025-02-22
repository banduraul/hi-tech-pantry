import 'package:flutter/material.dart';

class PasswordValidationIndicator extends StatelessWidget {
  const PasswordValidationIndicator({super.key, required this.isValid, required this.text});

  final bool isValid;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
            color: isValid ? Colors.green.shade600 : Colors.red.shade800, size: 18),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isValid ? Colors.green.shade600 : Colors.red.shade800)),
      ],
    );
  }
}