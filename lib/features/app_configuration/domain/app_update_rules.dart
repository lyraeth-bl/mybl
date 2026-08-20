// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:math' as math;

/// Whether the installed build is older than the one the backend requires.
///
/// `forceAppUpdate` on its own only arms the check — the decision is this
/// comparison. Treating the flag as "block everyone" would brick every build
/// the moment it is switched on, including the newest one.
///
/// Returns false when either value cannot be read as a version. The config
/// ships "-" for platforms without a build, and a typo in that field must not
/// lock users out of the app with no way back in.
bool isAppUpdateRequired({
  required String? installedVersion,
  required String? requiredVersion,
}) {
  final installed = _parseVersion(installedVersion);
  final required = _parseVersion(requiredVersion);

  if (installed == null || required == null) return false;

  final length = math.max(installed.length, required.length);

  for (var index = 0; index < length; index++) {
    final installedSegment = index < installed.length ? installed[index] : 0;
    final requiredSegment = index < required.length ? required[index] : 0;

    if (installedSegment != requiredSegment) {
      return installedSegment < requiredSegment;
    }
  }

  return false;
}

/// Splits a dotted version into comparable segments, dropping any build
/// number after `+` so "1.3.0+4" and "1.3.0" compare equal.
List<int>? _parseVersion(String? raw) {
  if (raw == null) return null;

  final trimmed = raw.split('+').first.trim();
  if (trimmed.isEmpty) return null;

  final segments = <int>[];

  for (final part in trimmed.split('.')) {
    final value = int.tryParse(part);
    if (value == null || value < 0) return null;
    segments.add(value);
  }

  return segments.isEmpty ? null : segments;
}
