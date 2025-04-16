import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:auth/dialog.dart';

createBackupImpl(context, json, filename) async {
  var bytes = utf8.encode(json);
  var blob = html.Blob([Uint8List.fromList(bytes)]);
  var url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  showAlertDialog(context, "导出成功", "文件位置:查看浏览器下载记录");
}
