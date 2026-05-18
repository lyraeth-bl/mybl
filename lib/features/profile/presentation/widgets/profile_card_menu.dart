import 'package:flutter/material.dart';

class ProfileCardMenu extends StatelessWidget {
  const ProfileCardMenu({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.shape,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ShapeBorder? shape;
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
