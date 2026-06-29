// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

enum _AppButtonVariant { filled, outlined }

/// A reusable Material 3 button with filled and outlined variants.
///
/// Use [AppButton] for primary actions and [AppButton.outlined] for secondary
/// actions. Both share consistent sizing, shape, and progress feedback.
@immutable
class AppButton extends StatelessWidget {
  /// Creates an app-styled primary filled button.
  const AppButton({
    super.key,
    required this.child,
    this.loading = false,
    this.loadingChild,
    this.style,
    this.padding,
    this.minimumSize,
    this.fixedSize,
    this.maximumSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.side,
    this.textStyle,
    this.visualDensity,
    this.tapTargetSize,
    this.animationDuration,
    this.clipBehavior = Clip.none,
    this.autofocus = false,
    this.focusNode,
    this.progressIndicatorSize = 20,
    this.progressIndicatorStrokeWidth = 2,
    this.onPressed,
    this.onLongPress,
  }) : _variant = _AppButtonVariant.filled,
       assert(
         progressIndicatorSize > 0,
         'progressIndicatorSize must be greater than zero.',
       ),
       assert(
         progressIndicatorStrokeWidth > 0,
         'progressIndicatorStrokeWidth must be greater than zero.',
       );

  /// Creates an app-styled secondary outlined button.
  const AppButton.outlined({
    super.key,
    required this.child,
    this.loading = false,
    this.loadingChild,
    this.style,
    this.padding,
    this.minimumSize,
    this.fixedSize,
    this.maximumSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.side,
    this.textStyle,
    this.visualDensity,
    this.tapTargetSize,
    this.animationDuration,
    this.clipBehavior = Clip.none,
    this.autofocus = false,
    this.focusNode,
    this.progressIndicatorSize = 20,
    this.progressIndicatorStrokeWidth = 2,
    this.onPressed,
    this.onLongPress,
  }) : _variant = _AppButtonVariant.outlined,
       assert(
         progressIndicatorSize > 0,
         'progressIndicatorSize must be greater than zero.',
       ),
       assert(
         progressIndicatorStrokeWidth > 0,
         'progressIndicatorStrokeWidth must be greater than zero.',
       );

  final _AppButtonVariant _variant;

  /// The widget below this button in the tree.
  final Widget child;

  /// Whether the button displays progress feedback and disables interactions.
  final bool loading;

  /// The widget displayed while [loading] is true.
  ///
  /// Defaults to a compact [CircularProgressIndicator].
  final Widget? loadingChild;

  /// The complete style override for this button.
  final ButtonStyle? style;

  /// The internal padding for the button's content.
  final EdgeInsetsGeometry? padding;

  /// The minimum size of the button.
  ///
  /// Defaults to a full-width button with Material's recommended interactive
  /// height.
  final Size? minimumSize;

  /// The fixed size of the button.
  final Size? fixedSize;

  /// The maximum size of the button.
  final Size? maximumSize;

  /// The radius of the button's rounded corners.
  ///
  /// Defaults to the app's rounded primary button shape.
  final BorderRadiusGeometry? borderRadius;

  /// The button's background color when enabled.
  ///
  /// Defaults to [ColorScheme.primary].
  final Color? backgroundColor;

  /// The button's foreground color when enabled.
  ///
  /// Defaults to [ColorScheme.onPrimary].
  final Color? foregroundColor;

  /// The button's background color when disabled.
  final Color? disabledBackgroundColor;

  /// The button's foreground color when disabled.
  final Color? disabledForegroundColor;

  /// The z-coordinate at which to place this button.
  final double? elevation;

  /// The color used to paint the button's shadow.
  final Color? shadowColor;

  /// The color used as an overlay on [backgroundColor] to indicate elevation.
  final Color? surfaceTintColor;

  /// The border side of the button.
  final BorderSide? side;

  /// The text style used by descendants of this button.
  final TextStyle? textStyle;

  /// Defines how compact the button's layout will be.
  final VisualDensity? visualDensity;

  /// Configures the minimum size of the tap target.
  final MaterialTapTargetSize? tapTargetSize;

  /// The duration of animated changes for shape and color.
  final Duration? animationDuration;

  /// The content clipping behavior.
  final Clip clipBehavior;

  /// Whether this button should focus itself when first built.
  final bool autofocus;

  /// An optional focus node to use as the focus node for this button.
  final FocusNode? focusNode;

  /// The square size of the default progress indicator.
  final double progressIndicatorSize;

  /// The stroke width of the default progress indicator.
  final double progressIndicatorStrokeWidth;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final OutlinedBorder shape = borderRadius == null
        ? _defaultShape
        : RoundedRectangleBorder(borderRadius: borderRadius!);
    final Widget effectiveChild = loading
        ? loadingChild ?? _buildProgressIndicator(context)
        : child;

    return switch (_variant) {
      _AppButtonVariant.filled => FilledButton(
        onPressed: loading ? null : onPressed,
        onLongPress: loading ? null : onLongPress,
        style:
            style ??
            FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              disabledBackgroundColor: disabledBackgroundColor,
              disabledForegroundColor: disabledForegroundColor,
              elevation: elevation,
              shadowColor: shadowColor,
              surfaceTintColor: surfaceTintColor,
              side: side,
              textStyle: textStyle,
              padding: padding,
              minimumSize: minimumSize ?? _defaultMinimumSize,
              fixedSize: fixedSize,
              maximumSize: maximumSize,
              shape: shape,
              visualDensity: visualDensity,
              tapTargetSize: tapTargetSize,
              animationDuration: animationDuration,
            ),
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        child: effectiveChild,
      ),
      _AppButtonVariant.outlined => OutlinedButton(
        onPressed: loading ? null : onPressed,
        onLongPress: loading ? null : onLongPress,
        style:
            style ??
            OutlinedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              disabledBackgroundColor: disabledBackgroundColor,
              disabledForegroundColor: disabledForegroundColor,
              elevation: elevation,
              shadowColor: shadowColor,
              surfaceTintColor: surfaceTintColor,
              side: side,
              textStyle: textStyle,
              padding: padding,
              minimumSize: minimumSize ?? _defaultMinimumSize,
              fixedSize: fixedSize,
              maximumSize: maximumSize,
              shape: shape,
              visualDensity: visualDensity,
              tapTargetSize: tapTargetSize,
              animationDuration: animationDuration,
            ),
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        child: effectiveChild,
      ),
    };
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: progressIndicatorSize,
      child: CircularProgressIndicator(
        color: foregroundColor ?? colorScheme.onSurface,
        strokeWidth: progressIndicatorStrokeWidth,
        // ignore: deprecated_member_use
        year2023: false,
      ),
    );
  }

  static const Size _defaultMinimumSize = Size.fromHeight(48);

  static const OutlinedBorder _defaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
}
