import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

const customIconPrefix = 'data:image/png;base64,';
const _maxIconBytes = 128 * 1024;
const _maxInputBytes = 10 * 1024 * 1024;

bool isCustomIcon(String value) => value.startsWith(customIconPrefix);

Uint8List validateIcon(String value) {
  if (!isCustomIcon(value)) {
    if (!RegExp(r'^assets/icons/[a-zA-Z0-9_-]+\.svg$').hasMatch(value)) {
      throw const FormatException('Invalid icon.');
    }
    return Uint8List(0);
  }
  final encoded = value.substring(customIconPrefix.length);
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
