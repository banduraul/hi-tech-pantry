import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'login_page.dart';
import 'products_page.dart';

import '../utils/app_state.dart';
import '../utils/notification_services.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String splashName = 'splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _checkForPermission();
  }

  Future<void> _checkForPermission() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final hasAskedForPermission = sharedPrefs.getBool('hasAskedForPermission') ?? false;

    if (!hasAskedForPermission) {
      NotificationServices.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
      sharedPrefs.setBool('hasAskedForPermission', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context, listen: false);

    return FutureBuilder<void>(
      future: appState.initComplete,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.isLoggedIn) {
              context.goNamed(ProductsPage.productsName);
            } else {
              context.goNamed(LoginPage.loginName);
            }
          });
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Hi-Tech Pantry',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                CircularProgressIndicator(color: Colors.blue.shade700),
              ],
            ),
          ),
        ); 
      }
    );
  }
}