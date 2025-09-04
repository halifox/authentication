import 'package:auth/auth.dart';
import 'package:auth/repository.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

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
          FilledButton(
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

showOverwriteDialog(BuildContext context, AuthConfig config) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlertDialog(
        title: Text('警告'),
        content: Text('令牌${config.issuer}:${config.account}已经存在,是否覆盖它'),
        actions: [
          OutlinedButton(
            onPressed: () async {
              await authStore.update(
                db,
                config.toJson(),
                finder: Finder(
                  filter: Filter.and([
                    Filter.equals('account', config.account),
                    Filter.equals('issuer', config.issuer),
                  ]),
                ),
              );
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            child: Text('是'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('否'),
          ),
        ],
      );
    },
  );
}
