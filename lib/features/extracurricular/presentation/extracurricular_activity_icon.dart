// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../domain/entities/extracurricular.dart';

const Map<String, IconData> _activityIconKeywords = {
  'bulutangkis': Icons.sports_tennis,
  'badminton': Icons.sports_tennis,
  'taekwondo': Icons.sports_martial_arts,
  'teater': Icons.theater_comedy,
  'theater': Icons.theater_comedy,
  'theatre': Icons.theater_comedy,
  'paskibra': Icons.flag,
  'fine art': Icons.palette,
  'band': Icons.music_note,
  'futsal': Icons.sports_soccer,
  'tari': Icons.emoji_people,
  'dance': Icons.emoji_people,
  'science': Icons.science,
  'basket': Icons.sports_basketball,
  'art and design': Icons.design_services,
  'editing video': Icons.video_settings,
  'quran': Icons.auto_stories,
  'hadis': Icons.auto_stories,
  'photograph': Icons.camera_alt,
  'math': Icons.calculate,
  'japan': Icons.language,
  'toefl': Icons.translate,
  'esport': Icons.sports_esports,
  'robotik': Icons.smart_toy,
  'robot': Icons.smart_toy,
  'coding': Icons.code,
  'first aid': Icons.medical_services,
  'preneurship': Icons.lightbulb_outline,
  'entrepreneur': Icons.lightbulb_outline,
};

extension ExtracurricularActivityIcon on ExtracurricularEntity {
  IconData get activityIcon {
    final String normalized = namaKegiatan.trim().toLowerCase();

    for (final MapEntry<String, IconData> entry
        in _activityIconKeywords.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }

    return Icons.groups_2_outlined;
  }
}
