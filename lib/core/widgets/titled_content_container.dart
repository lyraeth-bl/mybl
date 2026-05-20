// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'custom_container.dart';

class TitledContentContainer extends StatelessWidget {
  const TitledContentContainer({
    super.key,
    required this.title,
    required this.child,
    this.titleIcon,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.titlePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.contentPadding = EdgeInsets.zero,
    this.backgroundColor,
    this.contentColor,
    this.titleStyle,
    this.contentBorderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(32),
      topLeft: Radius.circular(24),
    ),
  });

  final String title;
  final Widget child;
  final Widget? titleIcon;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final Color? backgroundColor;
  final Color? contentColor;
  final TextStyle? titleStyle;
  final BorderRadiusGeometry contentBorderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolvedTitleStyle =
        titleStyle ??
        textTheme.titleMedium!.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        );

    return CustomContainer(
      backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: titlePadding,
            child: titleIcon == null
                ? Text(title, style: resolvedTitleStyle)
                : Row(
                    children: [
                      IconTheme.merge(
                        data: IconThemeData(
                          color: resolvedTitleStyle.color,
                          size: 22,
                        ),
                        child: titleIcon!,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(title, style: resolvedTitleStyle)),
                    ],
                  ),
          ),
          Container(
            margin: EdgeInsets.zero,
            padding: contentPadding,
            decoration: BoxDecoration(
              color: contentColor ?? colorScheme.surfaceContainerLowest,
              borderRadius: contentBorderRadius,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
