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
