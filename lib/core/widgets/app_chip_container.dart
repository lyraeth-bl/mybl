import 'package:flutter/material.dart';

/// A compact Material 3 chip-like container for short labels or custom content.
///
/// Use [AppChipContainer] when a lightweight, rounded label is needed without the
/// selection, deletion, or filtering behavior provided by Flutter's built-in
/// chip widgets.
@immutable
class AppChipContainer extends StatelessWidget {
  /// Creates a compact chip-like container.
  ///
  /// Exactly one of [value] and [child] must be provided.
  const AppChipContainer({
    super.key,
    this.value,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.margin,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.shape,
    this.borderRadius,
    this.side,
    this.elevation = 0,
    this.shadowColor,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.constraints,
    this.onTap,
  }) : assert(
         value != null || child != null,
         'Either value or child must be provided.',
       ),
       assert(
         value == null || child == null,
         'Only one of value and child may be provided.',
       ),
       assert(
         shape == null || borderRadius == null,
         'Only one of shape and borderRadius may be provided.',
       ),
       assert(elevation >= 0, 'Elevation must be greater than or equal to 0.'),
       _outlined = false;

  /// Creates an outlined variant of the chip: transparent fill, bordered.
  ///
  /// Defaults [foregroundColor] to [ColorScheme.onSurface] and [side] to a
  /// 1-width border in [ColorScheme.outline] when not overridden.
  const AppChipContainer.outlined({
    super.key,
    this.value,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.margin,
    this.foregroundColor,
    this.textStyle,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.borderRadius,
    this.side,
    this.constraints,
    this.onTap,
  }) : assert(
         value != null || child != null,
         'Either value or child must be provided.',
       ),
       assert(
         value == null || child == null,
         'Only one of value and child may be provided.',
       ),
       backgroundColor = Colors.transparent,
       shape = null,
       elevation = 0,
       shadowColor = null,
       surfaceTintColor = null,
       clipBehavior = Clip.none,
       _outlined = true;

  /// Whether this chip was created via [AppChipContainer.outlined].
  final bool _outlined;

  /// The text displayed by the chip.
  ///
  /// Provide either [value] or [child], but not both.
  final String? value;

  /// The custom content displayed by the chip.
  ///
  /// Provide either [child] or [value], but not both.
  final Widget? child;

  /// The amount of space to inset the chip's content.
  final EdgeInsetsGeometry padding;

  /// The empty space that surrounds the chip.
  final EdgeInsetsGeometry? margin;

  /// The color used to fill the chip.
  ///
  /// Defaults to [ColorScheme.primaryContainer].
  final Color? backgroundColor;

  /// The default color for text and icons inside the chip.
  ///
  /// Defaults to [ColorScheme.onPrimaryContainer].
  final Color? foregroundColor;

  /// The style used for [value].
  ///
  /// Defaults to [TextTheme.labelSmall] with a semibold weight.
  final TextStyle? textStyle;

  /// How the text in [value] should be aligned horizontally.
  final TextAlign? textAlign;

  /// An optional maximum number of lines for [value].
  final int? maxLines;

  /// How visual overflow for [value] should be handled.
  final TextOverflow? overflow;

  /// The shape of the chip's material.
  ///
  /// If null, a [RoundedRectangleBorder] using [borderRadius] and [side] is
  /// used.
  final ShapeBorder? shape;

  /// The radius of the chip's rounded corners.
  ///
  /// Defaults to a stadium-like radius.
  final BorderRadiusGeometry? borderRadius;

  /// The color and weight of the chip's outline.
  final BorderSide? side;

  /// The z-coordinate at which to place this chip relative to its parent.
  final double elevation;

  /// The color used to paint the shadow below the chip.
  final Color? shadowColor;

  /// The color used as an overlay on [backgroundColor] to indicate elevation.
  final Color? surfaceTintColor;

  /// The content clipping behavior for the chip's material.
  final Clip clipBehavior;

  /// Additional constraints to apply to the chip.
  final BoxConstraints? constraints;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveForegroundColor =
        foregroundColor ??
        (_outlined ? colorScheme.onSurface : colorScheme.onPrimaryContainer);
    final effectiveTextStyle = (textStyle ?? theme.textTheme.labelSmall)
        ?.copyWith(
          color: effectiveForegroundColor,
          fontWeight: FontWeight.w600,
        );
    final effectiveSide =
        side ??
        (_outlined ? BorderSide(color: colorScheme.outline) : BorderSide.none);
    final effectiveShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(999),
          side: effectiveSide,
        );

    Widget current = IconTheme.merge(
      data: IconThemeData(color: effectiveForegroundColor),
      child: DefaultTextStyle.merge(
        style: effectiveTextStyle,
        child:
            child ??
            Text(
              value!,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            ),
      ),
    );

    current = Padding(padding: padding, child: current);

    if (constraints != null) {
      current = ConstrainedBox(constraints: constraints!, child: current);
    }

    current = Material(
      color: backgroundColor ?? colorScheme.primaryContainer,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: effectiveShape,
      clipBehavior: clipBehavior,
      child: onTap == null
          ? current
          : InkWell(customBorder: effectiveShape, onTap: onTap, child: current),
    );

    if (margin != null) {
      current = Padding(padding: margin!, child: current);
    }

    return current;
  }
}
