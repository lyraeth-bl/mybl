// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular.dart';
import '../bloc/extracurricular_bloc.dart';

class ExtracurricularScreen extends StatelessWidget {
  const ExtracurricularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExtracurricularBloc>(
      create: (context) => di<ExtracurricularBloc>(),
      child: const _ExtracurricularView(),
    );
  }
}

class _ExtracurricularView extends StatefulWidget {
  const _ExtracurricularView();

  @override
  State<_ExtracurricularView> createState() => _ExtracurricularViewState();
}

class _ExtracurricularViewState extends State<_ExtracurricularView> {
  String? _selectedSchoolYear;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExtracurricularBloc>().add(
        const ExtracurricularEvent.fetchExtracurricular(),
      );
    });
  }

  List<ExtracurricularEntity> _filteredExtracurricular(
    List<ExtracurricularEntity> extracurricular,
  ) {
    final selectedSchoolYear = _selectedSchoolYear;
    if (selectedSchoolYear == null) return extracurricular;

    return extracurricular
        .where((item) => item.tajaran == selectedSchoolYear)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: const _ExtracurricularAppBar(),
      body: _ExtracurricularBody(
        selectedSchoolYear: _selectedSchoolYear,
        filteredExtracurricular: _filteredExtracurricular,
        onSchoolYearChanged: (value) {
          setState(() => _selectedSchoolYear = value);
        },
      ),
    );
  }
}

class _ExtracurricularAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ExtracurricularAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        l10n.extracurricular,
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _ExtracurricularBody extends StatelessWidget {
  const _ExtracurricularBody({
    required this.selectedSchoolYear,
    required this.filteredExtracurricular,
    required this.onSchoolYearChanged,
  });

  final String? selectedSchoolYear;
  final List<ExtracurricularEntity> Function(List<ExtracurricularEntity>)
  filteredExtracurricular;
  final ValueChanged<String?> onSchoolYearChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: RefreshWrapper(
        onRefresh: () =>
            blocRefresh<
              ExtracurricularBloc,
              ExtracurricularEvent,
              ExtracurricularState
            >(
              context: context,
              event: const ExtracurricularEvent.fetchExtracurricular(true),
              isDone: (state) => state.maybeWhen(
                success: (_) => true,
                failure: (_) => true,
                orElse: () => false,
              ),
            ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BlocBuilder<ExtracurricularBloc, ExtracurricularState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const _ExtracurricularLoadingContent(),
                  success: (extracurricular) {
                    final filtered = filteredExtracurricular(extracurricular);

                    return _ExtracurricularContent(
                      extracurricular: extracurricular,
                      filteredExtracurricular: filtered,
                      selectedSchoolYear: selectedSchoolYear,
                      onSchoolYearChanged: onSchoolYearChanged,
                    );
                  },
                  failure: (failure) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ExtracurricularFailure(
                      message: failure.localizedMessage(
                        AppLocalizations.of(context)!,
                      ),
                    ),
                  ),
                  orElse: () => const _ExtracurricularLoadingContent(),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _ExtracurricularContent extends StatelessWidget {
  const _ExtracurricularContent({
    required this.extracurricular,
    required this.filteredExtracurricular,
    required this.selectedSchoolYear,
    required this.onSchoolYearChanged,
  });

  final List<ExtracurricularEntity> extracurricular;
  final List<ExtracurricularEntity> filteredExtracurricular;
  final String? selectedSchoolYear;
  final ValueChanged<String?> onSchoolYearChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverMainAxisGroup(
      slivers: [
        AppSliverGroup(
          title: l10n.schoolYear,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: _SchoolYearFilter(
            extracurricular: extracurricular,
            selectedSchoolYear: selectedSchoolYear,
            onChanged: onSchoolYearChanged,
          ),
        ),
        AppSliverGroup(
          title: l10n.extracurricular,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          action: AppChipContainer(value: '${filteredExtracurricular.length}'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          sliver: filteredExtracurricular.isEmpty
              ? SliverToBoxAdapter(
                  child: _ExtracurricularMessageContainer(
                    icon: Icons.assignment_outlined,
                    message: l10n.noExtracurricularData,
                  ),
                )
              : SliverList.builder(
                  itemCount: filteredExtracurricular.length,
                  itemBuilder: (context, index) {
                    final shape = index.makeVerticalGoogleShape(
                      filteredExtracurricular.length - 1,
                    );

                    return _ExtracurricularCard(
                      extracurricular: filteredExtracurricular[index],
                      shape: shape,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SchoolYearFilter extends StatelessWidget {
  const _SchoolYearFilter({
    required this.extracurricular,
    required this.selectedSchoolYear,
    required this.onChanged,
  });

  final List<ExtracurricularEntity> extracurricular;
  final String? selectedSchoolYear;
  final ValueChanged<String?> onChanged;

  List<String> get _schoolYears {
    final years = extracurricular.map((item) => item.tajaran).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: EdgeInsets.zero,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      child: DropdownButtonFormField<String?>(
        initialValue: selectedSchoolYear,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: l10n.schoolYear,
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: const Icon(Icons.filter_list_rounded),
          prefixIconColor: colorScheme.primary,
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: customRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: customRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: customRadius,
            borderSide: BorderSide(color: colorScheme.primary),
          ),
        ),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              l10n.allSchoolYears,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          ..._schoolYears.map(
            (schoolYear) => DropdownMenuItem<String?>(
              value: schoolYear,
              child: Text(
                schoolYear,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ExtracurricularCard extends StatelessWidget {
  const _ExtracurricularCard({
    required this.extracurricular,
    required this.shape,
  });

  final ExtracurricularEntity extracurricular;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final classRoom = '${extracurricular.kelas} ${extracurricular.nomorKelas}'
        .trim();

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppIconContainer(
                icon: Icons.groups_2_outlined,
                padding: const EdgeInsets.all(12),
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extracurricular.namaKegiatan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classRoom.isEmpty ? '-' : classRoom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ScoreBadge(score: extracurricular.nilai),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _DetailTile(
                icon: Icons.badge_outlined,
                label: l10n.nis,
                value: extracurricular.nis,
              ),
              _DetailTile(
                icon: Icons.school_outlined,
                label: l10n.classRoom,
                value: classRoom,
              ),
              _DetailTile(
                icon: Icons.calendar_month_outlined,
                label: l10n.schoolYear,
                value: extracurricular.tajaran,
              ),
              _DetailTile(
                icon: Icons.event_note_outlined,
                label: l10n.semester,
                value: extracurricular.semester,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppChipContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.score),
          Text(score, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppChipContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: colorScheme.surfaceContainer,
      foregroundColor: colorScheme.onSurface,
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtracurricularLoadingContent extends StatelessWidget {
  const _ExtracurricularLoadingContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverMainAxisGroup(
      slivers: [
        AppSliverGroup(
          title: l10n.schoolYear,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: const _LoadingFilter(),
        ),
        AppSliverGroup(
          title: l10n.extracurricular,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          action: const Text('').toShimmer(
            context,
            width: 40,
            height: 28,
            borderRadius: BorderRadius.circular(999),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          sliver: SliverList.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              final shape = index.makeVerticalGoogleShape(2);

              return _LoadingCard(shape: shape);
            },
          ),
        ),
      ],
    );
  }
}

class _LoadingFilter extends StatelessWidget {
  const _LoadingFilter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: EdgeInsets.zero,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      child: Row(
        children: [
          const Text('').toShimmer(
            context,
            width: 24,
            height: 24,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('').toShimmer(context, width: 80, height: 11),
                const SizedBox(height: 8),
                const Text('').toShimmer(context, width: 132, height: 14),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('').toShimmer(
            context,
            width: 20,
            height: 20,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.shape});

  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('').toShimmer(
                context,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('').toShimmer(context, width: 180, height: 16),
                    const SizedBox(height: 8),
                    const Text('').toShimmer(context, width: 128, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text('').toShimmer(
                context,
                width: 56,
                height: 44,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: List.generate(4, (_) => const _LoadingDetailTile()),
          ),
        ],
      ),
    );
  }
}

class _LoadingDetailTile extends StatelessWidget {
  const _LoadingDetailTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          const Text('').toShimmer(
            context,
            width: 18,
            height: 18,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('').toShimmer(context, width: 56, height: 10),
                const SizedBox(height: 6),
                const Text('').toShimmer(context, width: 88, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtracurricularMessageContainer extends StatelessWidget {
  const _ExtracurricularMessageContainer({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      margin: EdgeInsets.zero,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      child: Row(
        children: [
          AppIconContainer(
            icon: icon,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtracurricularFailure extends StatelessWidget {
  const _ExtracurricularFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<ExtracurricularBloc>().add(
                const ExtracurricularEvent.fetchExtracurricular(true),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                l10n.tryAgain,
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
