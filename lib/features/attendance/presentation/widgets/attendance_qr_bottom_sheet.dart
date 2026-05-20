// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr/qr.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_qr_token/attendance_qr_token.dart';
import '../bloc/attendance_qr_bloc/attendance_qr_bloc.dart';

Future<void> showAttendanceQrSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.42,
      maxChildSize: 0.88,
      builder: (context, scrollController) => BlocProvider<AttendanceQrBloc>(
        create: (_) => di<AttendanceQrBloc>(),
        child: AttendanceQrBottomSheet(scrollController: scrollController),
      ),
    ),
  );
}

class AttendanceQrBottomSheet extends StatefulWidget {
  const AttendanceQrBottomSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<AttendanceQrBottomSheet> createState() =>
      _AttendanceQrBottomSheetState();
}

class _AttendanceQrBottomSheetState extends State<AttendanceQrBottomSheet> {
  static const _refreshInterval = Duration(seconds: 55);
  static const _countdownInterval = Duration(seconds: 1);

  Timer? _refreshTimer;
  Timer? _countdownTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestQrToken();
      _refreshTimer = Timer.periodic(
        _refreshInterval,
        (_) => _requestQrToken(),
      );
      _countdownTimer = Timer.periodic(_countdownInterval, (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _requestQrToken() {
    if (!mounted) return;

    final isLoading = context.read<AttendanceQrBloc>().state.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    );
    if (isLoading) return;

    context.read<AttendanceQrBloc>().add(
      const AttendanceQrEvent.attendanceQrTokenRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: BlocBuilder<AttendanceQrBloc, AttendanceQrState>(
        builder: (context, state) {
          final qrToken = state.maybeWhen(
            loading: (qrToken) => qrToken,
            success: (qrToken) => qrToken,
            orElse: () => null,
          );
          final isLoading = state.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );
          final failure = state.whenOrNull(failure: (failure) => failure);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.attendanceQrCode,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: isLoading ? null : _requestQrToken,
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.refreshQrCode,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: qrToken == null
                      ? _AttendanceQrPlaceholder(
                          isLoading: isLoading,
                          errorMessage: failure?.errorMessage,
                        )
                      : _AttendanceQrCard(
                          key: ValueKey(qrToken.token),
                          qrToken: qrToken,
                          isRefreshing: isLoading,
                          now: _now,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.qrCodeRefreshesAutomatically,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AttendanceQrPlaceholder extends StatelessWidget {
  const _AttendanceQrPlaceholder({
    required this.isLoading,
    required this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox.square(
      dimension: 240,
      child: Card.filled(
        color: colorScheme.surfaceContainerLowest,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.qrCodeLoading,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Text(
                    errorMessage ?? l10n.dioUnexpectedError,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceQrCard extends StatelessWidget {
  const _AttendanceQrCard({
    required this.qrToken,
    required this.isRefreshing,
    required this.now,
    super.key,
  });

  final AttendanceQrToken qrToken;
  final bool isRefreshing;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final remaining = qrToken.expiredAt.difference(now);
    final countdown = _formatCountdown(remaining);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 240,
              child: Card.filled(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: RepaintBoundary(
                    child: SizedBox.expand(
                      child: CustomPaint(
                        painter: _QrCodePainter(payload: qrToken.token),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isRefreshing)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.qrCodeExpiresIn(countdown),
          textAlign: TextAlign.center,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCountdown(Duration remaining) {
    final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
    final minutes = safeRemaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = safeRemaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }
}

class _QrCodePainter extends CustomPainter {
  _QrCodePainter({required this.payload}) : _image = _createQrImage(payload);

  static const _quietZone = 4;

  final String payload;
  final QrImage _image;

  static QrImage _createQrImage(String payload) {
    final code = QrCode(
      payload: QrPayload.fromString(payload),
      errorCorrectLevel: QrErrorCorrectLevel.high,
    );

    return QrImage(code);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = Colors.white;
    final darkPaint = Paint()..color = Colors.black;
    final modules = _image.moduleCount;
    final totalModules = modules + (_quietZone * 2);
    final moduleSize = size.shortestSide / totalModules;
    final qrSize = moduleSize * totalModules;
    final offset = Offset(
      (size.width - qrSize) / 2,
      (size.height - qrSize) / 2,
    );

    canvas.drawRect(offset & Size.square(qrSize), lightPaint);

    for (var row = 0; row < modules; row++) {
      for (var col = 0; col < modules; col++) {
        if (!_image.isDark(row, col)) continue;

        final rect = Rect.fromLTWH(
          offset.dx + ((col + _quietZone) * moduleSize),
          offset.dy + ((row + _quietZone) * moduleSize),
          moduleSize,
          moduleSize,
        );
        canvas.drawRect(rect, darkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) =>
      oldDelegate.payload != payload;
}
