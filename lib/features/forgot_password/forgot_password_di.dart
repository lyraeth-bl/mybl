// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/forgot_password_remote_data_source.dart';
import 'data/repositories/forgot_password_repository_impl.dart';
import 'domain/repositories/forgot_password_repository.dart';
import 'domain/usecases/reset_password_use_case.dart';
import 'domain/usecases/send_reset_otp_use_case.dart';
import 'domain/usecases/verify_reset_otp_use_case.dart';
import 'presentation/bloc/forgot_password_bloc.dart';

void initForgotPasswordDI() {
  di.registerLazySingleton<ForgotPasswordRemoteDataSource>(
    () => ForgotPasswordRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<ForgotPasswordRepository>(
    () => ForgotPasswordRepositoryImpl(di<ForgotPasswordRemoteDataSource>()),
  );

  di.registerLazySingleton<SendResetOtpUseCase>(
    () => SendResetOtpUseCase(di<ForgotPasswordRepository>()),
  );
  di.registerLazySingleton<VerifyResetOtpUseCase>(
    () => VerifyResetOtpUseCase(di<ForgotPasswordRepository>()),
  );
  di.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(di<ForgotPasswordRepository>()),
  );

  di.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      di<SendResetOtpUseCase>(),
      di<VerifyResetOtpUseCase>(),
      di<ResetPasswordUseCase>(),
    ),
  );
}
