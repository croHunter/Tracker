import 'dart:io';
import 'package:flutter/material.dart';
import 'package:time_tracker/auth-page/validator.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/custom-avatar.dart';
import 'package:time_tracker/widget/platform-aware-dialog.dart';
import 'package:time_tracker/widget/sign-up-button.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInForm extends StatefulWidget with EmailAndPasswordValidator {
  EmailSignInForm({@required this.auth});
  final AuthBase auth;
  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  bool _isVisible = false;
  bool _submitted = false;
  bool _isLoading = false;

  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String get _email => emailController.text;
  String get _password => passwordController.text;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool get _submitEnabled =>
      widget.emailValidator.isValid(_email) &&
      widget.passwordValidator.isValid(_password) &&
      !_isLoading;

  Future<void> _onSubmit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    if (_formType == EmailSignInFormType.signIn) {
      try {
        await widget.auth.signInWithEmail(_email, _password);
        Navigator.of(context).pop();
      } catch (e) {
        debugPrint("signin error : ${e.toString()}");
        PlatformAwareDialog(
          title: "Sign in failed",
          content: "${e.toString()}",
          defaultActionText: "Ok",
        ).show(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      try {
        await widget.auth.createUserWithEmail(_email, _password);
        Navigator.of(context).pop();
      } catch (e) {
        debugPrint("singUp error : ${e.toString()}");
        PlatformAwareDialog(
          title: "Sign in failed",
          content: "${e.toString()}",
          defaultActionText: "Ok",
        ).show(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    _submitted = false;
    setState(() {
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });
    emailController.clear();
    passwordController.clear();
  }

  List<Widget> _buildChildren() {
    final primaryText = _formType == EmailSignInFormType.signIn
        ? "Sign in"
        : "Create an account";
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? "Need an account? Register"
        : "Have an account? Sign in";

    return [
      CustomAvatar(),
      _buildEmailField(),
      SizedBox(height: 20),
      _buildPasswordField(),
      SizedBox(height: 20),
      SignUpButton(
        padding: EdgeInsets.symmetric(vertical: 12),
        color: Colors.teal,
        text: primaryText,
        textColor: Colors.white,
        onPressed: _submitEnabled ? _onSubmit : null,
      ),
      FlatButton(
        child: Text(
          secondaryText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        onPressed: _isLoading ? null : _toggleFormType,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildChildren(),
    );
  }

  TextFormField _buildEmailField() {
    bool showEmailError = _submitted &&
        !widget.emailValidator.isValid(_email); //submitted but not valid
    return TextFormField(
      controller: emailController,
      focusNode: _emailFocusNode,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      onEditingComplete: _emailEditingComplete,
      keyboardType: TextInputType.emailAddress,
      onChanged: (email) {
        _updateState();
      },
      style: new TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontFamily: "Poppins",
      ),
      decoration: InputDecoration(
        // fillColor: Colors.green,
        // filled: true,
        labelText: "Enter Email",
        labelStyle: TextStyle(color: Colors.yellowAccent),
        errorText: showEmailError ? widget.invalidEmailErrorText : null,
        enabled: _isLoading == false,
        // counterText: "Fill required",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.redAccent, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.teal,
            width: 3,
          ),
        ),
      ),
    );
  }

  TextFormField _buildPasswordField() {
    bool showPasswordError =
        _submitted && !widget.passwordValidator.isValid(_password);
    return TextFormField(
      controller: passwordController,
      focusNode: _passwordFocusNode,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: _submitEnabled ? _onSubmit : null,
      obscureText: _isVisible ? false : true,
      onChanged: (password) {
        _updateState();
      },
      style: new TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontFamily: "Poppins",
      ),
      decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
            child: Icon(
              _isVisible ? Icons.visibility : Icons.visibility_off,
              size: 24,
              color: Colors.white,
            ),
          ),
          labelText: "Password",
          labelStyle: TextStyle(color: Colors.yellowAccent),
          errorText: showPasswordError ? widget.invalidPasswordErrorText : null,
          enabled: _isLoading == false,
          // counterText: "Fill required",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.redAccent, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.teal, width: 3))),
    );
  }

  void _updateState() => setState(() {});
}
