// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A compact Material surface that displays an icon.
///
/// Use [AppIconContainer] for leading icons, status badges, and small action
/// affordances that need a consistent filled background. The widget sizes
/// itself to its icon and [padding], so it can be used in both bounded and
/// unbounded layouts.
@immutable
class AppIconContainer extends StatelessWidget {
  /// Creates a filled icon container.
  const AppIconContainer({
    super.key,
    required this.icon,
    this.margin,
    this.padding = const .all(8),
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize,
    this.semanticLabel,
    this.shape = const CircleBorder(),
    this.elevation = 0,
    this.shadowColor,
    this.surfaceTintColor,
    this.clipBehavior = .none,
    this.onTap,
  }) : assert(elevation >= 0, 'elevation must be non-negative.');

  /// The icon displayed inside the container.
  final IconData icon;

  /// The empty space that surrounds the container.
  final EdgeInsetsGeometry? margin;

  /// The empty space between the icon and the container edge.
  final EdgeInsetsGeometry padding;

  /// The fill color of the container.
  ///
  /// Defaults to [ColorScheme.primaryContainer].
  final Color? backgroundColor;

  /// The color used for the icon.
  ///
  /// Defaults to [ColorScheme.onPrimaryContainer].
  final Color? foregroundColor;

  /// The size of the icon.
  ///
  /// Defaults to the nearest [IconTheme] size.
  final double? iconSize;

  /// Text used by accessibility services to describe the icon.
  final String? semanticLabel;

  /// The shape of the container's Material.
  final ShapeBorder shape;

  /// The z-coordinate at which to place the container.
  final double elevation;

  /// The color used to paint the Material shadow.
  final Color? shadowColor;

  /// The Material surface tint color.
  final Color? surfaceTintColor;

  /// How the container clips its content.
  final Clip clipBehavior;

  /// Called when the container is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color effectiveBackgroundColor =
        backgroundColor ?? colorScheme.primaryContainer;
    final Color effectiveForegroundColor =
        foregroundColor ?? colorScheme.onPrimaryContainer;

    Widget result = Material(
      color: effectiveBackgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      clipBehavior: clipBehavior,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: padding,
          child: Icon(
            icon,
            size: iconSize,
            color: effectiveForegroundColor,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}
