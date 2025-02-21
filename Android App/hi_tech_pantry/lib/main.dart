import 'package:provider/provider.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'utils/router.dart';
import 'utils/app_state.dart';
import '/utils/theme_provider.dart';
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
      case 'increasedQuantity':
        NotificationServices.showNotification(
          title: message.data['name'],
          content: message.data['message'],
          channelInfo: NotificationServices.increasedQuantityChannel,
        );
        break;
      case 'decreasedQuantity':
        NotificationServices.showNotification(
          title: message.data['name'],
          content: message.data['message'],
          channelInfo: NotificationServices.decreasedQuantityChannel,
        );
        break;
      case 'productDeleted':
        NotificationServices.showNotification(
          title: message.data['name'],
          content: 'This product ran out',
          channelInfo: NotificationServices.productDeletedChannel,
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApplicationState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      builder: (context, child) => const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'Hi-Tech Pantry',
      themeMode: themeProvider.currentThemeMode,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      routerConfig: Router.goRouter,
    );
  }
}