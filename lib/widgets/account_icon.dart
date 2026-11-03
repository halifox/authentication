import 'dart:convert';

import 'package:authentication/storage/icon_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountIcon extends StatelessWidget {
  const AccountIcon({required this.icon, super.key, this.size = 28});
  final String icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isCustomIcon(icon)) {
      try {
        final svg = icon.startsWith(customSvgPrefix);
        final bytes = base64Decode(
          icon.substring(
            svg ? customSvgPrefix.length : customIconPrefix.length,
          ),
        );
        if (svg) {
          return SvgPicture.string(
            utf8.decode(bytes),
            width: size,
            height: size,
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          ),
        );
      } catch (_) {
        return const Icon(Icons.broken_image_outlined);
      }
    }
    return SvgPicture.asset(
      icon,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.onPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
