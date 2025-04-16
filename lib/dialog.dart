import 'package:flutter/material.dart';

Future<int?> showAlertDialog(context, title, message, {actions, barrierDismissible = false}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlertDialog(title: Text(title), content: Text(message), actions: <Widget>[...?actions, ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))]);
    },
  );
}

showDevDialog(BuildContext context) {
  showAlertDialog(context, "提示", "正在开发中");
}
