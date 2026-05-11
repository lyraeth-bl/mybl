// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Si paling refresh. Widget ini ngebungkus [RefreshIndicator] biar lo nggak perlu repot-repot
/// nulis boilerplate-nya tiap kali mau bikin fitur pull-to-refresh.
///
/// Tinggal kasih [onRefresh] buat logic-nya sama [child] yang scrollable (misal [ListView]
/// atau [SingleChildScrollView]), beres deh!
///
/// Contoh kalo lo mau refresh banyak data sekaligus (pake [blocRefresh] & [cubitRefresh]):
/// ```dart
/// class _DashboardRefreshWrapper extends StatelessWidget {
///   const _DashboardRefreshWrapper({required this.child});
///
///   final Widget child;
///
///   @override
///   Widget build(BuildContext context) {
///     return RefreshWrapper(
///       // Pake Future.wait biar loading-nya nungguin semua data kelar ditarik
///       onRefresh: () => Future.wait([
///         blocRefresh<UserBloc, UserEvent, UserState>(
///           context: context,
///           event: const UserEvent.fetchUser(forceRefresh: true),
///           isDone: (state) => state.maybeWhen(
///             success: (_) => true,
///             failure: (_, _) => true,
///             orElse: () => false,
///           ),
///         ),
///         cubitRefresh<TodayAttendanceCubit, TodayAttendanceState>(
///           context: context,
///           trigger: (cubit) => cubit.refresh(),
///           isDone: (state) => state.maybeWhen(
///             success: (_) => true,
///             noAttendanceToday: () => true,
///             failure: (_, _) => true,
///             orElse: () => false,
///           ),
///         ),
///       ]),
///       child: child,
///     );
///   }
/// }
/// ```
class RefreshWrapper extends StatelessWidget {
  const RefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// Callback yang bakal dipanggil pas user narik layar ke bawah.
  /// Biasanya isinya fungsi [blocRefresh] atau [cubitRefresh] biar sinkron sama state.
  final Future<void> Function() onRefresh;

  /// Widget scrollable yang mau dikasih fitur pull-to-refresh.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}

/// Jembatan andalan buat lo yang pengen nungguin proses [Bloc] sampe kelar pas lagi refresh.
///
/// Kadang kan [onRefresh] di [RefreshIndicator] itu butuh [Future]. Nah, si [blocRefresh]
/// ini bakal nge-fire [event] ke [B] terus nungguin sampe [isDone] ngebalikin `true`.
/// Jadi animasi loading-nya bakal tetep jalan sampe data beneran siap.
Future<void> blocRefresh<B extends Bloc<E, S>, E, S>({
  required BuildContext context,
  required E event,
  required bool Function(S state) isDone,
}) async {
  final completer = Completer<void>();
  final bloc = context.read<B>();

  bloc.add(event);

  late StreamSubscription<S> sub;
  sub = bloc.stream.listen((state) {
    if (isDone(state)) {
      completer.complete();
      sub.cancel();
    }
  });

  return completer.future;
}

/// Versi lite dari [blocRefresh], khusus buat lo yang tim [Cubit].
///
/// Cara kerjanya mirip, bedanya cuma di cara trigger logic-nya. Lo tinggal panggil
/// method di [Cubit] lewat callback [trigger], terus nungguin sampe statusnya [isDone].
/// Simple kan?
Future<void> cubitRefresh<C extends Cubit<S>, S>({
  required BuildContext context,
  required void Function(C cubit) trigger,
  required bool Function(S state) isDone,
}) async {
  final completer = Completer<void>();
  final cubit = context.read<C>();

  trigger(cubit);

  late StreamSubscription<S> sub;
  sub = cubit.stream.listen((state) {
    if (isDone(state)) {
      completer.complete();
      sub.cancel();
    }
  });

  return completer.future;
}
