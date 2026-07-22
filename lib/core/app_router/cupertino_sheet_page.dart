// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';

/// A go_router [Page] that presents its child as an iOS-style sheet.
///
/// Keeps sheet destinations inside the router so they stay deep-linkable
/// instead of being pushed imperatively onto the [Navigator].
class CupertinoSheetPage<T> extends Page<T> {
  const CupertinoSheetPage({
    required this.child,
    this.enableDrag = true,
    super.key,
    super.name,
  });

  /// The sheet's content.
  final Widget child;

  /// Whether the sheet can be dismissed by dragging it down.
  final bool enableDrag;

  @override
  Route<T> createRoute(BuildContext context) => CupertinoSheetRoute<T>(
    builder: (_) => child,
    enableDrag: enableDrag,
    settings: this,
  );
}
