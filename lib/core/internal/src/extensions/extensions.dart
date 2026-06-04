// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

/// Extension buat bikin widget lo jadi berkilau (shimmer) pas lagi loading.
///
/// Tinggal panggil [toShimmer] di widget mana aja, nanti dia bakal otomatis
/// ngebungkus widget itu pake [Shimmer.fromColors]. Lo bisa custom lebar, tinggi,
/// sampe radius pojokannya biar pas ama bentuk asli widget-nya.
extension ShimmerFormatting on Widget {
  Widget toShimmer(
    BuildContext context, {
    bool isLoading = true,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    AlignmentGeometry? alignment,
  }) {
    if (!isLoading) return this;

    Widget shimmerChild = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: (width == null && height == null) ? this : null,
    );

    if (width != null || height != null) {
      shimmerChild = Align(
        alignment: alignment ?? Alignment.centerLeft,

        child: shimmerChild,
      );
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: shimmerChild,
    );
  }
}

/// Extension biar list widget lo nggak kaku-kaku amat.
///
/// Pake [makeListAnimate] biar list item lo muncul satu-satu pake animasi fade-in
/// dan slide-up yang smooth. Cocok banget dipake pas data baru beres di-fetch.
extension AnimateListExtension on List<Widget> {
  List<Widget> makeListAnimate() {
    if (isEmpty) return this;

    return animate(interval: 100.ms)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

/// Extension buat bikin shape ala-ala Google yang pojokannya beda-beda.
///
/// Biasanya dipake buat list item yang nempel-nempel. Yang paling atas (index 0)
/// bakal lebih bulet di atas, yang paling bawah bakal lebih bulet di bawah,
/// dan yang tengah bakal lebih kotak.
extension GoogleListShape on int {
  /// Bikin shape vertikal buat list. [lastIndex] itu index terakhir dari list-nya.
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

  /// Bikin shape horizontal buat list. [lastIndex] itu index terakhir dari list-nya.
  ShapeBorder makeHorizontalGoogleShape(int lastIndex) {
    if (this == 0) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(16),
        ),
      );
    } else if (this == lastIndex) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(32),
        ),
      );
    }

    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
  }
}

extension DateAndTimeFormatterExtension on DateTime {
  String get toHourMinuteFormat => DateFormat("HH : mm").format(toLocal());

  String get toHourMinuteSecondFormat =>
      DateFormat("HH : mm : ss").format(toLocal());

  String get toDayMonthYearFormat =>
      DateFormat('dd MMMM yyyy').format(toLocal());

  String get toDayDateMonthYearFormat =>
      DateFormat("EEEE, d MMMM yyyy").format(toLocal());
}

extension StringExtension on String {
  String get capitalize =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
