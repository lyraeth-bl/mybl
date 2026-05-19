// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: RefreshWrapper(
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
            const _ExtracurricularHeader(),
            BlocBuilder<ExtracurricularBloc, ExtracurricularState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const _ExtracurricularLoadingList(),
                  success: (extracurricular) {
                    final filteredExtracurricular = _filteredExtracurricular(
                      extracurricular,
                    );
                    final extracurricularCards = filteredExtracurricular
                        .map<Widget>(
                          (item) => _ExtracurricularCard(extracurricular: item),
                        )
                        .toList()
                        .makeListAnimate();

                    return SliverList.list(
                      children: [
                        const SizedBox(height: 24),
                        _SchoolYearFilter(
                          extracurricular: extracurricular,
                          selectedSchoolYear: _selectedSchoolYear,
                          onChanged: (value) {
                            setState(() => _selectedSchoolYear = value);
                          },
                        ),
                        if (filteredExtracurricular.isEmpty)
                          const _ExtracurricularEmptyState()
                        else
                          ...extracurricularCards,
                        const SizedBox(height: 24),
                      ],
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
                  orElse: () => const _ExtracurricularLoadingList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtracurricularHeader extends StatelessWidget {
  const _ExtracurricularHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar.medium(
      title: Text(
        l10n.extracurricular,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      centerTitle: true,
      floating: false,
      pinned: true,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: DropdownButtonFormField<String?>(
        initialValue: selectedSchoolYear,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: l10n.schoolYear,
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: const Icon(Icons.filter_list_rounded),
          prefixIconColor: colorScheme.primary,
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
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
  const _ExtracurricularCard({required this.extracurricular});

  final ExtracurricularEntity extracurricular;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: customRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    extracurricular.namaKegiatan,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
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
                  value:
                      '${extracurricular.kelas} ${extracurricular.nomorKelas}',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.score,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            score,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
                  value,
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

class _ExtracurricularLoadingList extends StatelessWidget {
  const _ExtracurricularLoadingList();

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: const [
        SizedBox(height: 16),
        _LoadingCard(),
        _LoadingCard(),
        _LoadingCard(),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: customRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: const SizedBox(height: 22).toShimmer(
                    context,
                    width: double.infinity,
                    height: 22,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox().toShimmer(
                  context,
                  width: 56,
                  height: 44,
                  borderRadius: customRadius,
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
              children: List.generate(
                4,
                (_) => const SizedBox().toShimmer(
                  context,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtracurricularEmptyState extends StatelessWidget {
  const _ExtracurricularEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noExtracurricularData,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
