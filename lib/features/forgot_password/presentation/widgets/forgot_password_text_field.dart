// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_text_field.dart';

/// A labelled [AppTextField] styled like the sign-in form fields.
class ForgotPasswordTextField extends StatelessWidget {
  const ForgotPasswordTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurface),
        ),

        12.h,

        AppTextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            suffixIcon: suffixIcon,
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          backgroundColor: colorScheme.surface,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
          focusedSide: BorderSide(color: colorScheme.primary, width: 1.5),
          focusedBackgroundColor: colorScheme.surface,
          populatedBackgroundColor: colorScheme.surface,
        ),
      ],
    );
  }
}
