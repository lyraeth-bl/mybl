import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/attendance_local_data_source.dart';
import 'data/datasources/attendance_remote_data_source.dart';
import 'data/datasources/parent_attendance_remote_data_source.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'data/repositories/parent_attendance_repository_impl.dart';
import 'domain/repositories/attendance_repository.dart';
import 'domain/repositories/parent_attendance_repository.dart';
import 'domain/usecases/fetch_attendance_qr_token_use_case.dart';
import 'domain/usecases/fetch_daily_attendance_use_case.dart';
import 'domain/usecases/fetch_monthly_attendance_use_case.dart';
import 'domain/usecases/fetch_parent_daily_attendance_use_case.dart';
import 'domain/usecases/fetch_parent_monthly_attendance_use_case.dart';
import 'presentation/bloc/attendance_qr_bloc/attendance_qr_bloc.dart';
import 'presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import 'presentation/bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import 'presentation/bloc/parent_daily_attendance_bloc/parent_daily_attendance_bloc.dart';

void initAttendanceDI() {
  di.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(di<HTTPRequest>()),
  );
  di.registerLazySingleton<ParentAttendanceRemoteDataSource>(
    () => ParentAttendanceRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      di<AttendanceRemoteDataSource>(),
      di<AttendanceLocalDataSource>(),
    ),
  );
  di.registerLazySingleton<ParentAttendanceRepository>(
    () =>
        ParentAttendanceRepositoryImpl(di<ParentAttendanceRemoteDataSource>()),
  );

  di.registerLazySingleton<FetchMonthlyAttendanceUseCase>(
    () => FetchMonthlyAttendanceUseCase(di<AttendanceRepository>()),
  );
  di.registerLazySingleton<FetchDailyAttendanceUseCase>(
    () => FetchDailyAttendanceUseCase(di<AttendanceRepository>()),
  );
  di.registerLazySingleton<FetchAttendanceQrTokenUseCase>(
    () => FetchAttendanceQrTokenUseCase(di<AttendanceRepository>()),
  );
  di.registerLazySingleton<FetchParentDailyAttendanceUseCase>(
    () => FetchParentDailyAttendanceUseCase(di<ParentAttendanceRepository>()),
  );
  di.registerLazySingleton<FetchParentMonthlyAttendanceUseCase>(
    () => FetchParentMonthlyAttendanceUseCase(di<ParentAttendanceRepository>()),
  );

  di.registerFactoryParam<DailyAttendanceBloc, bool, void>(
    (isParent, _) => DailyAttendanceBloc(
      isParent
          ? di<FetchParentDailyAttendanceUseCase>().call
          : di<FetchDailyAttendanceUseCase>().call,
    ),
  );
  di.registerFactoryParam<MonthlyAttendanceBloc, bool, void>(
    (isParent, _) => MonthlyAttendanceBloc(
      isParent
          ? di<FetchParentMonthlyAttendanceUseCase>().call
          : di<FetchMonthlyAttendanceUseCase>().call,
    ),
  );
  di.registerFactory<AttendanceQrBloc>(
    () => AttendanceQrBloc(di<FetchAttendanceQrTokenUseCase>()),
  );
  di.registerFactory<ParentDailyAttendanceBloc>(
    () => ParentDailyAttendanceBloc(di<FetchParentDailyAttendanceUseCase>()),
  );
}
