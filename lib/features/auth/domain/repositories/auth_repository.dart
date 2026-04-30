// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/auth_response_entity/auth_response_entity.dart';

/// Kontrak utama buat urusan autentikasi (Login, Logout, dll).
///
/// Class ini cuma ngasih tau "apa aja" yang bisa dilakuin, tapi nggak peduli
/// gimana cara teknisnya (itu urusan Data Layer).
///
/// See also:
/// * [AuthRepositoryImpl], buat liat implementasi nyatanya.
abstract class AuthRepository implements Authenticator<AuthResponseEntity> {}
