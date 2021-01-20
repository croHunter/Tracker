import 'package:flutter/foundation.dart';
import 'package:time_tracker/auth-page/email-signin-model.dart';
import 'package:time_tracker/auth-page/validator.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInChangeModel with EmailAndPasswordValidator, ChangeNotifier {
  String email;
  String password;
  EmailSignInFormType formType;
  bool isLoading;
  bool submitted;
  bool isVisible;
  AuthBase auth;

  EmailSignInChangeModel({
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
    this.isVisible = false,
    @required this.auth,
  });
  Future<void> onSubmit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      if (formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmail(email, password);
      } else {
        await auth.createUserWithEmail(email, password);
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateEmail(email) => updateWith(email: email);
  void updatePassword(password) => updateWith(password: password);

  void toggleFormType() {
    final formType = this.formType == EmailSignInFormType.signIn
        ? EmailSignInFormType.register
        : EmailSignInFormType.signIn;
    updateWith(
      submitted: false,
      formType: formType,
      email: '',
      password: '',
      isLoading: false,
      isVisible: false,
    );
  }

  void updateWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
    bool isVisible,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.isVisible = isVisible ?? this.isVisible;
    notifyListeners();
  }

  String get primaryButtonText {
    return formType == EmailSignInFormType.signIn
        ? "Sign in"
        : "Create an account";
  }

  String get secondaryButtonText {
    return formType == EmailSignInFormType.signIn
        ? "Need an account? Register"
        : "Have an account? Sign in";
  }

  bool get canSubmit {
    return emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        !isLoading;
  }

  String get emailErrorText {
    bool showEmailError =
        submitted && !emailValidator.isValid(email); //submitted but not valid
    return showEmailError ? invalidEmailErrorText : null;
  }

  String get passwordErrorText {
    bool showPasswordError = submitted &&
        !emailValidator.isValid(password); //submitted but not valid
    return showPasswordError ? invalidPasswordErrorText : null;
  }
}
