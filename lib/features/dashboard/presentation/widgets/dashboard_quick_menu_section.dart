import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import 'menu_sheet_item.dart';

class DashboardQuickMenuSection extends StatelessWidget {
  const DashboardQuickMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final menuItems = MenuSheetItem.menuItems
        .where((item) => item.routePath != RouteNames.settings)
        .toList();

    return AppSliverGroup(
      title: l10n.quickMenu,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid.count(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.74,
        children: [
          for (final item in menuItems) _DashboardQuickMenuItem(item: item),
        ],
      ),
    );
  }
}

class _DashboardQuickMenuItem extends StatelessWidget {
  const _DashboardQuickMenuItem({required this.item});

  final MenuSheetItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final label = item.resolveLabel(l10n);

    return AppContainer(
      backgroundColor: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(item.routePath),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIconContainer(
            icon: item.icon,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
