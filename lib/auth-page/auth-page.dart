import 'package:flutter/material.dart';
import 'package:time_tracker/auth-page/email-signin-page.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/custom-avatar.dart';
import 'package:time_tracker/widget/sign-up-button.dart';
import 'package:time_tracker/widget/social-button.dart';

class AuthPage extends StatelessWidget {
  AuthPage({@required this.auth});
  final AuthBase auth;

  Future<void> _signInAnonymously() async {
    await auth.signInAnonymously();
  }

  Future<void> _signInWithGoogle() async {
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      debugPrint("Error on google signin: ${e.toString()}");
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      await auth.signInWithFacebook();
    } catch (e) {
      debugPrint("Error on facebook signin: ${e.toString()}");
    }
  }

  void _signUpWithEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      // fullscreenDialog: false,
      builder: (context) => SignInPage(
        auth: auth,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.withOpacity(0.3),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomAvatar(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: SocialButton(
                  text: "Sign in with Google",
                  assetName: "images/google-logo.png",
                  color: Colors.white,
                  textColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  onPressed: _signInWithGoogle,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: SocialButton(
                  text: "Sign in with Facebook",
                  assetName: "images/facebook-logo.png",
                  color: Color(0xff334d92),
                  textColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  onPressed: _signInWithFacebook,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SignUpButton(
                    text: "Sign up with email",
                    textColor: Colors.white,
                    onPressed: () => _signUpWithEmail(context),
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
                    onPressed: _signInAnonymously,
                    color: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 10)),
              ),
            ]),
      ),
    );
  }
}
