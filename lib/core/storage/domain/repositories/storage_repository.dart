// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../internal/src/interfaces/data_interfaces.dart';

/// Kontrak utama buat ngatur gudang penyimpanan lokal di level Domain.
///
/// Class ini nge-implement [LocalStorageManager], jadi dia punya tanggung jawab
/// buat buka, tutup, dan bersih-bersih database lokal (kayak Hive).
abstract class StorageRepository implements LocalStorageManager {}
