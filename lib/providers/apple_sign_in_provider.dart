import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInProvider {
  User? _user;
  User? get user => _user;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> login() async {
    try {
      // Perform the sign-in request
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create a new credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      final UserCredential creds =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      _user = creds.user;
      return creds;
    } catch (e) {
      return null;
    }
  }
}
