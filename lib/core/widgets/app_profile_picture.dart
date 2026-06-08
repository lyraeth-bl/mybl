// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A circular profile image with a themed fallback.
///
/// Use [AppProfilePicture] for user avatars that may be backed by a network image
/// and need a consistent Material-styled fallback when the image is unavailable.
@immutable
class AppProfilePicture extends StatelessWidget {
  /// Creates a circular profile picture.
  ///
  /// The fallback is resolved in this order: [child], [initials], then [icon].
  const AppProfilePicture({
    super.key,
    this.imageUrl,
    this.initials,
    this.child,
    this.icon = Icons.person_outline,
    this.radius = 28,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.side = BorderSide.none,
    this.clipBehavior = Clip.antiAlias,
    this.fit = BoxFit.cover,
  }) : assert(
         child == null || initials == null,
         'Only one of child or initials can be provided.',
       ),
       assert(radius > 0, 'radius must be greater than zero.');

  /// The URL of the image to display.
  ///
  /// When null or empty, the widget displays its fallback content.
  final String? imageUrl;

  /// Text displayed when [imageUrl] is null, empty, or fails to load.
  ///
  /// Usually this should be one or two user initials. Ignored when [child] is
  /// provided.
  final String? initials;

  /// Custom fallback content displayed when [imageUrl] is null, empty, or fails
  /// to load.
  ///
  /// When provided, [initials] must be null.
  final Widget? child;

  /// Icon displayed when [imageUrl], [child], and [initials] are all absent.
  final IconData icon;

  /// The radius of the circular avatar.
  final double radius;

  /// The color used behind the image or fallback content.
  ///
  /// Defaults to [ColorScheme.surfaceContainer].
  final Color? backgroundColor;

  /// The color used by the fallback text or icon.
  ///
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? foregroundColor;

  /// The text style used for [initials].
  ///
  /// Defaults to [TextTheme.titleMedium] with a bold weight.
  final TextStyle? textStyle;

  /// The border drawn around the circular avatar.
  final BorderSide side;

  /// How to clip the network image to the circular shape.
  final Clip clipBehavior;

  /// How the network image should be inscribed into the avatar.
  final BoxFit fit;

  /// Returns the first visible character from [value].
  ///
  /// Returns null when [value] is null or contains only whitespace.
  static String? initialFrom(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.primaryContainer;
    final effectiveForegroundColor =
        foregroundColor ?? colorScheme.onPrimaryContainer;

    return Container(
      foregroundDecoration: ShapeDecoration(shape: CircleBorder(side: side)),
      child: CircleAvatar(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        radius: radius,
        child: _hasImage
            ? ClipOval(
                clipBehavior: clipBehavior,
                child: CachedNetworkImage(
                  width: radius * 2,
                  height: radius * 2,
                  fit: fit,
                  imageUrl: imageUrl!.trim(),
                  errorWidget: (context, url, error) => _buildFallback(context),
                ),
              )
            : _buildFallback(context),
      ),
    );
  }

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveForegroundColor =
        foregroundColor ?? colorScheme.onSurfaceVariant;

    if (child != null) {
      return IconTheme.merge(
        data: IconThemeData(color: effectiveForegroundColor),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: effectiveForegroundColor),
          child: child!,
        ),
      );
    }

    final effectiveInitials = initials?.trim();
    if (effectiveInitials != null && effectiveInitials.isNotEmpty) {
      return Text(
        effectiveInitials.characters.first.toUpperCase(),
        style:
            textStyle ??
            theme.textTheme.titleMedium?.copyWith(
              color: effectiveForegroundColor,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    return Icon(icon, color: effectiveForegroundColor);
  }
}
