// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/student_entity/student_entity.dart';

/// [UserRepository] itu kontrak atau janji suci buat urusan data user.
/// Dia pake [ItemFetcher] biar konsisten pas mau narik data [StudentEntity].
/// Anggep aja ini cetak biru (blueprint) buat siapa pun yang mau ngambil data siswa,
/// entah itu dari internet atau dari memori hp sendiri.
abstract class UserRepository implements ItemFetcher<StudentEntity> {}
