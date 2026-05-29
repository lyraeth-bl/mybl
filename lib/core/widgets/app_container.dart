import 'package:flutter/material.dart';

/// A dashboard card with optional header content and Material interaction.
///
/// Use [AppContainer] for compact dashboard sections that need a
/// consistent container, optional title row, and an optional tap target.
@immutable
class AppContainer extends StatelessWidget {
  /// Creates a dashboard content card.
  ///
  /// The header is shown when either [title] or [trailing] is provided.
  const AppContainer({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(16),
    this.titlePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.backgroundColor,
    this.headerColor,
    this.foregroundColor,
    this.titleTextStyle,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation = 1,
    this.shape,
    this.borderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(32),
      topLeft: Radius.circular(32),
      topRight: Radius.circular(16),
    ),
    this.clipBehavior = Clip.antiAlias,
    this.aspectRatio,
    this.onTap,
  }) : assert(
         title != null || trailing == null,
         'title must be provided when trailing is provided.',
       ),
       assert(elevation >= 0, 'elevation must be non-negative.'),
       assert(
         aspectRatio == null || aspectRatio > 0,
         'aspectRatio must be greater than zero.',
       ),
       assert(
         shape == null || borderRadius == null,
         'Only one of shape or borderRadius can be provided.',
       );

  /// The primary content displayed in the card body.
  final Widget child;

  /// The widget displayed at the start of the optional header.
  final Widget? title;

  /// The widget displayed at the end of the optional header.
  final Widget? trailing;

  /// The empty space that surrounds the card.
  final EdgeInsetsGeometry? margin;

  /// The padding around [child].
  final EdgeInsetsGeometry padding;

  /// The padding around the optional header row.
  final EdgeInsetsGeometry titlePadding;

  /// The background color of the card body.
  ///
  /// Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// The background color of the optional header.
  ///
  /// Defaults to [ColorScheme.primaryContainer].
  final Color? headerColor;

  /// The default color for text and icons in the optional header.
  ///
  /// Defaults to [ColorScheme.onPrimaryContainer].
  final Color? foregroundColor;

  /// The default text style applied to [title].
  ///
  /// Defaults to [TextTheme.titleSmall].
  final TextStyle? titleTextStyle;

  /// The color used to paint the card shadow.
  final Color? shadowColor;

  /// The Material surface tint color for the card.
  final Color? surfaceTintColor;

  /// The z-coordinate at which to place this card.
  final double elevation;

  /// The shape of the card's [Material].
  ///
  /// If this is provided, [borderRadius] must be null.
  final ShapeBorder? shape;

  /// The border radius used when [shape] is null.
  final BorderRadiusGeometry? borderRadius;

  /// The content clipping behavior.
  final Clip clipBehavior;

  /// The width-to-height ratio for the whole card.
  ///
  /// When null, the card sizes itself to its content.
  final double? aspectRatio;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final TextDirection textDirection = Directionality.of(context);
    final ShapeBorder effectiveShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: borderRadius!.resolve(textDirection),
        );
    final Color effectiveForegroundColor =
        foregroundColor ?? colorScheme.onPrimaryContainer;
    final TextStyle effectiveTitleTextStyle =
        titleTextStyle ??
        textTheme.titleSmall?.copyWith(
          color: effectiveForegroundColor,
          fontWeight: FontWeight.w700,
        ) ??
        TextStyle(color: effectiveForegroundColor, fontWeight: FontWeight.w700);
    final bool hasHeader = title != null || trailing != null;

    Widget result = Material(
      color: hasHeader
          ? headerColor ?? colorScheme.primaryContainer
          : backgroundColor ?? colorScheme.surface,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      shape: effectiveShape,
      clipBehavior: clipBehavior,
      child: InkWell(
        onTap: onTap,
        customBorder: effectiveShape,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (hasHeader)
              IconTheme.merge(
                data: IconThemeData(color: effectiveForegroundColor),
                child: DefaultTextStyle.merge(
                  style: effectiveTitleTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Padding(
                    padding: titlePadding,
                    child: Row(
                      children: <Widget>[
                        if (title != null) Expanded(child: title!),
                        if (trailing != null) ...<Widget>[
                          if (title != null) const SizedBox(width: 12),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            if (aspectRatio == null)
              ColoredBox(
                color: backgroundColor ?? colorScheme.surface,
                child: Padding(padding: padding, child: child),
              )
            else
              Expanded(
                child: ColoredBox(
                  color: backgroundColor ?? colorScheme.surface,
                  child: Padding(padding: padding, child: child),
                ),
              ),
          ],
        ),
      ),
    );

    if (aspectRatio != null) {
      result = AspectRatio(aspectRatio: aspectRatio!, child: result);
    }

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}
