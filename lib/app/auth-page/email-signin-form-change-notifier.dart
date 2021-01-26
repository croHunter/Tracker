import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/custom-avatar.dart';
import 'package:time_tracker/widget/platform-exception-aware-dialog.dart';
import 'package:time_tracker/widget/sign-up-button.dart';

import 'email-signin-change-model.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  EmailSignInFormChangeNotifier({@required this.model});

  final EmailSignInChangeModel model;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (context) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (context, model, _) =>
            EmailSignInFormChangeNotifier(model: model),
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  EmailSignInChangeModel get model => widget.model;

  Future<void> _onSubmit() async {
    try {
      await model.onSubmit();
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      debugPrint("FirebaseException :" + e.toString());
      PlatformExceptionAwareDialog(
        title: "Sign in failed",
        firebaseException: e,
      ).show(context);
    }
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
    return [
      CustomAvatar(),
      _buildEmailField(),
      SizedBox(height: 20),
      _buildPasswordField(),
      SizedBox(height: 20),
      SignUpButton(
        padding: EdgeInsets.symmetric(vertical: 12),
        color: Colors.teal,
        text: model.primaryButtonText,
        textColor: Colors.white,
        onPressed: model.canSubmit ? _onSubmit : null,
      ),
      FlatButton(
        child: Text(
          model.secondaryButtonText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        onPressed: model.isLoading ? null : _toggleFormType,
      ),
    ];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildChildren(),
    );
  }

  TextField _buildEmailField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete(),
      keyboardType: TextInputType.emailAddress,
      onChanged: model.updateEmail,
      style: new TextStyle(
        fontSize: 16.0,
        color: Colors.white,
        fontFamily: "Poppins",
      ),
      decoration: InputDecoration(
        // fillColor: Colors.green,
        // filled: true,
        labelText: "Enter Email",
        labelStyle: TextStyle(color: Colors.yellowAccent),
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
        // counterText: "Fill required",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.teal,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  TextField _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: _onSubmit,
      obscureText: model.isVisible ? false : true,
      onChanged: model.updatePassword,
      style: new TextStyle(
        fontSize: 16.0,
        color: Colors.white,
        fontFamily: "Poppins",
      ),
      decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () {
              model.updateWith(isVisible: !(model.isVisible));
            },
            child: Icon(
              model.isVisible ? Icons.visibility : Icons.visibility_off,
              size: 16,
              color: Colors.white,
            ),
          ),
          labelText: "Password",
          labelStyle: TextStyle(color: Colors.yellowAccent),
          errorText: model.passwordErrorText,
          enabled: model.isLoading == false,
          // counterText: "Fill required",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.teal, width: 1.5))),
    );
  }
}
