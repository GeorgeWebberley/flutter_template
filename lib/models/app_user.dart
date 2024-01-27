import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppUser extends ChangeNotifier {
  final String uid;
  final List<String> providers;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;
  final bool emailVerified;

  AppUser({
    required this.uid,
    required this.providers,
    required this.email,
    this.firstName,
    this.lastName,
    this.imageUrl,
    required this.emailVerified,
  });

  static AppUser? fromFirebase(User? user) {
    if (user == null) return null;

    List<String>? name = user.displayName?.split(' ');
    String? firstName;
    String? lastName;

    if (name != null) {
      firstName = name.first;
      if (name.length >= 2) {
        lastName = name.last;
      }
    }

    return AppUser(
        uid: user.uid,
        email: user.email!,
        firstName: firstName,
        lastName: lastName,
        imageUrl: user.photoURL,
        emailVerified: user.emailVerified,
        providers: user.providerData
            .map((UserInfo userInfo) => userInfo.providerId)
            .toList());
  }
}
