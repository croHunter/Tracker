import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/auth-page/email-signin-page.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/custom-avatar.dart';
import 'package:time_tracker/widget/platform-exception-aware-dialog.dart';
import 'package:time_tracker/widget/sign-up-button.dart';
import 'package:time_tracker/widget/social-button.dart';

import 'auth-manager.dart';

class AuthPage extends StatelessWidget {
  AuthPage({@required this.manager, @required this.isLoading});
  final AuthManager manager;
  final bool isLoading;
  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<AuthManager>(
          create: (_) => AuthManager(auth: auth, isLoading: isLoading),
          child: Consumer<AuthManager>(
            builder: (_, manager, __) => AuthPage(
              manager: manager,
              isLoading: isLoading.value,
            ),
          ),
        ),
      ),
    );
  }

  void _showSignInError(
      BuildContext context, PlatformException e1, FirebaseAuthException e2) {
    PlatformExceptionAwareDialog(
      title: "Sign in failed",
      platformException: e1,
      firebaseException: e2,
    ).show(context);
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await manager.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _showSignInError(context, null, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e, null);
      }
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _showSignInError(context, e, null);
      }
    }
  }

  void _signUpWithEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => SignInPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Tracker"),
        backgroundColor: Colors.purple.withOpacity(0.5),
        centerTitle: true,
      ),
      backgroundColor: Colors.purple.withOpacity(0.3),
      body:
          isLoading ? _buildProgressHeader() : _buildColumn(context, isLoading),
    );
  }

  Column _buildColumn(BuildContext context, bool isLoading) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomAvatar(),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: SocialButton(
              text: "Sign in with Google",
              assetName: "images/google-logo.png",
              color: Colors.white,
              textColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 10),
              onPressed: isLoading ? null : () => _signInWithGoogle(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: SocialButton(
              text: "Sign in with Facebook",
              assetName: "images/facebook-logo.png",
              color: Color(0xff334d92),
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10),
              onPressed: isLoading ? null : () => _signInWithFacebook(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: SignUpButton(
                text: "Sign up with email",
                textColor: Colors.white,
                onPressed: isLoading ? null : () => _signUpWithEmail(context),
                color: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 10)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text("or",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SignUpButton(
                text: "Go anonymous",
                textColor: Colors.white,
                onPressed: isLoading ? null : () => _signInAnonymously(context),
                color: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 10)),
          ),
        ]);
  }

  Widget _buildProgressHeader() {
    return Center(child: CircularProgressIndicator());
  }
}
