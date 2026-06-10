# Sticky Grouped Transaction List Pattern

## Source Pattern

The original `neobrui/lib/main.dart` screen uses:

- `Scaffold` with an `AppBar`, `CustomScrollView`, and `BottomNavigationBar`.
- `SliverMainAxisGroup` to combine a sticky group title and a sliver list.
- `SliverPersistentHeaderDelegate` for a pinned "Hari ini" header.
- `SliverList.separated` for transaction rows.
- A card row with icon box, merchant/time column, and signed Rupiah amount.

## Adaptable Skeleton

```dart
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <TransactionGroup>[
      // Build these from the project's real data/state.
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
        toolbarHeight: 85,
        elevation: 0,
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (final group in groups)
            TransactionSliverGroup(
              title: group.title,
              transactions: group.items,
            ),
        ],
      ),
    );
  }
}

class TransactionSliverGroup extends StatelessWidget {
  const TransactionSliverGroup({
    super.key,
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<TransactionListItem> transactions;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: TransactionHeaderDelegate(title: title),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverList.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return TransactionCard(item: transactions[index]);
            },
          ),
        ),
      ],
    );
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOutgoing = item.direction == TransactionDirection.outgoing;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.secondaryContainer,
              ),
              child: Icon(
                item.icon,
                color: colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${isOutgoing ? '-' : '+'} ${item.formattedAmount}',
              textAlign: TextAlign.end,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOutgoing ? colorScheme.onSurface : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const TransactionHeaderDelegate({required this.title});

  final String title;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = shrinkOffset / maxExtent;
    final currentOffset = (1 - progress) * 4;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      alignment: Alignment.bottomLeft,
      child: Transform.translate(
        offset: Offset(currentOffset, 0),
        child: Opacity(
          opacity: (progress * 0.5 + 0.5).clamp(0.0, 1.0),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant TransactionHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
```

## Data Shape

Use a small view model when the project entity is too large or unstable:

```dart
class TransactionGroup {
  const TransactionGroup({required this.title, required this.items});

  final String title;
  final List<TransactionListItem> items;
}

class TransactionListItem {
  const TransactionListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.formattedAmount,
    required this.direction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String formattedAmount;
  final TransactionDirection direction;
}

enum TransactionDirection { incoming, outgoing }
```

## Currency Formatting

Prefer the app's existing formatter. If none exists and adding `intl` is acceptable:

```dart
final rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);
```

If avoiding a dependency, use a local helper near the mapper, not inside the card widget. Keep formatting out of `build` for long lists when data can be prepared earlier.
