import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/local.dart';
import 'data/datasources/remote.dart';
import 'data/repositories/repository_impl.dart';
import 'domain/repositories/repository.dart';
import 'domain/usecases/fetch_academic_calendar_use_case.dart';
import 'presentation/bloc/academic_calendar_bloc.dart';

void initAcademicCalendarDI() {
  di.registerLazySingleton<AcademicCalendarLocalDataSource>(
    () => AcademicCalendarLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<AcademicCalendarRemoteDataSource>(
    () => AcademicCalendarRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<AcademicCalendarRepository>(
    () => AcademicCalendarRepositoryImpl(
      di<AcademicCalendarLocalDataSource>(),
      di<AcademicCalendarRemoteDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchAcademicCalendarUseCase>(
    () => FetchAcademicCalendarUseCase(di<AcademicCalendarRepository>()),
  );

  di.registerFactory<AcademicCalendarBloc>(
    () => AcademicCalendarBloc(di<FetchAcademicCalendarUseCase>()),
  );
}
