import 'package:dio/dio.dart';

import '../../../features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../../enums/user_role.dart';

class StudentNisInterceptor extends Interceptor {
  /// Resolusi [ParentBloc] ditunda (lazy) supaya tidak memaksa membangun
  /// graf dependensinya saat interceptor dibuat di tahap network DI.
  final ParentBloc Function() parentBloc;
  final UserRole Function() getRoleCallback;

  StudentNisInterceptor({
    required this.parentBloc,
    required this.getRoleCallback,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (getRoleCallback() == UserRole.parent) {
      final nis = parentBloc().activeNis;
      if (nis != null) {
        options.headers['X-Student-NIS'] = nis;
      }
    }
    handler.next(options);
  }
}
