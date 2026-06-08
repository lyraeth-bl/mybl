// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Resolves a school subject name to a Material icon.
///
/// Use [SubjectIconResolver.resolve] when a subject comes from API data and the
/// UI needs a stable, recognizable icon without coupling presentation widgets to
/// a long list of subject aliases.
@immutable
final class SubjectIconResolver {
  const SubjectIconResolver._();

  /// Returns the most relevant icon for [subjectName].
  ///
  /// Matching is case-insensitive and ignores extra whitespace, punctuation, and
  /// common spelling variations. Returns [fallback] when no subject category can
  /// be inferred.
  static IconData resolve(
    String? subjectName, {
    IconData fallback = Icons.book_outlined,
  }) {
    final subject = _normalize(subjectName);
    if (subject.isEmpty) return fallback;

    if (_containsAny(subject, const [
      'pancasila',
      'kewarganegaraan',
      'kebudiluhuran',
      'karakter building',
      'etika',
    ])) {
      return Icons.balance_outlined;
    }

    if (_containsAny(subject, const ['agama', 'bimbingan konseling'])) {
      return Icons.volunteer_activism_outlined;
    }

    if (_containsAny(subject, const [
      'bahasa indonesia',
      'sastra indonesia',
      'karya tulis',
      'penulisan naskah',
    ])) {
      return Icons.menu_book_outlined;
    }

    if (_containsAny(subject, const [
      'bahasa inggris',
      'english talk',
      'public speaking',
      'negotiation',
      'lobbying',
    ])) {
      return Icons.record_voice_over_outlined;
    }

    if (_containsAny(subject, const [
      'bahasa jepang',
      'bahasa jerman',
      'bahasa mandarin',
      'hubungan internasional',
      'international',
      'contemporary ir',
    ])) {
      return Icons.language_outlined;
    }

    if (_containsAny(subject, const [
      'sejarah',
      'antropologi',
      'sosiologi',
      'ilmu pengetahuan sosial',
      'kriminologi',
      'crime',
    ])) {
      return Icons.account_balance_outlined;
    }

    if (_containsAny(subject, const [
      'seni budaya',
      'art',
      'desain',
      'design',
      'tinjauan seni',
      'gambar teknik',
      'pra perancangan arsitektur',
      'interior',
      'unsur desain',
      'ui ux',
      'visual desain',
      'compositing',
      'artistik',
      'scenic art',
    ])) {
      return Icons.palette_outlined;
    }

    if (_containsAny(subject, const ['seni musik', 'audio', 'tata suara'])) {
      return Icons.music_note_outlined;
    }

    if (_containsAny(subject, const [
      'pendidikan jasmani',
      'olahraga',
      'kesehatan',
    ])) {
      return Icons.sports_soccer_outlined;
    }

    if (_containsAny(subject, const [
      'matematika',
      'akuntansi',
      'komputer akuntansi',
      'aplikasi excel',
      'pasar uang',
      'pasar modal',
    ])) {
      return Icons.calculate_outlined;
    }

    if (_containsAny(subject, const [
      'ekonomi',
      'bisnis',
      'marketing',
      'entrepreneur',
      'kewirausahaan',
      'creativepreneurship',
      'enterprise resource planning',
      'retail',
      'korupsi',
    ])) {
      return Icons.trending_up_outlined;
    }

    if (_containsAny(subject, const [
      'informatika',
      'teknologi informasi',
      'komputer',
      'jaringan',
      'kkpi',
      'pemrograman',
      'coding',
      'mobile apps',
      'basis data',
      'database',
      'perangkat lunak',
      'software',
      'android',
      'framework',
      'data science',
      'genai',
      'prompt engineering',
    ])) {
      return Icons.computer_outlined;
    }

    if (_containsAny(subject, const ['game', 'gim', 'archiplay'])) {
      return Icons.sports_esports_outlined;
    }

    if (_containsAny(subject, const [
      'fisika',
      'kimia',
      'biologi',
      'ilmu pengetahuan alam',
      'ipas',
    ])) {
      return Icons.science_outlined;
    }

    if (_containsAny(subject, const [
      'geografi',
      'wisata wilayah',
      'mitigasi bencana',
    ])) {
      return Icons.public_outlined;
    }

    if (_containsAny(subject, const [
      'elektronika',
      'listrik',
      'energi baru',
      'robotics',
      'robotik',
      'automation',
      'engisketch',
      'insinyur',
    ])) {
      return Icons.memory_outlined;
    }

    if (_containsAny(subject, const [
      'creative content',
      'konten kreatif',
      'videografi',
      'video',
      'vidio',
      'editing',
      'fotografi',
      'movie maker',
      'multimedia',
      'kamera',
      'pencahayaan',
      'produksi',
      'animasi',
      'casting',
      'penyutradaraan',
      'televisi',
      'efek',
      'spesial video',
      'hunting lokasi',
    ])) {
      return Icons.movie_creation_outlined;
    }

    if (_containsAny(subject, const [
      'prakarya',
      'ketrampilan',
      'keterampilan',
      'projek kreatif',
      'proyek',
      'dasar-dasar program keahlian',
      'praktik kerja lapangan',
      'praktik kerja industri',
      'teori kejuruan',
    ])) {
      return Icons.construction_outlined;
    }

    if (_containsAny(subject, const [
      'media sosial',
      'periklanan',
      'digital marketing',
      'komunikasi massa',
    ])) {
      return Icons.campaign_outlined;
    }

    return fallback;
  }

  static String _normalize(String? value) {
    if (value == null) return '';

    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _containsAny(String subject, List<String> keywords) {
    return keywords.any((keyword) => subject.contains(_normalize(keyword)));
  }
}
