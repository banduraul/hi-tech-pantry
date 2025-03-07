import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'login_page.dart';

import '../utils/database.dart';
import '../utils/app_state.dart';
import '../utils/theme_provider.dart';
import '../utils/notification_services.dart';

import '../widgets/qr_code_dialog.dart';
import '../widgets/change_profile_picture_modal_sheet.dart';
import '../widgets/change_theme_dialog.dart';
import '../widgets/confirmation_dialog.dart';
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
  late final StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    ApplicationState.refreshUser();
    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        ApplicationState.refreshUser();
      },
    );
    _messageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('message: $message');
      switch (message.data['type']) {
        case 'newProduct':
          NotificationServices.showNotification(
            title: message.data['name'],
            content: 'New product added',
            channelInfo: NotificationServices.newProductsChannel,
          );
          break;
        case 'expiredProduct':
          NotificationServices.showNotification(
            title: message.data['name'],
            content: 'Expired on ${message.data['expiryDate']}',
            channelInfo: NotificationServices.expiredProductsChannel,
          );
          break;
        case 'expireSoon':
          String days = '';
          switch(message.data['days']) {
              case '0':
                days = 'Expires today';
                break;
              case '1':
                days = 'Expires tomorrow';
                break;
              default:
                days = 'Expires in ${message.data['days']} days';
                break;
          }
          NotificationServices.showNotification(
            title: message.data['name'],
            content: days,
            channelInfo: NotificationServices.expireSoonChannel,
          );
          break;
        case 'runningLow':
          NotificationServices.showNotification(
            title: message.data['name'],
            content: 'You only have ${message.data['quantity']} left',
            channelInfo: NotificationServices.runningLowChannel,
          );
          break;
        case 'increasedQuantity':
          NotificationServices.showNotification(
            title: message.data['name'],
            content: message.data['message'],
            channelInfo: NotificationServices.increasedQuantityChannel,
          );
          break;
      }
    });
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    _messageSubscription?.cancel();
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
                              builder: (context) => ChangeProfilePictureModalSheet()
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
                                    barrierDismissible: false,
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
                                Text(appState.isUserEmailVerified ? 'Email verified' : 'Email not verified', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: appState.isUserEmailVerified ? Colors.green.shade600 : Colors.red.shade600)),
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
                    barrierDismissible: false,
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
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
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
                              Text('Pantry', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Status:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.blue.shade700 : Colors.grey.shade800)),
                                    const SizedBox(width: 10),
                                    Text('Connected', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green.shade600)),
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
                                  final confirmation = await showDialog(
                                    context: context,
                                    builder: (context) => const ConfirmationDialog(text: 'Are you sure you want to disconnect from your pantry?')
                                  );

                                  if (confirmation) {
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
                        barrierDismissible: false,
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
                  barrierDismissible: false,
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
                  barrierDismissible: false,
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