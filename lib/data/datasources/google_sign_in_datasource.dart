import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInDatasource {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google Sign-In 후 OAuthCredential 반환. 취소 시 null.
  Future<OAuthCredential?> getCredential() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null; // 유저가 취소

    final auth = await account.authentication;
    return GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
