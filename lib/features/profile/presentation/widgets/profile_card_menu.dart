// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Kartu menu andalan buat di halaman profil.
///
/// Daripada nulis [ListTile] berulang-ulang, mending pake widget ini aja.
/// Udah sepaket sama icon, title, subtitle, dan handling [onTap]-nya.
/// Bentuk pojokannya (shape) juga bisa lo custom kalo mau beda sendiri.
class ProfileCardMenu extends StatelessWidget {
  const ProfileCardMenu({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.shape,
  });

  /// Judul utama yang bakal ditebelin tulisannya.
  final String title;

  /// Keterangan tambahan di bawah judul.
  final String subtitle;

  /// Icon yang muncul di sebelah kiri.
  final IconData icon;

  /// Bentuk pojokan kartunya, default-nya [RoundedRectangleBorder] dengan radius 24.
  final ShapeBorder? shape;

  /// Fungsi yang dipanggil pas kartu ini diklik.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(2),
      elevation: 0,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        onTap: onTap,
        shape:
            shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHigh,
          foregroundColor: colorScheme.onSurfaceVariant,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
