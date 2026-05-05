// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/profile_picture.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: SizedBox(
          height: 175,
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -80,
                child: Container(
                  width: 225,
                  height: 225,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Row(
                    children: [
                      BlocSelector<UserBloc, UserState, String>(
                        selector: (state) => state.maybeWhen(
                          success: (student) => student.profileImageUrl ?? "",
                          orElse: () => "",
                        ),
                        builder: (context, studentImageUrl) {
                          return ProfilePicture(
                            profileImageUrl: studentImageUrl,
                          );
                        },
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocSelector<UserBloc, UserState, String>(
                              selector: (state) => state.maybeWhen(
                                success: (student) =>
                                    student.nama ?? l10n.emptyName,
                                orElse: () => "",
                              ),
                              builder: (context, studentName) {
                                return Text(
                                  studentName,
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 4),

                            BlocSelector<UserBloc, UserState, String>(
                              selector: (state) => state.maybeWhen(
                                success: (student) {
                                  return "${student.kelasSaatIni} ${student.noKelasSaatIni}";
                                },
                                orElse: () => "",
                              ),
                              builder: (context, studentClass) {
                                return Text(
                                  "${l10n.classRoom} $studentClass",
                                  style: textTheme.labelMedium!.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      IconButton(
                        iconSize: 28,
                        onPressed: () {},
                        icon: Icon(Icons.notifications),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
