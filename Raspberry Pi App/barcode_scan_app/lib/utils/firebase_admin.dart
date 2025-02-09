import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

import '../data_classes/product_info.dart';

class FirebaseAdmin {

  static late FirebaseAdminApp admin;
  static late String uid;
  static late String tokenAPI;

  static Future<void> init() async {
    final credentialsFile = await rootBundle.loadString('lib/assets/credentials.json');
    final credentials = jsonDecode(credentialsFile) as Map<String, dynamic>;
    admin = FirebaseAdminApp.initializeApp(
      credentials['projectId'],
      Credential.fromServiceAccount(File(credentials['pathToServiceAccount']))
    );
    tokenAPI = credentials['tokenAPI'];
  }

  static Future<String> getUid({required String email}) async {
    String message = '';

    try {
      final auth = Auth(admin);
      final user = await auth.getUserByEmail(email);
      uid = user.uid;
      message = 'Success';
    } on Exception {
        message = 'The QR Code you have scanned is not from the Mobile App or the account has been deleted';
    }

    return message;
  }

  static Future<(String, String)> addProduct({required String eancode}) async {
    String message = '';
    String title = '';

    try {
      final firestore = Firestore(admin);
      final snapshot = await firestore.collection('users').doc(uid).collection('products').where('eancode', WhereFilter.equal, eancode).get();
      if (snapshot.docs.isNotEmpty) {
        final document = snapshot.docs[0];
        await document.ref.update({ 'quantity': const FieldValue.increment(1) });
        String name = document.data()['name'].toString();
        if (name != '') {
          title = name;
        } else {
          title = 'Unknown Product';
        }
        message = 'Success';
      } else {
        final response = await get(Uri.parse('https://api.ean-search.org/api?op=barcode-lookup&format=json&token=$tokenAPI&ean=$eancode'));
        List<dynamic> products = jsonDecode(response.body);
        if (products.isNotEmpty && products[0]['error'] == null) {
          await firestore.collection('users').doc(uid).collection('products').add(ProductInfo(eancode: products[0]['ean'], name: products[0]['name']).toFirestore());
          title = products[0]['name'];
          message = 'Success';
        } else {
          await firestore.collection('users').doc(uid).collection('products').add(ProductInfo(eancode: eancode, name: '').toFirestore());
          message = 'The product information has not been found using the API. The product has been added to the pantry as a Unknown product. Please add a name to the product using the Mobile Application.';
        }
      }
    } on Exception catch(_) {

    }

    return (message, title);
  }

  static Future<(String, String)> removeProduct({required String eancode}) async {
    String message = '';
    String title = '';

    try {
      final firestore = Firestore(admin);
      final snapshot = await firestore.collection('users').doc(uid).collection('products').where('eancode', WhereFilter.equal, eancode).get();
      if (snapshot.docs.isNotEmpty) {
        final document = snapshot.docs[0];
        title = document.data()['name'].toString();
        if (document.data()['quantity'] == 1) {
          await document.ref.delete();
        } else {
          await document.ref.update({ 'quantity': const FieldValue.increment(-1) });
        }
        message = 'Success';
      } else {
        message = 'The scanned product wasn\'t deposited first';
      }
    } on Exception catch(_) {

    }

    return (message, title);
  }
}