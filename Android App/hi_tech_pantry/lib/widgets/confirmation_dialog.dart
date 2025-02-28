import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key, required this.text});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      icon: Icon(Icons.warning_rounded, color: Colors.red.shade800),
      title: Text(text, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text('No', style: TextStyle(fontSize: 18, color: Colors.red.shade800, fontWeight: FontWeight.w500)),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: Text('Yes', style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}