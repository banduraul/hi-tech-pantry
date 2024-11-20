import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';
import 'login_page.dart';

import '../utils/app_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const String splashName = 'splash';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context, listen: false);

    return FutureBuilder<void>(
      future: appState.initComplete,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.isLoggedIn) {
              context.goNamed(HomePage.homeName);
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