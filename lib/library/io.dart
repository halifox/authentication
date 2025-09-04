import 'dart:io';

import 'package:auth/dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

createBackupImpl(context, json, filename) async {
  var file;
  if (Platform.isAndroid && false) {
    // var status = await Permission.storage.request();
    // if (!status.isGranted) throw Exception("Storage permission denied");
    // file = File('/storage/emulated/0/Download/$filename');
  } else {
    var dir = await getDownloadsDirectory();
    if (dir == null) return;
    await dir.create(recursive: true);
    file = File(join(dir.path, filename));
  }
  await file.writeAsString(json);
  showAlertDialog(context, "导出成功", "文件位置:${file.path}");
}
