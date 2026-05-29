import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A Material-styled group for composing a section header with sliver content.
///
/// Use [AppSliverGroup] inside a [CustomScrollView] when a scrollable section needs
/// a consistent header and either a regular box [child] or a custom [sliver].
@immutable
class AppSliverGroup extends StatelessWidget {
  /// Creates a sliver group with a section title and one content widget.
  ///
  /// Exactly one of [child] and [sliver] must be provided.
  const AppSliverGroup({
    super.key,
    required this.title,
    this.child,
    this.sliver,
    this.action,
    this.headerPadding = const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
    this.contentPadding = EdgeInsets.zero,
    this.headerHeight = 56,
    this.headerAlignment = AlignmentDirectional.bottomStart,
    this.titleStyle,
    this.titleMaxLines = 1,
    this.titleOverflow = TextOverflow.ellipsis,
    this.backgroundColor,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.snapCurve = Curves.ease,
    this.snapDuration = const Duration(milliseconds: 300),
    this.titleOffset = 4,
    this.collapsedOpacity = 0.5,
    this.animationCurve = Curves.linear,
  }) : assert(
         child != null || sliver != null,
         'Either child or sliver must be provided.',
       ),
       assert(
         child == null || sliver == null,
         'Only one of child or sliver can be provided.',
       ),
       assert(headerHeight >= 0, 'headerHeight must be non-negative.'),
       assert(titleMaxLines > 0, 'titleMaxLines must be greater than zero.'),
       assert(titleOffset >= 0, 'titleOffset must be non-negative.'),
       assert(
         collapsedOpacity >= 0.0 && collapsedOpacity <= 1.0,
         'collapsedOpacity must be between 0.0 and 1.0.',
       ),
       assert(
         !snap || floating,
         'snap can only be true when floating is also true.',
       ),
       assert(
         snapDuration > Duration.zero,
         'snapDuration must be greater than Duration.zero.',
       );

  /// The text displayed in the section header.
  final String title;

  /// A box widget displayed below the header.
  ///
  /// This widget is wrapped in a [SliverToBoxAdapter]. Exactly one of [child]
  /// and [sliver] must be provided.
  final Widget? child;

  /// A sliver displayed below the header.
  ///
  /// Exactly one of [child] and [sliver] must be provided.
  final Widget? sliver;

  /// A trailing widget displayed at the end of the header.
  final Widget? action;

  /// The padding around the header content.
  final EdgeInsetsGeometry headerPadding;

  /// The padding around the content sliver.
  final EdgeInsetsGeometry contentPadding;

  /// The minimum and maximum extent of the header.
  final double headerHeight;

  /// How the header content is aligned within the header extent.
  final AlignmentGeometry headerAlignment;

  /// The text style for [title].
  ///
  /// Defaults to [TextTheme.titleMedium] with [ColorScheme.onSurface].
  final TextStyle? titleStyle;

  /// The maximum number of lines used by [title].
  final int titleMaxLines;

  /// How visual overflow from [title] is handled.
  final TextOverflow titleOverflow;

  /// The header background color.
  ///
  /// Defaults to transparent.
  final Color? backgroundColor;

  /// Whether the header sticks to the start of the viewport.
  final bool pinned;

  /// Whether the header can appear as soon as the user scrolls toward it.
  final bool floating;

  /// Whether a floating header should snap into view.
  ///
  /// This can only be true when [floating] is also true.
  final bool snap;

  /// The curve used when [snap] animates the header into or out of view.
  final Curve snapCurve;

  /// The duration used when [snap] animates the header into or out of view.
  final Duration snapDuration;

  /// The horizontal distance the title travels as the header collapses.
  final double titleOffset;

  /// The opacity used when the header is fully collapsed.
  final double collapsedOpacity;

  /// The curve used for the header title motion and opacity.
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    final Widget content = sliver ?? SliverToBoxAdapter(child: child);

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: pinned,
          floating: floating,
          delegate: _AppSliverGroupHeaderDelegate(
            title: title,
            action: action,
            padding: headerPadding,
            height: headerHeight,
            alignment: headerAlignment,
            titleStyle: titleStyle,
            titleMaxLines: titleMaxLines,
            titleOverflow: titleOverflow,
            backgroundColor: backgroundColor,
            snap: snap,
            snapCurve: snapCurve,
            snapDuration: snapDuration,
            titleOffset: titleOffset,
            collapsedOpacity: collapsedOpacity,
            animationCurve: animationCurve,
          ),
        ),
        SliverPadding(padding: contentPadding, sliver: content),
      ],
    );
  }
}

class _AppSliverGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _AppSliverGroupHeaderDelegate({
    required this.title,
    required this.padding,
    required this.height,
    required this.alignment,
    required this.titleMaxLines,
    required this.titleOverflow,
    required this.snap,
    required this.snapCurve,
    required this.snapDuration,
    required this.titleOffset,
    required this.collapsedOpacity,
    required this.animationCurve,
    this.action,
    this.titleStyle,
    this.backgroundColor,
  });

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final double height;
  final AlignmentGeometry alignment;
  final TextStyle? titleStyle;
  final int titleMaxLines;
  final TextOverflow titleOverflow;
  final Color? backgroundColor;
  final bool snap;
  final Curve snapCurve;
  final Duration snapDuration;
  final double titleOffset;
  final double collapsedOpacity;
  final Curve animationCurve;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final TextDirection textDirection = Directionality.of(context);
    final double progress = maxExtent == 0
        ? 1.0
        : (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final double curvedProgress = animationCurve.transform(progress);
    final double direction = textDirection == TextDirection.rtl ? -1.0 : 1.0;
    final double currentOffset = (1.0 - curvedProgress) * titleOffset;
    final double opacity = 1.0 + (collapsedOpacity - 1.0) * curvedProgress;
    final TextStyle effectiveTitleStyle =
        titleStyle ??
        textTheme.titleMedium?.copyWith(color: colorScheme.onSurface) ??
        TextStyle(color: colorScheme.onSurface);

    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Padding(
        padding: padding,
        child: Align(
          alignment: alignment,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(currentOffset * direction, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      maxLines: titleMaxLines,
                      overflow: titleOverflow,
                      style: effectiveTitleStyle,
                    ),
                  ),
                  if (action != null) ...<Widget>[
                    const SizedBox(width: 8),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration {
    if (!snap) {
      return null;
    }

    return FloatingHeaderSnapConfiguration(
      curve: snapCurve,
      duration: snapDuration,
    );
  }

  @override
  bool shouldRebuild(covariant _AppSliverGroupHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.action != action ||
        oldDelegate.padding != padding ||
        oldDelegate.height != height ||
        oldDelegate.alignment != alignment ||
        oldDelegate.titleStyle != titleStyle ||
        oldDelegate.titleMaxLines != titleMaxLines ||
        oldDelegate.titleOverflow != titleOverflow ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.snap != snap ||
        oldDelegate.snapCurve != snapCurve ||
        oldDelegate.snapDuration != snapDuration ||
        oldDelegate.titleOffset != titleOffset ||
        oldDelegate.collapsedOpacity != collapsedOpacity ||
        oldDelegate.animationCurve != animationCurve;
  }
}
