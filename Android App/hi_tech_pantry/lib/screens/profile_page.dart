import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

import '../utils/database.dart';
import '../utils/app_state.dart';

import '../widgets/qr_code_dialog.dart';
import '../widgets/check_password_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/change_username_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String profileName = 'profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late final AppLifecycleListener _appLifecycleListener;
  
  final picker = ImagePicker();

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final message = await Database.uploadProfilePicture(image: File(pickedFile.path));
      if (message.contains('Success')) {
        Fluttertoast.showToast(
          msg: 'Profile picture updated',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      final message = await Database.uploadProfilePicture(image: File(pickedFile.path));
      if (message.contains('Success')) {
        Fluttertoast.showToast(
          msg: 'Profile picture updated',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

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
                  elevation: 10,
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
                              builder: (context) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                height: 150,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await getImageFromGallery();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color.fromARGB(255, 68, 68, 68),
                                      ),
                                      child: const Text('Choose picture from gallery', style: TextStyle(fontSize: 20)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await getImageFromCamera();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color.fromARGB(255, 68, 68, 68),
                                      ),
                                      child: const Text('Take a picture', style: TextStyle(fontSize: 20)),
                                    ),
                                  ],
                                )
                              )
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
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_rounded),
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
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${appState.userEmail}', style: TextStyle(fontSize: 17, color: Colors.grey.shade800)),
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
            const Spacer(),
            ElevatedButton(
              onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 68, 68, 68),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.notifications_rounded),
                    SizedBox(width: 40),
                    Text('Notifications', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: 'Email needs to be verified first',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: ElevatedButton(
                  onPressed: appState.isUserEmailVerified ? () {
                    debugPrint('Two-Factor Authentication');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color.fromARGB(255, 68, 68, 68),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Icon(Icons.lock_person_rounded),
                        SizedBox(width: 40),
                        Text('Two-Factor Authentication', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Icon(Icons.arrow_right_rounded, size: 40)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => QRCodeDialog(email: appState.userEmail)
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 68, 68, 68),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_rounded),
                      SizedBox(width: 40),
                      Text('Link to Raspberry Pi App', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CheckPasswordDialog()
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 68, 68, 68),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.key_rounded),
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade700,
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded),
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
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_rounded),
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