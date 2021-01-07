import 'package:flutter/material.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/platform-aware-dialog.dart';
import 'package:time_tracker/widget/sign-up-button.dart';

class HomePage extends StatelessWidget {
  HomePage({@required this.auth});
  final AuthBase auth;

  Future<void> _onSignOut() async {
    await auth.signOut();
  }

  Future<void> _comformSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAwareDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      defaultActionText: 'Logout',
      cancelActionText: 'Cancel',
    ).show(context);
    if (didRequestSignOut) {
      await _onSignOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: SignUpButton(
            text: "LogOut",
            onPressed: () => _comformSignOut(context),
          ),
        ),
      ),
    );
  }
}
