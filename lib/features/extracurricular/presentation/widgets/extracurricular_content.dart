// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular.dart';
import 'extracurricular_filter_section.dart';
import 'extracurricular_list_section.dart';

class ExtracurricularContent extends StatefulWidget {
  const ExtracurricularContent({super.key, required this.extracurricular});

  final List<ExtracurricularEntity> extracurricular;

  @override
  State<ExtracurricularContent> createState() => _ExtracurricularContentState();
}

class _ExtracurricularContentState extends State<ExtracurricularContent> {
  String? _selectedSchoolYear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredExtracurricular = _filteredExtracurricular(
      widget.extracurricular,
    );

    return SliverMainAxisGroup(
      slivers: [
        ExtracurricularFilterSection(
          extracurricular: widget.extracurricular,
          selectedSchoolYear: _selectedSchoolYear,
          onChanged: (value) => setState(() => _selectedSchoolYear = value),
        ),
        ExtracurricularListSection(
          extracurricular: filteredExtracurricular,
          emptyMessage: l10n.noExtracurricularData,
        ),
      ],
    );
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
}
