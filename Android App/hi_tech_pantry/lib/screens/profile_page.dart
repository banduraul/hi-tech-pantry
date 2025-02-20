import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_settings/app_settings.dart';

import 'login_page.dart';

import '../utils/database.dart';
import '../utils/app_state.dart';
import '../utils/theme_provider.dart';

import '../widgets/qr_code_dialog.dart';
import '../widgets/bottom_modal_sheet.dart';
import '../widgets/change_theme_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/change_username_dialog.dart';
import '../widgets/reauthenticate_user_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String profileName = 'profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    super.initState();
    ApplicationState.refreshUser();
    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        ApplicationState.refreshUser();
      },
    );
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userEmail = Provider.of<ApplicationState>(context, listen: false).userEmail;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 90,
              child: Consumer<ApplicationState>(
                builder: (context, appState, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => BottomModalSheet()
                            );
                          },
                          child: appState.userPhotoUrl.isEmpty
                            ? Image(
                                image: AssetImage('assets/no-profile.png'),
                                width: 60,
                                height: 60
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(appState.userPhotoUrl),
                            ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appState.userDisplayName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_rounded, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const ChangeUsernameDialog()
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ),
            SizedBox(
              width: double.infinity,
              height: 90,
              child: Consumer<ApplicationState>(
                builder: (context, appState, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${appState.userEmail}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                            Row(
                              children: [
                                Icon(appState.isUserEmailVerified ? Icons.check_circle_rounded : Icons.error_rounded, color: appState.isUserEmailVerified ? Colors.green.shade600 : Colors.red.shade600),
                                SizedBox(width: 10),
                                Text(appState.isUserEmailVerified ? 'Email verified' : 'Email not verified', style: TextStyle(fontSize: 15, color: appState.isUserEmailVerified ? Colors.green.shade600 : Colors.red.shade600)),
                              ],
                            )
                          ],
                        ),
                        if (!appState.isUserEmailVerified)
                          SizedBox(
                            width: 100,
                            height: 50,
                            child: TextButton(
                              child: Text('Verify', style: TextStyle(fontSize: 20, color: Colors.green.shade600)),
                              onPressed: () async {
                                await appState.sendEmailVerification();
                                Fluttertoast.showToast(
                                  msg: 'Verification email sent',
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 90,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangeThemeDialog()
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                    child: Row(
                      children: [
                        Icon(Icons.brightness_6_outlined, size: 30, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800),
                        SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                themeProvider.currentThemeMode == ThemeMode.system ? 'System Default'
                                  : isDarkMode ? 'Dark' : 'Light',
                                style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => Visibility(
                visible: appState.isConnectedToPantry,
                child: SizedBox(
                  width: double.infinity,
                  height: 110,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pantry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Status:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                                        Text('Mode:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800))
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Connected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green.shade600)),
                                        Text(appState.pantryMode, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.yellow : Colors.orange)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: SizedBox(
                              width: 130,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final message = await Database.disconnectFromPantry();
                                  if (message.contains('Success')) {
                                    Fluttertoast.showToast(
                                      msg: 'You have disconnected from the pantry',
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: message,
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade900,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Disconnect', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => Visibility(
                visible: !appState.isConnectedToPantry,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => QRCodeDialog(email: userEmail)
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Icon(Icons.qr_code_rounded, size: 25, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800),
                          SizedBox(width: 40),
                          Text('Connect to your Pantry', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.notifications_rounded, size: 25, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800),
                    SizedBox(width: 40),
                    Text('Notifications', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ReauthenticateUserDialog()
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.key_rounded, size: 25, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800),
                    SizedBox(width: 40),
                    Text('Change password', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final message = await Database.signOut();
                if (message.contains('Success')) {
                    Fluttertoast.showToast(
                      msg: 'Logged out successfully',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                    if (context.mounted) {
                      context.goNamed(LoginPage.loginName);
                    }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                foregroundColor: Colors.red.shade800,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 25, color: Colors.red.shade800),
                    SizedBox(width: 40),
                    Text('Log out', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const DeleteAccountDialog()
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_rounded, size: 25, color: Colors.white),
                    SizedBox(width: 40),
                    Text('Delete account', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}