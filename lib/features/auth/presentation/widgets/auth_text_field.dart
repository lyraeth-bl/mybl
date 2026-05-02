// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A custom text field component designed for the authentication flow.
///
/// This widget wraps a [TextFormField] and provides animated background color
/// transitions based on its focus, error, or value state. It is primarily used
/// to capture user input such as emails and passwords in the login screen.
class AuthTextField extends StatefulWidget {
  /// Creates an [AuthTextField] with the given configuration.
  const AuthTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.isPassword = false,
    this.contentPadding,
    this.errorText,
    this.onChanged,
  });

  /// The controller that manages the text being edited.
  final TextEditingController textEditingController;

  /// Whether to hide the text being entered.
  final bool isPassword;

  /// The padding around the input field's content.
  final EdgeInsetsGeometry? contentPadding;

  /// The text displayed as a suggestion in the field.
  final String hintText;

  /// The error message to display below the field.
  final String? errorText;

  /// Called when the text in the field changes.
  final VoidCallback? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _hasValue = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged?.call();

    final hasValue = widget.textEditingController.text.isNotEmpty;
    if (hasValue != _hasValue) {
      setState(() => _hasValue = hasValue);
    }
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasError = widget.errorText != null;

    final color = hasError
        ? Theme.of(context).colorScheme.errorContainer
        : _hasValue
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surfaceContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color,
            border: hasError ? Border.all(color: colorScheme.error) : null,
          ),
          child: TextFormField(
            controller: widget.textEditingController,
            obscureText: _obscureText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: widget.contentPadding ?? const EdgeInsets.all(16),
              hintText: widget.hintText,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
