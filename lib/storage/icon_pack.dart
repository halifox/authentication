import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/storage/icon_data.dart';
import 'package:protobuf/protobuf.dart';

typedef IconPack = ({
  String name,
  String description,
  String url,
  Map<String, String> icons,
});

const maxIconPackBytes = 10 * 1024 * 1024;
const maxStoredIconPacksBytes = 4 * 1024 * 1024;

IconPack validateIconPack(IconPack pack) {
  if (pack.name.trim() != pack.name ||
      pack.name.isEmpty ||
      pack.name.length > 100 ||
      pack.name.contains('\u0000') ||
      pack.description.length > 1000 ||
      pack.url.length > 2048 ||
      pack.icons.isEmpty ||
      pack.icons.length > 1000) {
    throw const FormatException('Invalid icon pack.');
  }
  var total = 0;
  for (final entry in pack.icons.entries) {
    if (entry.key.trim() != entry.key ||
        entry.key.isEmpty ||
        entry.key.length > 100 ||
        entry.key.contains('\u0000') ||
        !isCustomIcon(entry.value)) {
      throw const FormatException('Invalid icon pack entry.');
    }
    total += entry.key.length + entry.value.length;
    if (total > maxStoredIconPacksBytes) {
      throw const FormatException('Icon pack is too large.');
    }
    validateIcon(entry.value);
  }
  return pack;
}

List<IconPack> validateIconPacks(List<IconPack> packs) {
  if (packs.length > 100 ||
      packs.map((pack) => pack.name).toSet().length != packs.length) {
    throw const FormatException('Invalid icon packs.');
  }
  var size = 0;
  for (final pack in packs) {
    validateIconPack(pack);
    size += jsonEncode(iconPackToJson(pack)).length;
    if (size > maxStoredIconPacksBytes) {
      throw const FormatException('Icon packs are too large.');
    }
  }
  return packs;
}

Map<String, Object> iconPackToJson(IconPack pack) => {
  'name': pack.name,
  'description': pack.description,
  'url': pack.url,
  'icons': pack.icons,
};

IconPack iconPackFromJson(Object? value) {
  if (value is! Map ||
      value['name'] is! String ||
      value['description'] is! String ||
      value['url'] is! String ||
      value['icons'] is! Map) {
    throw const FormatException('Invalid icon pack.');
  }
  final icons = <String, String>{};
  for (final entry in (value['icons'] as Map).entries) {
    if (entry.key is! String || entry.value is! String) {
      throw const FormatException('Invalid icon.');
    }
    icons[entry.key as String] = entry.value as String;
  }
  return validateIconPack((
    name: value['name'] as String,
    description: value['description'] as String,
    url: value['url'] as String,
    icons: icons,
  ));
}

IconPack parseIconPack(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxIconPackBytes) {
    throw const FormatException('Invalid icon pack size.');
  }
  try {
    final reader = CodedBufferReader(bytes, sizeLimit: maxIconPackBytes);
    String? name, description, url;
    final icons = <String, String>{};
    var decodedBytes = 0;
    while (!reader.isAtEnd()) {
      switch (reader.readTag()) {
        case 10:
          if (name != null) throw const FormatException();
          name = utf8.decode(reader.readBytes());
        case 18:
          if (description != null) throw const FormatException();
          description = utf8.decode(reader.readBytes());
        case 26:
          if (url != null) throw const FormatException();
          url = utf8.decode(reader.readBytes());
        case 34:
          if (icons.length >= 1000) throw const FormatException();
          final entry = CodedBufferReader(
            reader.readBytes(),
            sizeLimit: maxIconPackBytes,
          );
          String? iconName;
          Uint8List? data;
          while (!entry.isAtEnd()) {
            switch (entry.readTag()) {
              case 10:
                if (iconName != null) throw const FormatException();
                iconName = utf8.decode(entry.readBytes());
              case 18:
                if (data != null) throw const FormatException();
                data = entry.readBytes();
              default:
                throw const FormatException();
            }
          }
          if (iconName == null || data == null || icons.containsKey(iconName)) {
            throw const FormatException();
          }
          final icon = makeCustomIcon(data);
          decodedBytes += iconName.length + icon.length;
          if (decodedBytes > maxStoredIconPacksBytes) {
            throw const FormatException();
          }
          icons[iconName] = icon;
        default:
          throw const FormatException();
      }
    }
    return validateIconPack((
      name: name ?? '',
      description: description ?? '',
      url: url ?? '',
      icons: icons,
    ));
  } catch (_) {
    throw const FormatException('Invalid or unsupported icon pack.');
  }
}
