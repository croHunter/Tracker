import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  CustomRaisedButton({
    Key key,
    this.onPressed,
    this.child,
    this.color,
    this.borderRadius: 10,
    this.padding,
  })  : assert(borderRadius != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: padding,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
      onPressed: onPressed,
    );
  }
}
