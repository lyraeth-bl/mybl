// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';

/// Jembatan utama buat ngurusin segala urusan sesi user di aplikasi kita.
///
/// [SessionRepository] ini tugasnya jadi satu pintu buat akses data sesi,
/// kayak token biar user nggak perlu bolak-balik login. Class ini
/// sebenernya kontrak yang wajib diikutin kalau kita mau bikin implementasi
/// storage buat sesi, misalnya mau pake Hive atau SharedPreferences.
///
/// Karena dia dapet warisan dari [TokenStorage], dia punya tugas buat
/// baca, nyimpen, sampe ngebakar (hapus) access token pas user logout.
abstract class SessionRepository implements TokenStorage {}
