// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'app_toast_type.dart';

/// Shows application-styled toast notifications.
///
/// This class wraps `toastification` so callers can show semantic toast
/// notifications without directly depending on package styling details.
@immutable
abstract final class AppToast {
  const AppToast._();

  /// Shows a customizable toast notification.
  ///
  /// The [context] is used to find the nearest overlay and [ThemeData].
  ///
  /// The [message] is the primary body text displayed in the toast.
  ///
  /// The [title] is displayed above [message] when non-null.
  ///
  /// The [type] controls the semantic color and default icon.
  ///
  /// The [style] controls the toast surface treatment.
  ///
  /// The [alignment] controls where the toast appears on screen.
  ///
  /// The [duration] controls how long the toast stays visible before closing.
  ///
  /// The [showProgressBar] controls whether the timeout progress indicator is
  /// visible.
  ///
  /// The [showCloseButton] controls whether the close button is visible.
  ///
  /// The [pauseOnHover] controls whether the close timer pauses while hovering.
  ///
  /// The [closeOnSwipe] controls whether the toast can be dismissed by a swipe
  /// gesture.
  ///
  /// The [icon] replaces the default semantic icon when non-null.
  ///
  /// The [padding] is the interior spacing around the toast content.
  ///
  /// The [borderRadius] is the radius of the toast container.
  ///
  /// The [onTap] callback is invoked when the toast is tapped.
  ///
  /// The [onDismissed] callback is invoked when the toast is dismissed by a
  /// gesture.
  static ToastificationItem show(
    BuildContext context,
    String message, {
    String? title,
    AppToastType type = AppToastType.info,
    AppToastStyle style = .flatColored,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 3),
    bool showProgressBar = true,
    bool showCloseButton = false,
    bool pauseOnHover = true,
    bool closeOnSwipe = true,
    Widget? icon,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onDismissed,
  }) {
    assert(duration > Duration.zero, 'duration must be greater than zero.');

    return toastification.show(
      context: context,
      type: type._toToastificationType(),
      style: style._toToastificationStyle(),
      alignment: alignment,
      autoCloseDuration: duration,
      title: title == null
          ? null
          : Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      description: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
      icon: icon,
      padding: padding,
      borderRadius: borderRadius,
      showProgressBar: showProgressBar,
      closeButton: ToastCloseButton(
        showType: showCloseButton
            ? CloseButtonShowType.always
            : CloseButtonShowType.none,
      ),
      dragToClose: closeOnSwipe,
      pauseOnHover: pauseOnHover,
      callbacks: ToastificationCallbacks(
        onTap: onTap == null ? null : (_) => onTap(),
        onDismissed: onDismissed == null ? null : (_) => onDismissed(),
      ),
      onHoverMouseCursor: onTap == null ? null : SystemMouseCursors.click,
    );
  }

  /// Shows a success toast notification.
  static ToastificationItem success(
    BuildContext context,
    String message, {
    String? title,
    AppToastStyle style = .flatColored,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 3),
    bool showProgressBar = true,
    bool showCloseButton = false,
    bool pauseOnHover = true,
    bool closeOnSwipe = true,
    Widget? icon,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onDismissed,
  }) {
    return show(
      context,
      message,
      title: title,
      type: AppToastType.success,
      style: style,
      alignment: alignment,
      duration: duration,
      showProgressBar: showProgressBar,
      showCloseButton: showCloseButton,
      pauseOnHover: pauseOnHover,
      closeOnSwipe: closeOnSwipe,
      icon: icon,
      padding: padding,
      borderRadius: borderRadius,
      onTap: onTap,
      onDismissed: onDismissed,
    );
  }

  /// Shows an error toast notification.
  static ToastificationItem error(
    BuildContext context,
    String message, {
    String? title,
    AppToastStyle style = .flatColored,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 3),
    bool showProgressBar = true,
    bool showCloseButton = false,
    bool pauseOnHover = true,
    bool closeOnSwipe = true,
    Widget? icon,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onDismissed,
  }) {
    return show(
      context,
      message,
      title: title,
      type: AppToastType.error,
      style: style,
      alignment: alignment,
      duration: duration,
      showProgressBar: showProgressBar,
      showCloseButton: showCloseButton,
      pauseOnHover: pauseOnHover,
      closeOnSwipe: closeOnSwipe,
      icon: icon,
      padding: padding,
      borderRadius: borderRadius,
      onTap: onTap,
      onDismissed: onDismissed,
    );
  }

  /// Shows a warning toast notification.
  static ToastificationItem warning(
    BuildContext context,
    String message, {
    String? title,
    AppToastStyle style = .flatColored,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 3),
    bool showProgressBar = true,
    bool showCloseButton = false,
    bool pauseOnHover = true,
    bool closeOnSwipe = true,
    Widget? icon,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onDismissed,
  }) {
    return show(
      context,
      message,
      title: title,
      type: AppToastType.warning,
      style: style,
      alignment: alignment,
      duration: duration,
      showProgressBar: showProgressBar,
      showCloseButton: showCloseButton,
      pauseOnHover: pauseOnHover,
      closeOnSwipe: closeOnSwipe,
      icon: icon,
      padding: padding,
      borderRadius: borderRadius,
      onTap: onTap,
      onDismissed: onDismissed,
    );
  }

  /// Shows an info toast notification.
  static ToastificationItem info(
    BuildContext context,
    String message, {
    String? title,
    AppToastStyle style = .flatColored,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 3),
    bool showProgressBar = true,
    bool showCloseButton = false,
    bool pauseOnHover = true,
    bool closeOnSwipe = true,
    Widget? icon,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onDismissed,
  }) {
    return show(
      context,
      message,
      title: title,
      type: AppToastType.info,
      style: style,
      alignment: alignment,
      duration: duration,
      showProgressBar: showProgressBar,
      showCloseButton: showCloseButton,
      pauseOnHover: pauseOnHover,
      closeOnSwipe: closeOnSwipe,
      icon: icon,
      padding: padding,
      borderRadius: borderRadius,
      onTap: onTap,
      onDismissed: onDismissed,
    );
  }
}

extension on AppToastType {
  ToastificationType _toToastificationType() {
    return switch (this) {
      AppToastType.info => ToastificationType.info,
      AppToastType.success => ToastificationType.success,
      AppToastType.warning => ToastificationType.warning,
      AppToastType.error => ToastificationType.error,
    };
  }
}

extension on AppToastStyle {
  ToastificationStyle _toToastificationStyle() {
    return switch (this) {
      AppToastStyle.flat => ToastificationStyle.flat,
      AppToastStyle.flatColored => ToastificationStyle.flatColored,
      AppToastStyle.filled => ToastificationStyle.fillColored,
      AppToastStyle.minimal => ToastificationStyle.minimal,
    };
  }
}
