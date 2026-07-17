// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/core/internal/src/extensions/extensions.dart';

void main() {
  group('StringExtension', () {
    test('capitalize handles empty string without throwing', () {
      expect(''.capitalize, '');
    });

    test('capitalize uppercases first letter and lowercases the rest', () {
      expect('mATEMATIKA'.capitalize, 'Matematika');
    });

    test('capitalizeEveryWord handles empty string without throwing', () {
      expect(''.capitalizeEveryWord, '');
    });

    test('capitalizeEveryWord handles consecutive spaces', () {
      expect('bahasa  indonesia'.capitalizeEveryWord, 'Bahasa  Indonesia');
    });

    test('capitalizeEveryWord capitalizes each word', () {
      expect('bahasa indonesia'.capitalizeEveryWord, 'Bahasa Indonesia');
    });

    test('takeFirstWordAndCapitalize returns first word capitalized', () {
      expect('budi luhur'.takeFirstWordAndCapitalize, 'Budi');
    });

    test('takeFirstWordAndCapitalize handles empty string', () {
      expect(''.takeFirstWordAndCapitalize, '');
    });
  });
}
