import 'package:flutter/material.dart';

Future<int?> showAlertDialog(context, title, message, {actions, barrierDismissible = false}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ...?actions,
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('确定'),
          ),
        ],
      );
    },
  );
}
