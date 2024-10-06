import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppUser extends ChangeNotifier {
  final String uid;
  final List<String> providers;
  final String email;
  final String? name;
  final String? imageUrl;
  final bool emailVerified;

  AppUser({
    required this.uid,
    required this.providers,
    required this.email,
    this.name,
    this.imageUrl,
    required this.emailVerified,
  });

  static AppUser? fromFirebase(User? user) {
    if (user == null) return null;

    // print("user.uid: ${user.uid}");
    // print("user.email: ${user.email}");
    // print("user.displayName: ${user.displayName}");
    // print("user.photoURL: ${user.photoURL}");
    // print("user.emailVerified: ${user.emailVerified}");
    // print("user.providerData: ${user.providerData}");

    return AppUser(
        uid: user.uid,
        email: user.email!,
        name: user.displayName,
        imageUrl: user.photoURL,
        emailVerified: user.emailVerified,
        providers: user.providerData
            .map((UserInfo userInfo) => userInfo.providerId)
            .toList());
  }
}
