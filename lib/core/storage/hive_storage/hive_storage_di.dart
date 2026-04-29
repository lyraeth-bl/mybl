import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../di/get_it_constant.dart';
import 'hive_storage_names.dart';

Future<void> initHiveStorageDI() async {
  await Hive.initFlutter();

  await Hive.openBox(HiveStorageBoxNames.userBoxKey);

  di.registerLazySingleton<HiveInterface>(() => Hive);
}
