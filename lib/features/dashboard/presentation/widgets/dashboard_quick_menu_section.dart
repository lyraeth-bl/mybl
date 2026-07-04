import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import 'menu_sheet_item.dart';

class DashboardQuickMenuSection extends StatelessWidget {
  const DashboardQuickMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final menuItems = MenuSheetItem.menuItems
        .where((item) => item.routePath != RouteNames.settings)
        .toList();

    return AppSliverGroup(
      title: l10n.quickMenu,
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      sliver: SliverGrid.count(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final label = item.resolveLabel(l10n);

    return AppContainer(
      backgroundColor: colorScheme.surface,
      margin: .zero,
      elevation: 0,
      padding: const .symmetric(vertical: 16, horizontal: 8),
      onTap: () => context.push(item.routePath),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          AppIconContainer(
            icon: item.icon,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            padding: const .all(8),
            shape: RoundedRectangleBorder(borderRadius: .circular(8)),
          ),
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
        ].separatedBy(8.h),
      ),
    );
  }
}
