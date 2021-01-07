import 'package:flutter/material.dart';
import 'package:time_tracker/services/auth.dart';
import 'email-signin-form.dart';

class SignInPage extends StatelessWidget {
  SignInPage({@required this.auth});
  final AuthBase auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.withOpacity(0.5),
        title: Text('Sign up with Email',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            )),
        elevation: 3,
        centerTitle: true,
      ),
      backgroundColor: Colors.purple.withOpacity(0.3),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: EmailSignInForm(
            auth: auth,
          ),
        ),
      ),
    );
  }
}