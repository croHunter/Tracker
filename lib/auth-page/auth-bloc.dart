import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:time_tracker/services/auth.dart';

class AuthBloc {
  AuthBloc({@required this.auth});
  final AuthBase auth;
  final StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  void dispose() {
    _isLoadingController.close();
  }

  void _setIsloading(bool isLoading) => _isLoadingController.add(isLoading);

  Future<FireUser> signInAnonymously() async =>
      await _signIn(auth.signInAnonymously);
  Future<FireUser> signInWithGoogle() async =>
      await _signIn(auth.signInWithGoogle);
  Future<FireUser> signInWithFacebook() async =>
      await _signIn(auth.signInWithFacebook);

  Future<FireUser> _signIn(Future<FireUser> Function() signInMethod) async {
    try {
      _setIsloading(true);
      return await signInMethod();
    } catch (e) {
      _setIsloading(false);
      rethrow;
    }
  }
}
