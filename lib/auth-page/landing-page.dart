import 'package:flutter/material.dart';
import 'package:time_tracker/pages/home-page.dart';
import 'package:time_tracker/services/auth.dart';
import 'auth-page.dart';

class LandingPage extends StatelessWidget {
  final AuthBase auth;
  LandingPage({@required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FireUser>(
      stream: auth.onAuthStateChange(),
      // ignore: missing_return
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FireUser user = snapshot.data;
          if (user == null) {
            return AuthPage(
              auth: auth,
            );
          }
          return HomePage(
            auth: auth,
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
