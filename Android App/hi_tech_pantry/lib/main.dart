import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'screens/login_page.dart';
import 'screens/splash_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_page.dart';
import 'screens/products_page.dart';
import 'screens/forgot_password_page.dart';

import 'utils/app_state.dart';
import 'utils/notification_services.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    switch (message.data['type']) {
      case 'newProduct':
        NotificationServices.showNotification(
          title: message.data['name'],
          content: 'Click to add an expiration date and change product information if needed',
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
    }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationServices.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final ImagePickerPlatform imagePickerPlatform = ImagePickerPlatform.instance;
  if (imagePickerPlatform is ImagePickerAndroid) {
    imagePickerPlatform.useAndroidPhotoPicker = true;
  }

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const MainApp()),
  ));
}

final goRouter = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: SplashPage.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/products',
        name: ProductsPage.productsName,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ProductsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        routes: [
          GoRoute(
            path: 'profile',
            name: ProfilePage.profileName,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ProfilePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ), 
        ]
      ),
      GoRoute(
        path: '/login',
        name: LoginPage.loginName,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const LoginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
        ),
        routes: [
          GoRoute(
            path: 'forgot-password',
            name: ForgotPasswordPage.forgotPasswordName,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ForgotPasswordPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
          GoRoute(
            path: 'register',
            name: RegisterPage.registerName,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const RegisterPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
        ]
      )
    ],
  );

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hi-Tech Pantry',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade100,
        cardTheme: CardTheme(
          color: Colors.grey.shade200,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 10,
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 46.0,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: const TextStyle(fontSize: 18.0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade50,
          shadowColor: Colors.blue.shade900,
          elevation: 3,
          centerTitle: true,
          titleSpacing: 0.0,
          toolbarHeight: 50,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25)
            ),
          ),
          foregroundColor: Colors.blue.shade700,
          titleTextStyle: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700,
          ),
        ),
      ),
      routerConfig: goRouter,
    );
  }
}
