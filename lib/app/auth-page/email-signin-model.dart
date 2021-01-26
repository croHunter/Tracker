import 'package:time_tracker/app/auth-page/validator.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInModel with EmailAndPasswordValidator {
  final String email;
  final String password;
  final EmailSignInFormType formType;
  final bool isLoading;
  final bool submitted;
  final bool isVisible;
  EmailSignInModel({
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
    this.isVisible = false,
  });

  get updatePassword => null;
//Named Constructor//?????????????????
  EmailSignInModel copyWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
    bool isVisible,
  }) {
    return EmailSignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      formType: formType ?? this.formType,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted,
      isVisible: isVisible ?? this.isVisible,
    );
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
