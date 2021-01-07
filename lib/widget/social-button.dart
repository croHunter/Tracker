import 'package:flutter/material.dart';
import 'package:time_tracker/widget/custom-raised-button.dart';

class SocialButton extends CustomRaisedButton {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final String assetName;
  SocialButton({
    @required this.assetName,
    @required this.text,
    this.color,
    this.onPressed,
    this.padding,
    this.textColor,
  })  : assert(assetName != null),
        assert(text != null),
        super(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Image.asset(assetName),
                Text(text, style: TextStyle(color: textColor, fontSize: 24)),
                Opacity(opacity: 0, child: Image.asset(assetName)),
              ]),
          padding: padding,
          color: color,
          onPressed: onPressed,
        );
}
