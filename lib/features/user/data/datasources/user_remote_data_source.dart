// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/student_response/student_response.dart';

/// [UserRemoteDataSource] itu kontrak buat urusan nembak API.
/// Kerjaan utamanya cuma satu: ambil data terbaru dari server.
abstract class UserRemoteDataSource {
  Future<StudentResponse> fetch();
}

/// [UserRemoteDataSourceImpl] adalah implementasi nyata yang pake [HTTPRequest].
/// Dia ini "Si Paling Update" yang tugasnya terbang ke cloud (lewat internet)
/// buat nanya, "Eh, data siswa ini apa kabar ya?".
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<StudentResponse> fetch() async {
    // Kita panggil endpoint 'me' buat dapet info profil kita sendiri.
    final response = await _httpRequest.get(ApiEndpoints.me);

    // Kalo udah dapet, langsung kita sulap jadi [StudentResponse].
    return StudentResponse.fromJson(response);
  }
}
