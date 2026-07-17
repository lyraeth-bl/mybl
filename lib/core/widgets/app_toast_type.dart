// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

/// The semantic meaning of an app toast notification.
enum AppToastType {
  /// A neutral informational toast.
  info,

  /// A toast for successful or positive outcomes.
  success,

  /// A toast for warning or cautionary messages.
  warning,

  /// A toast for errors or destructive outcomes.
  error,
}

/// The visual treatment used for an app toast notification.
enum AppToastStyle {
  /// A neutral surface toast with semantic accent color.
  flat,

  /// A neutral surface toast with the semantic color.
  flatColored,

  /// A toast filled with the semantic color.
  filled,

  /// A reduced toast with subtle surface and border styling.
  minimal,
}
