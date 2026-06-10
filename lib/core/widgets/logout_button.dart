import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final void Function()? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: isLoading ? null : onPressed,
      label: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                // ignore: deprecated_member_use
                year2023: false,
              ),
            )
          : Text(l10n.logout),
      icon: isLoading ? null : Icon(Icons.logout),
    );
  }
}
