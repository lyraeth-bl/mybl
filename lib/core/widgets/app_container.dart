// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app_button.dart';

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
    this.boxShadow,
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

  /// The directional shadow painted behind the card.
  ///
  /// Use this when the card needs a sharper [Container]-style shadow. The
  /// [elevation] shadow remains available for Material-style depth.
  final List<BoxShadow>? boxShadow;

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

    if (boxShadow != null) {
      result = DecoratedBox(
        decoration: ShapeDecoration(shape: effectiveShape, shadows: boxShadow),
        child: result,
      );
    }

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}

/// A bordered [AppContainer] whose body holds an inset, separately-rounded
/// panel — a card-within-a-card.
///
/// Use [AppFramedContainer] for dashboard sections that need a header row plus
/// a distinct inner surface (e.g. an icon/title/CTA block). The inner panel's
/// corners are controlled independently via [innerBorderRadius].
@immutable
class AppFramedContainer extends StatelessWidget {
  /// Creates a framed dashboard card.
  ///
  /// The header is shown when either [title] or [trailing] is provided.
  const AppFramedContainer({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.margin = const EdgeInsets.all(16),
    this.gap = const EdgeInsets.all(12),
    this.innerPadding = const EdgeInsets.all(24),
    this.titlePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.backgroundColor,
    this.innerColor,
    this.headerColor,
    this.foregroundColor,
    this.titleTextStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.innerBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderColor,
    this.innerBorderColor,
    this.elevation = 0,
    this.onTap,
  });

  /// The content displayed inside the inner panel.
  final Widget child;

  /// The widget displayed at the start of the optional header.
  final Widget? title;

  /// The widget displayed at the end of the optional header.
  final Widget? trailing;

  /// The empty space that surrounds the card.
  final EdgeInsetsGeometry? margin;

  /// The space between the card edge and the inner panel.
  final EdgeInsetsGeometry gap;

  /// The padding inside the inner panel, around [child].
  final EdgeInsetsGeometry innerPadding;

  /// The padding around the optional header row.
  final EdgeInsetsGeometry titlePadding;

  /// The background color behind the inner panel.
  ///
  /// Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// The background color of the inner panel.
  ///
  /// Defaults to [ColorScheme.surface].
  final Color? innerColor;

  /// The background color of the optional header.
  ///
  /// Defaults to [ColorScheme.surfaceContainerLow].
  final Color? headerColor;

  /// The default color for text and icons in the optional header.
  ///
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? foregroundColor;

  /// The default text style applied to [title].
  final TextStyle? titleTextStyle;

  /// The border radius of the outer card.
  final BorderRadiusGeometry borderRadius;

  /// The border radius of the inner panel.
  final BorderRadiusGeometry innerBorderRadius;

  /// The color of the outer card border.
  ///
  /// Defaults to [ColorScheme.outlineVariant].
  final Color? borderColor;

  /// The color of the inner panel border.
  ///
  /// Defaults to [ColorScheme.outlineVariant].
  final Color? innerBorderColor;

  /// The z-coordinate at which to place the outer card.
  final double elevation;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: margin,
      padding: gap,
      titlePadding: titlePadding,
      title: title,
      trailing: trailing,
      titleTextStyle: titleTextStyle,
      headerColor: headerColor ?? colorScheme.surfaceContainer,
      foregroundColor: foregroundColor ?? colorScheme.onSurfaceVariant,
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
      elevation: elevation,
      borderRadius: null,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor ?? colorScheme.outlineVariant),
      ),
      onTap: onTap,
      child: Container(
        padding: innerPadding,
        decoration: BoxDecoration(
          color: innerColor ?? colorScheme.surface,
          borderRadius: innerBorderRadius,
          border: Border.all(
            color: innerBorderColor ?? colorScheme.outlineVariant,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A centered empty-state placeholder for a card body with no data.
///
/// Use [AppNoData] inside an [AppContainer] or [AppFramedContainer] body to
/// communicate an empty state: an [icon], a bold [title], an optional
/// supporting [message], and an optional call-to-action button.
@immutable
class AppNoData extends StatelessWidget {
  /// Creates an empty-state placeholder.
  ///
  /// The action button is shown only when both [actionLabel] and [onAction]
  /// are provided.
  const AppNoData({
    super.key,
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.message,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.iconSize = 32,
  });

  /// The bold headline describing the empty state.
  final String title;

  /// The icon displayed above the [title].
  final IconData icon;

  /// The optional supporting text shown below the [title].
  final String? message;

  /// The optional label for the call-to-action button.
  final String? actionLabel;

  /// Called when the call-to-action button is tapped.
  final VoidCallback? onAction;

  /// The padding around the content.
  final EdgeInsetsGeometry padding;

  /// The size of the [icon].
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasAction = actionLabel != null && onAction != null;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: iconSize, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (hasAction) ...<Widget>[
            const SizedBox(height: 20),
            AppButton.outlined(
              onPressed: onAction,
              minimumSize: const Size(0, 40),
              side: BorderSide(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
              child: Text(
                actionLabel!,
                style: textTheme.titleSmall!.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
