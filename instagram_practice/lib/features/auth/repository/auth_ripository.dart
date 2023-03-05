import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_practice/features/auth/constants/constants.dart';
import 'package:instagram_practice/features/auth/models/auth_result.dart';
import 'package:instagram_practice/shared/stypedefs/user_id.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    facebookAuthInstance: FacebookAuth.instance,
    firebaseAuthInstance: FirebaseAuth.instance,
  );
});

class AuthRepository {
  final FirebaseAuth firebaseAuthInstance;
  final FacebookAuth facebookAuthInstance;

  const AuthRepository({
    required this.facebookAuthInstance,
    required this.firebaseAuthInstance,
  });

  // getters

  bool get isAlreadyLoggedIn => userId != null;
  UserId? get userId => firebaseAuthInstance.currentUser?.uid;
  String get displayName => firebaseAuthInstance.currentUser?.displayName ?? '';
  String? get email => firebaseAuthInstance.currentUser?.email;

  Future<void> logOut() async {
    await firebaseAuthInstance.signOut();
    await GoogleSignIn().signOut();
    await facebookAuthInstance.logOut();
  }

  Future<AuthResult> loginWithFacebook() async {
    final loginResult = await facebookAuthInstance.login();
    final token = loginResult.accessToken?.token;
    if (token == null) {
      return AuthResult.aborted;
    }
    final oauthCredentials = FacebookAuthProvider.credential(token);

    try {
      await firebaseAuthInstance.signInWithCredential(
        oauthCredentials,
      );
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      final email = e.email;
      final credential = e.credential;
      if (e.code == Constants.accountExistsWithDifferentCredentialsError &&
          email != null &&
          credential != null) {
        final providers =
            await firebaseAuthInstance.fetchSignInMethodsForEmail(email);
        if (providers.contains(Constants.googleCom)) {
          await loginWithGoogle();
          firebaseAuthInstance.currentUser?.linkWithCredential(credential);
        }
        return AuthResult.success;
      }
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        Constants.emailScope,
      ],
    );
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount == null) {
      return AuthResult.aborted;
    }

    final googleAuth = await signInAccount.authentication;
    final oauthCredentials = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    try {
      await firebaseAuthInstance.signInWithCredential(
        oauthCredentials,
      );
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}
