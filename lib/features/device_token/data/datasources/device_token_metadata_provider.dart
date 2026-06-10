// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class DeviceTokenMetadataProvider {
  String get platform;

  Future<String> readAppVersion();
}

class DeviceTokenMetadataProviderImpl implements DeviceTokenMetadataProvider {
  @override
  String get platform => defaultTargetPlatform.name;

  @override
  Future<String> readAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }
}
