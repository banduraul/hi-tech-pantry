import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../data_classes/product_info.dart';

class Database {
  
  static Future<String?> registerUsingEmailPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    String? message;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fcmToken = await FirebaseMessaging.instance.getToken();

      await FirebaseFirestore.instance
        .collection('fcmTokens')
        .doc(userCredential.user!.uid)
        .set({
          'pushTokens': [fcmToken],
        });

      await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'username': username,
        });

      await userCredential.user!.updateDisplayName(username);

      await userCredential.user!.sendEmailVerification();

      message = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        message = 'An account with this email address already exists';
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<bool> isUsernameAvailable({required String username}) async {
    final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();

    return snapshot.docs.isEmpty;
  }

  static Future<String?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? message;

    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fcmToken = await FirebaseMessaging.instance.getToken();

      await FirebaseFirestore.instance
        .collection('fcmTokens')
        .doc(auth.currentUser!.uid)
        .update({
          'pushTokens': FieldValue.arrayUnion([fcmToken]),
        });

      message = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        message = 'Invalid credentials provided';
      } else if (e.code == 'user-not-found') {
        message = 'There is no account with this email address';
      } else if (e.code == 'wrong-password') {
        message = 'The password provided is incorrect';
      }
    }

    return message;
  }

  static Future<String> sendPasswordResetLink({required String email}) async {
    String message = '';

    try {
      final auth = FirebaseAuth.instance;

      await auth.sendPasswordResetEmail(email: email);

      message = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        message = 'There is no account with this email address';
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> reauthenticateUser({required String password}) async {
    String message;

    try {
      final auth = FirebaseAuth.instance;
      AuthCredential credential = EmailAuthProvider.credential(email: auth.currentUser!.email!, password: password);
      await auth.currentUser!.reauthenticateWithCredential(credential);
      message = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        message = 'The password provided is incorrect';
      } else {
        message = e.toString();
      }
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> updatePassword({required String newPassword}) async {
    String message;

    try {
      final auth = FirebaseAuth.instance;
      await auth.currentUser!.updatePassword(newPassword);
      message = 'Success';
    } on FirebaseAuthException catch (e) {
      message = e.toString();
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> signOut() async {
    String message;
    try {
      final auth = FirebaseAuth.instance;

      final fcmToken = await FirebaseMessaging.instance.getToken();

      await FirebaseFirestore.instance
        .collection('fcmTokens')
        .doc(auth.currentUser!.uid)
        .update({
          'pushTokens': FieldValue.arrayRemove([fcmToken]),
        });
      
      await auth.signOut();

      message = 'Success';
    } catch (e) {
      message = e.toString();
    }

    return message;
  }

  static Future<String> deleteAccount() async {
    String message;
    try {
      final auth = FirebaseAuth.instance;
      
      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('products')
        .get()
        .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
          'connectedToPantry': false,
        });

      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid).delete();

      await FirebaseFirestore.instance
        .collection('fcmTokens')
        .doc(auth.currentUser!.uid).delete();

      final storageRef = FirebaseStorage.instance.ref(auth.currentUser!.uid);

      await storageRef.child('picture.jpg').delete();

      await auth.currentUser!.delete();
      message = 'Success';
    } catch (e) {
      message = e.toString();
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> updateProductInfo({required ProductInfo productInfo}) async {
    String message;

    try {
      final auth = FirebaseAuth.instance;
      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('products')
        .doc(productInfo.docId)
        .update(productInfo.toFirestore());
      message = 'Success';
    } catch (e) {
      message = e.toString();
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> deleteProduct({required String docId}) async {
    String message;

    try {
      final auth = FirebaseAuth.instance;
      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('products')
        .doc(docId)
        .delete();
      message = 'Success';
    } catch (e) {
      message = e.toString();
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> updateUsername({required String username}) async {
    String message;

    try {
      final isAvailable = await isUsernameAvailable(username: username);
      if (!isAvailable) {
        message = 'This username is already taken';
        return message;
      }
      
      final auth = FirebaseAuth.instance;
      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
          'username': username,
        });

      await auth.currentUser!.updateDisplayName(username);

      message = 'Success';
    } catch (e) {
      message = e.toString();
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> uploadProfilePicture({required File image}) async {
    String message;

    try {
      final auth = FirebaseAuth.instance;
      final storageRef = FirebaseStorage.instance.ref(auth.currentUser!.uid);
      await storageRef.child('picture.jpg').putFile(image);
      final downloadURL = await storageRef.child('picture.jpg').getDownloadURL();
      await auth.currentUser!.updatePhotoURL(downloadURL);
      message = 'Success';
    } catch (e) {
      message = e.toString();
      debugPrint(e.toString());
    }

    return message;
  }

  static Future<String> disconnectFromPantry() async {
    String message;

    try {
      final auth = FirebaseAuth.instance;
      await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
          'connectedToPantry': false,
        });
      message = 'Success';
    } catch (e) {
      message = 'Disconnection attempt failed. Please try again';
      debugPrint(e.toString());
    }

    return message;
  }
}