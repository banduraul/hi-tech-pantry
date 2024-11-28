import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/database.dart';

class BottomModalSheet extends StatelessWidget {
  BottomModalSheet({super.key});

  final picker = ImagePicker();

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      Fluttertoast.showToast(
        msg: 'Updating profile picture...',
        toastLength: Toast.LENGTH_SHORT,
      );
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
      Fluttertoast.showToast(
        msg: 'Updating profile picture...',
        toastLength: Toast.LENGTH_SHORT,
      );
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
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
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
              context.pop();
              await getImageFromGallery();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            ),
            child: const Text('Choose picture from gallery', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await getImageFromCamera();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            ),
            child: const Text('Take a picture', style: TextStyle(fontSize: 20)),
          ),
        ],
      )
    );
  }
}