import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../di/get_it_constant.dart';

void initSecureStorageDI() {
  di.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
}
