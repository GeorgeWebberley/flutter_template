import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInProvider {
  User? _user;
  User? get user => _user;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> login() async {
    try {
      print("test 1");
      // Perform the sign-in request
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print("test 2");

      // Create a new credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      print("test 3");

      // Sign in the user with Firebase
      final UserCredential creds =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      print("test 4");

      _user = creds.user;
      print("test 5");

      return creds;
    } catch (e) {
      print("test 6");

      print(e.toString());

      return null;
    }
  }
}
