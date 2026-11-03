import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:xml/xml.dart' as xml;

const customIconPrefix = 'data:image/png;base64,';
const customSvgPrefix = 'data:image/svg+xml;base64,';
const _maxIconBytes = 128 * 1024;
const _maxInputBytes = 10 * 1024 * 1024;

bool isCustomIcon(String value) =>
    value.startsWith(customIconPrefix) || value.startsWith(customSvgPrefix);

Uint8List validateIcon(String value) {
  if (!isCustomIcon(value)) {
    if (!RegExp(r'^assets/icons/[a-zA-Z0-9_-]+\.svg$').hasMatch(value)) {
      throw const FormatException('Invalid icon.');
    }
    return Uint8List(0);
  }
  final isSvg = value.startsWith(customSvgPrefix);
  final encoded = value.substring(
    isSvg ? customSvgPrefix.length : customIconPrefix.length,
  );
  if (encoded.length > ((_maxIconBytes + 2) ~/ 3) * 4) {
    throw const FormatException('Icon is too large.');
  }
  try {
    final bytes = base64Decode(encoded);
    if (bytes.isEmpty ||
        bytes.length > _maxIconBytes ||
        base64Encode(bytes) != encoded) {
      throw const FormatException();
    }
    if (isSvg) {
      _validateSvg(bytes);
      return bytes;
    }
    final decoder = image.PngDecoder();
    final info = decoder.startDecode(bytes);
    if (info == null ||
        info.width < 1 ||
        info.height < 1 ||
        info.width > 128 ||
        info.height > 128 ||
        info.numFrames != 1 ||
        decoder.decodeFrame(0) == null) {
      throw const FormatException();
    }
    return bytes;
  } catch (_) {
    throw const FormatException('Invalid icon.');
  }
}

String makeCustomIcon(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > _maxInputBytes) {
    throw const FormatException('Invalid image size.');
  }
  try {
    final decoder = image.findDecoderForData(bytes);
    if (decoder is! image.PngDecoder && decoder is! image.JpegDecoder) {
      throw const FormatException();
    }
    final info = decoder!.startDecode(bytes);
    if (info == null ||
        info.width < 1 ||
        info.height < 1 ||
        info.width > 4096 ||
        info.height > 4096 ||
        info.width * info.height > 16000000 ||
        info.numFrames != 1) {
      throw const FormatException();
    }
    final source = decoder.decodeFrame(0);
    if (source == null) throw const FormatException();
    final result = image.copyResize(
      source,
      width: source.width >= source.height ? 128 : null,
      height: source.width < source.height ? 128 : null,
      interpolation: image.Interpolation.average,
    );
    final png = image.encodePng(result);
    final icon = '$customIconPrefix${base64Encode(png)}';
    validateIcon(icon);
    return icon;
  } catch (_) {
    throw const FormatException('Invalid or unsupported image.');
  }
}

void _validateSvg(Uint8List bytes) {
  if (bytes.length > 65536) throw const FormatException();
  final document = xml.XmlDocument.parse(utf8.decode(bytes));
  if (document.children.any(
        (node) => node is! xml.XmlElement && node is! xml.XmlText,
      ) ||
      document.rootElement.name.qualified != 'svg') {
    throw const FormatException();
  }
  const elements = {
    'svg',
    'g',
    'path',
    'circle',
    'rect',
    'ellipse',
    'line',
    'polyline',
    'polygon',
  };
  const numbers = {
    'viewBox',
    'x',
    'y',
    'x1',
    'x2',
    'y1',
    'y2',
    'width',
    'height',
    'cx',
    'cy',
    'r',
    'rx',
    'ry',
    'stroke-width',
    'opacity',
    'fill-opacity',
    'stroke-opacity',
    'points',
  };
  final numberPattern = RegExp(r'^[0-9eE+.,% -]+$');
  final pathPattern = RegExp(r'^[MmZzLlHhVvCcSsQqTtAa0-9eE+., -]+$');
  final colorPattern = RegExp(r'^(none|#[0-9a-fA-F]{3,8})$');
  var count = 0;
  for (final node in document.descendants) {
    if (node is xml.XmlText) {
      if (node.value.trim().isNotEmpty) throw const FormatException();
    } else if (node is xml.XmlElement) {
      if (++count > 256 || !elements.contains(node.name.qualified)) {
        throw const FormatException();
      }
      for (final attr in node.attributes) {
        final name = attr.name.qualified, value = attr.value.trim();
        if (name == 'xmlns' &&
            node == document.rootElement &&
            value == 'http://www.w3.org/2000/svg') {
          continue;
        }
        if (numbers.contains(name) && numberPattern.hasMatch(value)) continue;
        if (name == 'd' &&
            value.length <= 32768 &&
            pathPattern.hasMatch(value)) {
          continue;
        }
        if ((name == 'fill' || name == 'stroke') &&
            colorPattern.hasMatch(value)) {
          continue;
        }
        if (name == 'style' &&
            RegExp(r'^fill:\s*(none|#[0-9a-fA-F]{3,8});?$').hasMatch(value)) {
          continue;
        }
        throw const FormatException();
      }
    } else if (node is! xml.XmlAttribute) {
      throw const FormatException();
    }
  }
}

String makeImportedIcon(Uint8List bytes) {
  if (bytes.length <= 65536) {
    try {
      _validateSvg(bytes);
      final value = '$customSvgPrefix${base64Encode(bytes)}';
      validateIcon(value);
      return value;
    } catch (_) {
      // Attempt a supported raster image below.
    }
  }
  return makeCustomIcon(bytes);
}
