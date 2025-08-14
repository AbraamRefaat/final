import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/utils/file_models.dart';

class MyFilesDialog extends StatelessWidget {
  final String path;
  final bool isDirectory;
  final Function onPressed;

  const MyFilesDialog({
    Key? key,
    required this.path,
    required this.isDirectory,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertCustomizedForDecisions(
      alertContent: getAlertContent(context),
      actions: buildActions(context),
    );
  }

  Widget getAlertContent(context) {
    final style = FileManagerInit.currentStyle;
    final message = isDirectory
        ? style.myFileDialogAlertFolder ?? "Are you sure you want to delete this folder?"
        : style.myFileDialogAlertFile ?? "Are you sure you want to delete this file?";
    return Text(message);
  }

  List<Widget> buildActions(context) {
    final style = FileManagerInit.currentStyle;
    List<Widget> actions = [];
    actions.add(createActionButton(context, style.textActionCancel ?? "Cancel"));
    actions.add(createActionButton(
      context,
      style.textActionDelete ?? "Delete",
      onDeleteFile: () => onPressed(),
    ));
    return actions;
  }

  Widget createActionButton(context, String buttonText,
      {Function? onDeleteFile}) {
    return TextButton(
      child: Text(buttonText),
      onPressed: () =>
          onDeleteFile != null ? onDeleteFile() : Navigator.of(context).pop(),
    );
  }
}

class AlertCustomizedForDecisions extends StatelessWidget {
  final Widget alertContent;
  final List<Widget> actions;

  const AlertCustomizedForDecisions({
    Key? key,
    required this.alertContent,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Theme.of(context).platform == TargetPlatform.iOS)
        ? createIosAlertDialog()
        : createAndroidAlertDialog();
  }

  CupertinoAlertDialog createIosAlertDialog() {
    return CupertinoAlertDialog(
      content: alertContent,
      actions: actions,
    );
  }

  AlertDialog createAndroidAlertDialog() {
    return AlertDialog(
      content: alertContent,
      actions: actions,
    );
  }
}
