import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/acount-avatar.dart';
import 'package:time_tracker/widget/platform-aware-dialog.dart';

class AccountPage extends StatelessWidget {
  Future<void> _onSignOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await auth.signOut();
  }

  Future<void> _conformSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAwareDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      defaultActionText: 'Logout',
      cancelActionText: 'Cancel',
    ).show(context);
    if (didRequestSignOut) {
      await _onSignOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FireUser>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
        centerTitle: true,
        actions: [
          FlatButton(
            onPressed: () => _conformSignOut(context),
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(140),
          child: _buildUserInfo(user),
        ),
      ),
    );
  }

  Widget _buildUserInfo(FireUser user) {
    return Column(
      children: [
        Avatar(
          radius: 50,
          photoUrl: user.photoUrl,
        ),
        SizedBox(
          height: 8,
        ),
        if (user.displayName != null)
          Text(
            user.displayName,
            style: TextStyle(color: Colors.white),
          ),
        SizedBox(
          height: 8,
        ),
        if (user.email != null)
          Text(
            user.email,
            style: TextStyle(color: Colors.white),
          ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
