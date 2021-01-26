import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/widget/platform-widget.dart';

class PlatformAwareDialog extends PlatformWidget {
  PlatformAwareDialog({
    @required this.title,
    @required this.content,
    @required this.defaultActionText,
    this.cancelActionText,
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String defaultActionText;
  final String cancelActionText;

  Future<bool> show(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => this,
          )
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
          );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildAction(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildAction(context),
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    List<Widget> actions = [];
    if (cancelActionText != null) {
      actions.add(PlatformAwareDialogAction(
        child: Text(cancelActionText),
        onPressed: () => Navigator.of(context).pop(false),
      ));
    }
    actions.add(PlatformAwareDialogAction(
      child: Text(defaultActionText),
      onPressed: () => Navigator.of(context).pop(true),
    ));
    return actions;
  }
}

class PlatformAwareDialogAction extends PlatformWidget {
  final Widget child;
  final VoidCallback onPressed;

  PlatformAwareDialogAction({
    this.child,
    this.onPressed,
  });
  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
}
