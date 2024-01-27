import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';

import 'dart:io' show Platform;

class PushNotificationProvider {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  LocalStorageProvider localStorageProvider;
  bool? _permissionGranted;

  bool? get permissionGranter => _permissionGranted;

  PushNotificationProvider({required this.localStorageProvider});

  init() async {
    // From the docs: "Android applications are not required to request permission."
    if (Platform.isAndroid) {
      _permissionGranted = true;
      return;
    }

    String? permission =
        await localStorageProvider.get(key: LocalStorageKeys.pushNotification);

    if (permission == AuthorizationStatus.notDetermined.toString() ||
        permission == null) {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      await localStorageProvider.set(
          key: LocalStorageKeys.pushNotification,
          value: settings.authorizationStatus.toString());

      _permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
    } else {
      _permissionGranted =
          permission == AuthorizationStatus.authorized.toString() ||
              permission == AuthorizationStatus.provisional.toString();
    }
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage(
      void Function(RemoteMessage) handleMessage) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
