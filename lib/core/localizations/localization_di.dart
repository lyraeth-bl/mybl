import 'package:hive_ce/hive_ce.dart';

import '../di/get_it_constant.dart';
import 'localization_storage.dart';

void initLocalizationDI() {
  di.registerLazySingleton<LocalizationStorage>(
    () => LocalizationStorage(di<HiveInterface>()),
  );
}
