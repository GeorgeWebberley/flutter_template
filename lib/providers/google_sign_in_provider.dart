import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;

  Future<UserCredential?> googleLogin() async {
    OAuthCredential? credential = await getLoginCredential();

    return credential != null
        ? await FirebaseAuth.instance.signInWithCredential(credential)
        : null;
  }

  Future<OAuthCredential?> getLoginCredential() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    _user = googleUser;

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    return GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  }
}
