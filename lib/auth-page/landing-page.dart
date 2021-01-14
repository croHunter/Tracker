import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/pages/home-page.dart';

import 'package:time_tracker/services/auth.dart';
import 'auth-page.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<FireUser>(
      stream: auth.onAuthStateChange(),
      // ignore: missing_return
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FireUser user = snapshot.data;
          if (user == null) {
            return AuthPage.create(context);
          }
          return HomePage();
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
