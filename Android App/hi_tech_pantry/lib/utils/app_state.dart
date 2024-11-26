import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data_classes/product_info.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initComplete => _initCompleter.future;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  StreamSubscription<QuerySnapshot>? _productInfoSubscription;
  List<ProductInfo> _productInfo = [];
  List<ProductInfo> get productInfo => _productInfo;

  bool _hasExpiredProducts = false;
  bool get hasExpiredProducts => _hasExpiredProducts;

  String _userEmail = '';
  String get userEmail => _userEmail;

  bool _isUserEmailVerified = false;
  bool get isUserEmailVerified => _isUserEmailVerified;

  String _userDisplayName = '';
  String get userDisplayName => _userDisplayName;

  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  static Future<void> refreshUser() async {
    await FirebaseAuth.instance.currentUser!.reload();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );

    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _userEmail = user.email ?? '';
        _isUserEmailVerified = user.emailVerified;
        _userDisplayName = user.displayName ?? '';
      } else {
        _userEmail = '';
        _isUserEmailVerified = false;
        _userDisplayName = '';
      }

      notifyListeners();
    });

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        _isLoggedIn = true;
        _productInfoSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .snapshots()
          .listen((snapshot) {
            _productInfo = [];
            for (final document in snapshot.docs) {
              _productInfo.add(
                ProductInfo(
                  eancode: document.data()['eancode'] as String,
                  name: document.data()['name'] as String,
                  finishedEditing: document.data()['finishedEditing'] as bool,
                  quantity: document.data()['quantity'] as int,
                  expiryDate: document.data()['expiryDate']?.toDate() as DateTime?,
                  docId: document.id,
                  isExpired: document.data()['isExpired'] as bool
                ),
              );
            }
            
            _hasExpiredProducts = _productInfo.any((product) => product.isExpired);

            _productInfo.sort((a, b) {
              if (a.expiryDate == null && b.expiryDate == null) {
                return 0;
              } else if (a.expiryDate == null) {
                return -1;
              } else if (b.expiryDate == null) {
                return 1;
              } else {
                return a.expiryDate!.isBefore(b.expiryDate!) ? -1 : 1;
              }
            });

            notifyListeners();
          });
      } else {
        _isLoggedIn = false;
        _productInfo = [];
        _productInfoSubscription?.cancel();
      }

      await Future.delayed(const Duration(seconds: 3));

      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }

      notifyListeners();
    });
  }
}