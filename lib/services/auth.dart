import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireUser {
  final String uId;
  FireUser({this.uId});
}

abstract class AuthBase {
  //public interface
  FireUser currentUser();
  Future<FireUser> signInAnonymously();
  Future<void> signOut();
  Stream<FireUser> onAuthStateChange();
  Future<FireUser> signInWithGoogle();
  Future<FireUser> signInWithFacebook();
  Future<FireUser> signInWithEmail(email, password);
  Future<FireUser> createUserWithEmail(email, password);
}

class Auth implements AuthBase {
  final _auth = FirebaseAuth.instance;

  FireUser _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }
    return FireUser(uId: user.uid); //instance( i.e object ) of FireUser
  }

  @override
  Stream<FireUser> onAuthStateChange() {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  @override
  FireUser currentUser() {
    final user = _auth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Future<FireUser> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  @override
  Future<FireUser> signInWithFacebook() async {
    FireUser resultAuth;
    final facebookSignIn = FacebookLogin();
    facebookSignIn.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await facebookSignIn.logIn(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        print("cancel by user");
        print(result.errorMessage);
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
        break;
      case FacebookLoginStatus.error:
        print("error");
        print(result.errorMessage);
        throw PlatformException(
          code: 'ERROR FB LOGIN',
          message: 'There is some problem',
        );
        break;
      case FacebookLoginStatus.loggedIn:
        resultAuth = await _handleFbSignIn(result);
        return resultAuth;
      default:
        print("switch default is excuted in fb login section");
    }
    return resultAuth;
  }

  Future<FireUser> _handleFbSignIn(FacebookLoginResult result) async {
    if (result.accessToken != null) {
      final authResult = await _auth.signInWithCredential(
          FacebookAuthProvider.credential(result.accessToken.token));
      return _userFromFirebase(authResult.user);
    } else {
      print("null case: " + result.errorMessage);
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  Future<FireUser> signInWithEmail(email, password) async {
    final authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  Future<FireUser> createUserWithEmail(email, password) async {
    final authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<FireUser> signInAnonymously() async {
    UserCredential authResult;
    try {
      authResult = await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("anonymous sing in error :" + e.toString());
    }
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final facebookSignIn = FacebookLogin();
      await facebookSignIn.logOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("error on SignOut : ${e.toString()}");
    }
  }
}
