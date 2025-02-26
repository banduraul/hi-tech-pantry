import 'package:flutter/material.dart';

class ConfirmProductDeletionDialog extends StatelessWidget {
  const ConfirmProductDeletionDialog({super.key, required this.productName});
  
  final String productName;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      icon: Icon(Icons.warning_rounded, color: Colors.red.shade800),
      title: Text('Are you sure you want to delete $productName?', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No', style: TextStyle(fontSize: 18, color: Colors.red.shade800, fontWeight: FontWeight.w500)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Yes', style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}