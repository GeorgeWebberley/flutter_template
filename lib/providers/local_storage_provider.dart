import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LocalStorageKeys {
  static String get pushNotification => "push-notification";
}

// Wrapper around flutter secure storage
// TODO: Currently this is excessive as it doesn't add anything. Included in case other required functionality is needed
class LocalStorageProvider {
  final storage = const FlutterSecureStorage();

  set({required String key, required String value}) async {
    try {
      await storage.write(key: key, value: value);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<String?> get({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  delete({required String key}) async {
    try {
      return await storage.delete(key: key);
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
