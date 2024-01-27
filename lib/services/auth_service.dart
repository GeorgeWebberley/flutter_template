import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/providers/google_sign_in_provider.dart';

enum AuthType { email, google }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignInProvider _googleSignIn = GoogleSignInProvider();

  // photos document reference
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  // When user signs up, will create an entry in the firestore database for the user
  Future addUserToDb({required String email, required String id}) async {
    return await usersRef.doc(id).set({'email': email});
  }

  // When user signs up, will create an entry in the firestore database for the user
  Future<Object?> readUserFromDb({required String? id}) async {
    DocumentSnapshot<Object?> user = await usersRef.doc(id).get();
    if (user.exists) {
      return user.data();
    } else {
      return null;
    }
  }

  //   // auth stream (when user logs in/out)
  // Stream<AppUser?> get user {
  //   return _auth
  //       .authStateChanges() // Firebase function that returns a firebase 'User' stream
  //       .map((User? user) => AppUser.fromFirebase(
  //           user)); // map firebase 'User' to my own app's 'AppUser' class.
  // }

  // auth stream (when user logs in/out)
  Stream<AppUser?> get user => _auth
      .authStateChanges() // Firebase function that returns a firebase 'User' stream
      .map((User? user) => AppUser.fromFirebase(
          user)); // map firebase 'User' to my own app's 'AppUser' class.

  // sign in with firebase
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AppUser.fromFirebase(result.user);
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  // sign in with google into firebase
  Future signInWithGoogle() async {
    try {
      UserCredential? result = await _googleSignIn.googleLogin();

      print("result?.user?.providerData");
      print(result?.user?.providerData);

      return AppUser.fromFirebase(result!.user);
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  // register with firebase
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return AppUser.fromFirebase(result.user);
    } on FirebaseAuthException catch (error) {
      debugPrint(error.toString());
      return error.message;
    } catch (error) {
      debugPrint(error.toString());
      return 'Could not register with those credentials';
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) return false;

    final cred = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);

    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<void> sendResetPasswordEmail({required String email}) async =>
      await _auth.sendPasswordResetEmail(email: email);
}
