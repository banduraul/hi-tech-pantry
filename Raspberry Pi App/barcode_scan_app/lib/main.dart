import 'package:flutter/material.dart';

import 'screens/qrcode_scan_page.dart';

import 'utils/firebase_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseAdmin.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hi-Tech Pantry',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 60.0,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(fontSize: 18.0),
        )
      ),
      home: const QrcodeScanPage()
    );
  }
}
