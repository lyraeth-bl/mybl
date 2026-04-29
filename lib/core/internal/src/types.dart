// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../failure/failure.dart';

/// Alias generik untuk return type operasi yang bisa gagal.
///
/// Wraps [Either] dari fpdart — [Left] berisi [Failure],
/// [Right] berisi data bertipe [T].
///
/// Gunakan ini sebagai return type di repository dan use case:
/// ```dart
/// Future<Result<User>> getUser(String id);
/// Future<Result<List<Product>>> getProducts();
/// ```
typedef Result<T> = Either<Failure, T>;

/// Alias untuk return type HTTP request.
///
/// Spesialisasi dari [Result] untuk response API yang belum di-parse —
/// [Right] selalu berisi `Map<String, dynamic>` (raw JSON object),
/// [Left] berisi [Failure] jika request gagal.
///
/// Gunakan di layer [HTTPRequest], bukan di repository atau use case.
/// Di repository, parse dulu ke model lalu kembalikan sebagai [Result].
///
/// ```dart
/// // Di ApiClient
/// Future<HTTPResult> get(String url);
///
/// // Di repository — parse HTTPResult ke Result<User>
/// final result = await _client.get('/users/1');
/// return result.flatMap((json) => Result.right(User.fromJson(json)));
/// ```
typedef HTTPResult = Either<Failure, Map<String, dynamic>>;
