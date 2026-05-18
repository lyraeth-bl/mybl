// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user/presentation/bloc/user_bloc.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    super.key,
    required this.profileImageUrl,
    this.radius,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String profileImageUrl;
  final double? radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      radius: radius != null ? radius! : 28,
      child: profileImageUrl.isEmpty
          ? _buildInitial(context)
          : ClipOval(
              child: CachedNetworkImage(
                width: radius != null ? (radius! * 2) : 56,
                height: radius != null ? (radius! * 2) : 56,
                imageUrl: profileImageUrl,
                errorWidget: (context, url, error) => _buildInitial(context),
              ),
            ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocSelector<UserBloc, UserState, String>(
      selector: (state) => state.maybeWhen(
        success: (student) {
          final nama = student.nama ?? "";
          return nama.isNotEmpty ? nama[0] : "-";
        },
        orElse: () => "-",
      ),
      builder: (context, initial) {
        return Text(
          initial,
          style: textTheme.titleLarge!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
