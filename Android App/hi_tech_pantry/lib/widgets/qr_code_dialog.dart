import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeDialog extends StatelessWidget {
  const QRCodeDialog({super.key, required this.email});
  
  final String email;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan to link your account', style: TextStyle(color: Colors.blue)),
      content: SizedBox(
        width: 200,
        height: 200,
        child: Align(
          alignment: Alignment.center,
          child: QrImageView(
            data: email.replaceFirst('@', '"'),
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    );
  }
}