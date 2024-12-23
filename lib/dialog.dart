import 'package:flutter/material.dart';

Future<int?> showAlertDialog(
  BuildContext context,
  String? title,
  String? message, {
  bool barrierDismissible = false,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return AlertDialog(
        title: Text(title ?? ''),
        content: Text(message ?? ''),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}

showDevDialog(
  BuildContext context,
) {
  showAlertDialog(context, "提示", "正在开发中");
}
