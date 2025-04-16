import 'dart:io';

import 'package:auth/dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

createBackupImpl(context, json, filename) async {
  var dir = await getApplicationDocumentsDirectory();
  await dir.create(recursive: true);
  var path = join(dir.path, filename);
  var file = File(path);
  await file.writeAsString(json);
  showAlertDialog(context, "导出成功", "文件位置:${path}");
}
