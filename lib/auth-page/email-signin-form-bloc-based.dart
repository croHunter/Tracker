import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/auth-page/validator.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/widget/custom-avatar.dart';
import 'package:time_tracker/widget/platform-exception-aware-dialog.dart';
import 'package:time_tracker/widget/sign-up-button.dart';

import 'email-signin-bloc.dart';
import 'email-signin-model.dart';

class EmailSignInFormBlocBased extends StatefulWidget
    with EmailAndPasswordValidator {
  EmailSignInFormBlocBased({@required this.bloc});
  final EmailSignInBloc bloc;
  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return Provider<EmailSignInBloc>(
      create: (context) => EmailSignInBloc(auth: auth),
      child: Consumer<EmailSignInBloc>(
        builder: (context, bloc, _) => EmailSignInFormBlocBased(bloc: bloc),
      ),
      dispose: (context, bloc) => bloc.dispose(),
    );
  }

  @override
  _EmailSignInFormBlocBasedState createState() =>
      _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
  // bool _isVisible = false;
  // bool _submitted = false;
  // bool _isLoading = false;

  // EmailSignInFormType _formType = EmailSignInFormType.signIn;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // String get _email => _emailController.text;
  // String get _password => _passwordController.text;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Future<void> _onSubmit() async {
    try {
      await widget.bloc.onSubmit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException :" + e.toString());
      PlatformExceptionAwareDialog(
        title: "Sign in failed",
        firebaseAuthException: e,
      ).show(context);
    }
  }

  void _emailEditingComplete(EmailSignInModel model) {
    final newFocus = widget.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType(EmailSignInModel model) {
    widget.bloc.updateWith(
      submitted: false,
      formType: model.formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn,
      email: '',
      password: '',
      isLoading: false,
      isVisible: false,
    );

    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren(EmailSignInModel model) {
    final primaryText = model.formType == EmailSignInFormType.signIn
        ? "Sign in"
        : "Create an account";
    final secondaryText = model.formType == EmailSignInFormType.signIn
        ? "Need an account? Register"
        : "Have an account? Sign in";
    bool _submitEnabled = widget.emailValidator.isValid(model.email) &&
        widget.passwordValidator.isValid(model.password) &&
        !model.isLoading;

    return [
      CustomAvatar(),
      _buildEmailField(model),
      SizedBox(height: 20),
      _buildPasswordField(model),
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
        onPressed: model.isLoading ? null : () => _toggleFormType(model),
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
    return StreamBuilder<EmailSignInModel>(
        stream: widget.bloc.modelStream,
        initialData: EmailSignInModel(),
        builder: (context, snapshot) {
          final EmailSignInModel model = snapshot.data;
          debugPrint("Model : " + model.toString());
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildren(model),
          );
        });
  }

  TextFormField _buildEmailField(EmailSignInModel model) {
    bool showEmailError = model.submitted &&
        !widget.emailValidator.isValid(model.email); //submitted but not valid
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete(model),
      keyboardType: TextInputType.emailAddress,
      onChanged: (email) {
        widget.bloc.updateWith(email: email);
      },
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
        errorText: showEmailError ? widget.invalidEmailErrorText : null,
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

  TextFormField _buildPasswordField(EmailSignInModel model) {
    bool showPasswordError =
        model.submitted && !widget.passwordValidator.isValid(model.password);
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: _onSubmit,
      obscureText: model.isVisible ? false : true,
      onChanged: (password) {
        widget.bloc.updateWith(password: password);
      },
      style: new TextStyle(
        fontSize: 16.0,
        color: Colors.white,
        fontFamily: "Poppins",
      ),
      decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () {
              // setState(() {
              //   _isVisible = !_isVisible;
              // });
              widget.bloc.updateWith(isVisible: !(model.isVisible));
            },
            child: Icon(
              model.isVisible ? Icons.visibility : Icons.visibility_off,
              size: 16,
              color: Colors.white,
            ),
          ),
          labelText: "Password",
          labelStyle: TextStyle(color: Colors.yellowAccent),
          errorText: showPasswordError ? widget.invalidPasswordErrorText : null,
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
