import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:time_tracker/services/auth.dart';

class AuthManager {
  AuthManager({
    @required this.auth,
    @required this.isLoading,
  });
  final AuthBase auth;
  final ValueNotifier<bool> isLoading;

  Future<FireUser> signInAnonymously() async =>
      await _signIn(auth.signInAnonymously);
  Future<FireUser> signInWithGoogle() async =>
      await _signIn(auth.signInWithGoogle);
  Future<FireUser> signInWithFacebook() async =>
      await _signIn(auth.signInWithFacebook);

  Future<FireUser> _signIn(Future<FireUser> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }
}
