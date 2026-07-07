// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

extension ShimmerFormatting on Widget {
  Widget toShimmer(
    BuildContext context, {
    bool isLoading = true,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isLoading) return this;

    Widget child = this;

    if (width != null || height != null) {
      child = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: borderRadius,
        ),
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius, child: child);
    }

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: child,
    );
  }
}

enum AnimationType {
  fadeSlideUp,
  fadeSlideDown,
  fadeSlideLeft,
  fadeSlideRight,
  fadeOnly,
  scaleIn,
}

extension AnimateWidgetExtension on Widget {
  Widget makeAnimate({
    AnimationType type = AnimationType.fadeSlideUp,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
  }) {
    final animated = animate(
      delay: delay,
    ).fadeIn(duration: duration, curve: curve);

    switch (type) {
      case AnimationType.fadeSlideUp:
        return animated.slideY(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeSlideDown:
        return animated.slideY(
          begin: -0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeSlideLeft:
        return animated.slideX(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeSlideRight:
        return animated.slideX(
          begin: -0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeOnly:
        return animated;
      case AnimationType.scaleIn:
        return animated.scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: duration,
          curve: curve,
        );
    }
  }
}

extension AnimateListExtension on List<Widget> {
  List<Widget> makeListAnimate({
    AnimationType type = AnimationType.fadeSlideUp,
    Duration interval = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
  }) {
    if (isEmpty) return this;
    final animated = animate(
      interval: interval,
    ).fadeIn(duration: duration, curve: curve);

    switch (type) {
      case AnimationType.fadeSlideUp:
        return animated.slideY(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeSlideDown:
        return animated.slideY(
          begin: -0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeSlideLeft:
        return animated.slideX(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeSlideRight:
        return animated.slideX(
          begin: -0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
      case AnimationType.fadeOnly:
        return animated;
      case AnimationType.scaleIn:
        return animated.scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: duration,
          curve: curve,
        );
    }
  }
}

extension GoogleListShape on int {
  ShapeBorder makeVerticalGoogleShape(int lastIndex) {
    if (this == 0) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
          bottom: Radius.circular(4),
        ),
      );
    } else if (this == lastIndex) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(4),
          bottom: Radius.circular(24),
        ),
      );
    }

    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
  }

  ShapeBorder makeHorizontalGoogleShape(int lastIndex) {
    if (this == 0) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      );
    } else if (this == lastIndex) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
      );
    }

    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
  }
}

extension DateAndTimeFormatterExtension on DateTime {
  String toHourMinuteFormat() => DateFormat("HH:mm").format(toLocal());

  String toHourMinuteSecondFormat() => DateFormat("HH:mm:ss").format(toLocal());

  String toDayMonthYearFormat(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM yyyy', locale).format(toLocal());
  }

  String toDayDateMonthYearFormat(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat("EEEE, d MMMM yyyy", locale).format(toLocal());
  }
}

extension StringExtension on String {
  String get capitalize => isEmpty
      ? this
      : "${this[0].toUpperCase()}${substring(1).toLowerCase()}";

  String get capitalizeEveryWord =>
      split(' ').map((word) => word.capitalize).join(' ');

  String get takeFirstWordAndCapitalize => split(' ').first.capitalize;
}

extension SpaceExtension on num {
  SizedBox get h => SizedBox(height: toDouble());

  SizedBox get w => SizedBox(width: toDouble());
}

extension SpacingExtension on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    if (length < 2) return this;
    final spaced = <Widget>[];
    for (var i = 0; i < length; i++) {
      spaced.add(this[i]);
      if (i != length - 1) spaced.add(separator);
    }
    return spaced;
  }
}

extension MediaQueryExtension on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);
}
