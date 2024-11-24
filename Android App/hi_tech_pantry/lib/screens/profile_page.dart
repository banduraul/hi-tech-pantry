import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';

import '../utils/database.dart';

import '../widgets/check_password_dialog.dart';
import '../widgets/delete_account_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String profileName = 'profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 100, bottom: 10),
          child: Column(
            children: [
              QrImageView(
                data: user!.email!.replaceFirst('@', '"'),
                version: QrVersions.auto,
                size: 200.0,
              ),
              Text(
                'Email: ${user!.email}',
                style: const TextStyle(fontSize: 25),
              ),
              const Spacer(),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Color.fromARGB(255, 68, 68, 68),
                      width: 3,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Icon(Icons.key_rounded),
                      SizedBox(width: 60),
                      Text('Change password'),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.red.shade700,
                      width: 3,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded),
                      SizedBox(width: 60),
                      Text('Log out'),
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
                      SizedBox(width: 60),
                      Text('Delete account'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}