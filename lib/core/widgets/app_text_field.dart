// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable Material 3 text field with an animated app surface.
///
/// Use [AppTextField] for form inputs that should share the app's rounded,
/// filled surface treatment while keeping the behavior and API close to
/// Flutter's [TextFormField].
@immutable
class AppTextField extends StatefulWidget {
  /// Creates an app-styled text field.
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.inputFormatters,
    this.enabled,
    this.restorationId,
    this.autovalidateMode,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.margin,
    this.contentPadding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor,
    this.focusedBackgroundColor,
    this.populatedBackgroundColor,
    this.errorBackgroundColor,
    this.side,
    this.focusedSide,
    this.errorSide,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.linear,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.onTap,
  }) : assert(
         controller == null || initialValue == null,
         'controller and initialValue cannot both be provided.',
       ),
       assert(maxLines == null || maxLines > 0, 'maxLines must be positive.'),
       assert(minLines == null || minLines > 0, 'minLines must be positive.'),
       assert(
         minLines == null || maxLines == null || minLines <= maxLines,
         'minLines must be less than or equal to maxLines.',
       ),
       assert(
         !expands || (minLines == null && maxLines == null),
         'minLines and maxLines must be null when expands is true.',
       ),
       assert(
         !obscureText || maxLines == 1,
         'obscureText can only be used when maxLines is 1.',
       ),
       assert(
         maxLength == null || maxLength > 0,
         'maxLength must be greater than zero.',
       ),
       assert(
         animationDuration >= Duration.zero,
         'animationDuration must not be negative.',
       );

  /// Controls the text being edited.
  ///
  /// If null, [initialValue] may be used instead.
  final TextEditingController? controller;

  /// The initial text value when [controller] is null.
  final String? initialValue;

  /// Defines the keyboard focus for this field.
  final FocusNode? focusNode;

  /// The decoration to show around the editable text.
  ///
  /// The border defaults to [InputBorder.none] so the outer animated surface
  /// provides the visual container.
  final InputDecoration decoration;

  /// The keyboard type to use for editing the text.
  final TextInputType? keyboardType;

  /// The action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Configures how the platform keyboard selects an uppercase or lowercase
  /// keyboard.
  final TextCapitalization textCapitalization;

  /// The text style to use for the editable text.
  ///
  /// Defaults to [TextTheme.bodyMedium].
  final TextStyle? style;

  /// The strut style used by the editable text.
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// How the text should be aligned vertically.
  final TextAlignVertical? textAlignVertical;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Whether the text can be changed.
  final bool readOnly;

  /// Whether to show the cursor.
  final bool? showCursor;

  /// Whether this field should focus itself when first built.
  final bool autofocus;

  /// Whether to hide the text being edited.
  ///
  /// When true, a visibility toggle is shown if [decoration] does not provide a
  /// suffix icon.
  final bool obscureText;

  /// Whether to enable autocorrection.
  final bool autocorrect;

  /// Whether to show keyboard suggestions.
  final bool enableSuggestions;

  /// The maximum number of lines for the text to span.
  final int? maxLines;

  /// The minimum number of lines to occupy.
  final int? minLines;

  /// Whether this field should fill its parent.
  final bool expands;

  /// The maximum number of characters to allow.
  final int? maxLength;

  /// Optional input validation and formatting overrides.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether this field is interactive.
  final bool? enabled;

  /// Restoration ID to save and restore the state of this field.
  final String? restorationId;

  /// Used to enable or disable automatic validation.
  final AutovalidateMode? autovalidateMode;

  /// The padding around the inner [TextFormField].
  final EdgeInsetsGeometry padding;

  /// The empty space that surrounds this field.
  final EdgeInsetsGeometry? margin;

  /// The padding for the editable text inside the field decoration.
  final EdgeInsetsGeometry contentPadding;

  /// The radius of the animated field surface.
  final BorderRadiusGeometry borderRadius;

  /// The background color when the field is empty and unfocused.
  ///
  /// Defaults to [ColorScheme.surfaceContainer].
  final Color? backgroundColor;

  /// The background color when the field has focus.
  ///
  /// Defaults to [ColorScheme.surfaceContainerHigh].
  final Color? focusedBackgroundColor;

  /// The background color when the field has text and no error.
  ///
  /// Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? populatedBackgroundColor;

  /// The background color when [InputDecoration.errorText] is non-null.
  ///
  /// Defaults to [ColorScheme.errorContainer].
  final Color? errorBackgroundColor;

  /// The border side when the field is enabled, empty, and unfocused.
  final BorderSide? side;

  /// The border side when the field has focus.
  final BorderSide? focusedSide;

  /// The border side when [InputDecoration.errorText] is non-null.
  ///
  /// Defaults to [ColorScheme.error].
  final BorderSide? errorSide;

  /// The duration of the animated surface transition.
  final Duration animationDuration;

  /// The curve of the animated surface transition.
  final Curve animationCurve;

  /// Validates the text entered in this field.
  final FormFieldValidator<String>? validator;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits editing without a platform action.
  final VoidCallback? onEditingComplete;

  /// Called when the user indicates that they are done editing the text.
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// Called when the field is tapped.
  final GestureTapCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _focusNode;
  bool _hasFocus = false;
  bool _hasValue = false;
  late bool _obscureText;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _hasValue = _currentText.isNotEmpty;
    _hasFocus = _effectiveFocusNode.hasFocus;
    _effectiveFocusNode.addListener(_handleFocusChanged);
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      if (widget.focusNode != null) {
        _focusNode?.dispose();
        _focusNode = null;
      } else {
        _focusNode ??= FocusNode();
      }
      _effectiveFocusNode.addListener(_handleFocusChanged);
      _hasFocus = _effectiveFocusNode.hasFocus;
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
      _hasValue = _currentText.isNotEmpty;
    }

    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    widget.controller?.removeListener(_handleControllerChanged);
    _focusNode?.dispose();
    super.dispose();
  }

  String get _currentText =>
      widget.controller?.text ?? widget.initialValue ?? '';

  void _handleFocusChanged() {
    if (_hasFocus != _effectiveFocusNode.hasFocus) {
      setState(() => _hasFocus = _effectiveFocusNode.hasFocus);
    }
  }

  void _handleControllerChanged() {
    _updateHasValue(widget.controller?.text ?? '');
  }

  void _handleChanged(String value) {
    _updateHasValue(value);
    widget.onChanged?.call(value);
  }

  void _updateHasValue(String value) {
    final bool hasValue = value.isNotEmpty;
    if (_hasValue != hasValue) {
      setState(() => _hasValue = hasValue);
    }
  }

  void _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? effectiveStyle =
        widget.style ?? theme.textTheme.bodyMedium;
    final bool hasError = widget.decoration.errorText != null;
    final Color effectiveBackgroundColor = _backgroundColor(
      colorScheme,
      hasError: hasError,
    );
    final BorderSide effectiveSide = _borderSide(
      colorScheme,
      hasError: hasError,
    );
    final InputDecoration effectiveDecoration = _decoration(colorScheme);

    Widget current = AnimatedContainer(
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: widget.borderRadius,
        border: effectiveSide == BorderSide.none
            ? null
            : Border.fromBorderSide(effectiveSide),
      ),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.controller == null ? widget.initialValue : null,
        focusNode: _effectiveFocusNode,
        decoration: effectiveDecoration,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: effectiveStyle,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        textDirection: widget.textDirection,
        readOnly: widget.readOnly,
        showCursor: widget.showCursor,
        autofocus: widget.autofocus,
        obscureText: _obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        expands: widget.expands,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        restorationId: widget.restorationId,
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator,
        onChanged: _handleChanged,
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onFieldSubmitted,
        onSaved: widget.onSaved,
        onTap: widget.onTap,
      ),
    );

    if (widget.margin != null) {
      current = Padding(padding: widget.margin!, child: current);
    }

    return current;
  }

  Color _backgroundColor(ColorScheme colorScheme, {required bool hasError}) {
    if (hasError) {
      return widget.errorBackgroundColor ?? colorScheme.errorContainer;
    }

    if (_hasFocus) {
      return widget.focusedBackgroundColor ?? colorScheme.surfaceContainerHigh;
    }

    if (_hasValue) {
      return widget.populatedBackgroundColor ??
          colorScheme.surfaceContainerHighest;
    }

    return widget.backgroundColor ?? colorScheme.surfaceContainer;
  }

  BorderSide _borderSide(ColorScheme colorScheme, {required bool hasError}) {
    if (hasError) {
      return widget.errorSide ?? BorderSide(color: colorScheme.error);
    }

    if (_hasFocus) {
      return widget.focusedSide ?? widget.side ?? BorderSide.none;
    }

    return widget.side ?? BorderSide.none;
  }

  InputDecoration _decoration(ColorScheme colorScheme) {
    final InputDecoration decoration = widget.decoration;
    final Widget? suffixIcon =
        decoration.suffixIcon ??
        (widget.obscureText ? _buildVisibilityButton(colorScheme) : null);

    return decoration.copyWith(
      border: decoration.border ?? InputBorder.none,
      enabledBorder: decoration.enabledBorder ?? InputBorder.none,
      focusedBorder: decoration.focusedBorder ?? InputBorder.none,
      errorBorder: decoration.errorBorder ?? InputBorder.none,
      focusedErrorBorder: decoration.focusedErrorBorder ?? InputBorder.none,
      disabledBorder: decoration.disabledBorder ?? InputBorder.none,
      contentPadding: decoration.contentPadding ?? widget.contentPadding,
      hintStyle:
          decoration.hintStyle ??
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildVisibilityButton(ColorScheme colorScheme) {
    return IconButton(
      onPressed: _toggleObscureText,
      icon: Icon(
        _obscureText
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
