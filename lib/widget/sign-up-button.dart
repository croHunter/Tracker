import '../widget/custom-raised-button.dart';
import 'package:flutter/material.dart';

class SignUpButton extends CustomRaisedButton {
  SignUpButton({
    @required String text,
    Color color,
    Color textColor,
    VoidCallback onPressed,
    EdgeInsetsGeometry padding,
  })  : assert(text != null),
        super(
          padding: padding,
          child: Text(text,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              )),
          color: color,
          onPressed: onPressed,
        );
}
