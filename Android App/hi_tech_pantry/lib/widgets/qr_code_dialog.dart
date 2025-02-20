import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeDialog extends StatelessWidget {
  const QRCodeDialog({super.key, required this.email});
  
  final String email;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      title: const Text('Scan to connect to pantry', style: TextStyle(color: Colors.blue)),
      content: SizedBox(
        width: 200,
        height: 200,
        child: Align(
          alignment: Alignment.center,
          child: QrImageView(
            backgroundColor: Colors.white,
            data: email.replaceFirst('@', '"'),
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    );
  }
}