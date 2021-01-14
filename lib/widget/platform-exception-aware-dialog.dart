import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_tracker/widget/platform-aware-dialog.dart';

class PlatformExceptionAwareDialog extends PlatformAwareDialog {
  PlatformExceptionAwareDialog({
    @required String title,
    FirebaseAuthException firebaseAuthException,
    PlatformException platformException,
  })  : assert(title != null),
        super(
          title: title,
          content: _message(platformException ?? firebaseAuthException),
          defaultActionText: 'OK',
        );
  static String _message(exception) {
    return _error[exception.code] ??
        exception
            .message; //if _error[exception.code] =null then exception.message
  }

  static Map<String, String> _error = {
    "expired-action-code": "OTP in email link expires",
    "invalid-email": "The email address is not valid",
    "user-disabled":
        "Thrown if the user corresponding to the given email has been disabled",
    'ERROR_MISSING_GOOGLE_AUTH_TOKEN': 'Missing Google Auth Token',
    'ERROR_ABORTED_BY_USER': 'Sign in aborted by user',
  };
}
