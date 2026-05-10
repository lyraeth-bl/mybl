import 'package:flutter/material.dart';

import '../constants/constant.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.enableShadow = true,
    this.alignment,
    this.width,
    this.height,
    this.border,
    this.shadowsOffset,
    this.shadowColor,
  });

  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool enableShadow;
  final AlignmentGeometry? alignment;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final Offset? shadowsOffset;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final defaultBgColor = backgroundColor ?? colorScheme.surface;

    final defaultShadowColor =
        shadowColor ?? colorScheme.surfaceContainerHighest;

    return Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: defaultBgColor,
        borderRadius: borderRadius ?? customRadius,
        boxShadow: enableShadow == false
            ? null
            : [
                BoxShadow(
                  color: defaultShadowColor,
                  offset: shadowsOffset ?? const Offset(4, 4),
                ),
              ],

        border: border,
      ),
      child: child,
    );
  }
}
