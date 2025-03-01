import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data_classes/notification_channel_info.dart';

class NotificationServices {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const NotificationChannelInfo newProductsChannel = NotificationChannelInfo(
    id: 'newProductsChannelID',
    name: 'New Products',
    description: 'Channel for new products',
    groupKey: 'newProductsNotificationGroup',
    summaryText: 'New Products',
    subText: 'New Product',
    groupID: 0
  );

  static const NotificationChannelInfo expiredProductsChannel = NotificationChannelInfo(
    id: 'expiredProductsChannelID',
    name: 'Expired Products',
    description: 'Channel for expired products',
    groupKey: 'expiredProductsNotificationGroup',
    summaryText: 'Expired Products',
    subText: 'Expired Product',
    groupID: 1
  );

  static const NotificationChannelInfo expireSoonChannel = NotificationChannelInfo(
    id: 'expireSoonChannelID',
    name: 'Products expiring soon',
    description: 'Channel for products that expire in the next 3 days',
    groupKey: 'expireSoonNotificationGroup',
    summaryText: 'Products expiring soon',
    subText: 'Product expires soon',
    groupID: 2
  );

  static const NotificationChannelInfo runningLowChannel = NotificationChannelInfo(
    id: 'runningLowChannelID',
    name: 'Products running low',
    description: 'Channel for products running low',
    groupKey: 'runningLowNotificationGroup',
    summaryText: 'Products running low',
    subText: 'Product running low',
    groupID: 3
  );

  static const NotificationChannelInfo increasedQuantityChannel = NotificationChannelInfo(
    id: 'increasedQuantityChannelID',
    name: 'Product quantity increased',
    description: 'Channel for product quantity increase',
    groupKey: 'increasedQuantityNotificationGroup',
    summaryText: 'Quantities increased',
    subText: 'Quantity increased',
    groupID: 4
  );

  static const NotificationChannelInfo decreasedQuantityChannel = NotificationChannelInfo(
    id: 'decreasedQuantityChannelID',
    name: 'Product quantity decreased',
    description: 'Channel for product quantity decrease',
    groupKey: 'decreasedQuantityNotificationGroup',
    summaryText: 'Quantities decreased',
    subText: 'Quantity decreased',
    groupID: 5
  );

  static const NotificationChannelInfo productDeletedChannel = NotificationChannelInfo(
    id: 'productDeletedChannelID',
    name: 'Products that ran out',
    description: 'Channel for products that ran out',
    groupKey: 'productDeletedNotificationGroup',
    summaryText: 'Products that ran out',
    subText: 'Product ran out',
    groupID: 6
  );

  static int id = 7;

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static NotificationDetails getGroupNotifier(NotificationChannelInfo channelInfo) {
    InboxStyleInformation inboxStyleInformation = InboxStyleInformation([], summaryText: channelInfo.summaryText);

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelInfo.id,
      channelInfo.name,
      channelDescription: channelInfo.description,
      styleInformation: inboxStyleInformation,
      groupKey: channelInfo.groupKey,
      setAsGroupSummary: true,
      enableLights: true,
    );

    return NotificationDetails(android: androidNotificationDetails);
  }

  static void showNotification({required NotificationChannelInfo channelInfo, required String title, required String content}) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelInfo.id,
      channelInfo.name,
      channelDescription: channelInfo.description,
      importance: Importance.max,
      priority: Priority.high,
      subText: channelInfo.subText,
      groupKey: channelInfo.groupKey,
      enableLights: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(id++, title, content, notificationDetails);

    NotificationDetails groupNotification = getGroupNotifier(channelInfo);
    await flutterLocalNotificationsPlugin.show(channelInfo.groupID, null, null, groupNotification);
  }
}