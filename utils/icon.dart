import 'dart:convert';
import 'dart:io';

void main() {
  // 指定你要读取的文件夹路径
  final directory = Directory('/Users/user/IdeaProjects/PurityAuth/assets/icons');

  if (!directory.existsSync()) {
    print('目录不存在: ${directory.path}');
    return;
  }

  // 获取文件夹下所有文件
  final files = directory
      .listSync()
      .whereType<File>()
      .map((file) => file.uri.pathSegments.last) // 只取文件名
      .toList();

  // 转化为 JSON
  final jsonContent = jsonEncode(files);

  // 写入 JSON 文件
  final outputFile = File('/Users/user/IdeaProjects/PurityAuth/assets/icons.json');
  outputFile.writeAsStringSync(jsonContent);

  print('生成 JSON 成功: ${outputFile.path}');
}
