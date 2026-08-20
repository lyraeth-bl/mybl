// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/app_configuration/domain/app_update_rules.dart';

bool _required(String? installed, String? backend) =>
    isAppUpdateRequired(installedVersion: installed, requiredVersion: backend);

void main() {
  test('an older build needs the update', () {
    expect(_required('1.0.0', '1.3.0'), isTrue);
    expect(_required('1.2.9', '1.3.0'), isTrue);
    expect(_required('0.9.0', '1.0.0'), isTrue);
  });

  test('a current or newer build does not', () {
    expect(_required('1.3.0', '1.3.0'), isFalse);
    expect(_required('1.3.1', '1.3.0'), isFalse);
    expect(_required('2.0.0', '1.3.0'), isFalse);
  });

  test('segments compare numerically, not as text', () {
    // '9' sorts after '10' as a string; as a version it comes before.
    expect(_required('1.9.0', '1.10.0'), isTrue);
    expect(_required('1.10.0', '1.9.0'), isFalse);
  });

  test('the build number after + is ignored', () {
    expect(_required('1.3.0+4', '1.3.0'), isFalse);
    expect(_required('1.3.0', '1.3.0+9'), isFalse);
    expect(_required('1.2.0+9', '1.3.0+1'), isTrue);
  });

  test('missing segments count as zero', () {
    expect(_required('1.3', '1.3.0'), isFalse);
    expect(_required('1.3', '1.3.1'), isTrue);
    expect(_required('2', '1.9.9'), isFalse);
  });

  // A version the app cannot read must never lock anyone out: the config
  // ships '-' for platforms without a build, and a typo would otherwise
  // brick every install with no way back in.
  test('an unreadable version never forces an update', () {
    expect(_required('1.0.0', '-'), isFalse);
    expect(_required('-', '1.3.0'), isFalse);
    expect(_required('1.0.0', null), isFalse);
    expect(_required(null, '1.3.0'), isFalse);
    expect(_required('1.0.0', ''), isFalse);
    expect(_required('1.0.0', 'v1.3.0'), isFalse);
    expect(_required('1.0.0', 'latest'), isFalse);
  });
}
