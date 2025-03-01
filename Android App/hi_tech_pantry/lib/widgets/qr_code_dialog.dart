import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/app_state.dart';


class QRCodeDialog extends StatelessWidget {
  const QRCodeDialog({super.key, required this.email});
  
  final String email;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<ApplicationState>(
      builder: (context, appState, _) {
        if (appState.isConnectedToPantry) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Fluttertoast.showToast(
              msg: 'Connected successfully',
              toastLength: Toast.LENGTH_SHORT,
            );
            
            Future.delayed(Duration(milliseconds: 300), () {
              if (context.mounted) {
                context.pop();
              }
            });
          });
        }

        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
          title: Text('Scan to connect to pantry', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
          content: SizedBox(
            width: 200,
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QrImageView(
                  backgroundColor: Colors.white,
                  data: email.replaceFirst('@', '"'),
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Cancel', style: TextStyle(fontSize: 24, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}