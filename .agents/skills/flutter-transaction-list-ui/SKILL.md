---
name: flutter-transaction-list-ui
description: Build or adapt a Flutter Material transaction/history list screen with CustomScrollView, grouped sticky section headers, SliverMainAxisGroup, separated card rows, transaction amount coloring, and bottom navigation. Use when the user wants to implement the UI pattern from neobrui lib/main.dart in another Flutter project such as MyBL, or asks for a reusable transaction list, payment history, wallet history, order history, activity feed, or grouped sliver list screen.
---

# Flutter Transaction List UI

## Workflow

1. Inspect the target Flutter project before editing:
   - Locate the app's routing/navigation pattern, theme setup, existing list/card components, and transaction/domain models.
   - Prefer existing design tokens, currency formatters, icons, localization, and state management.
   - If the target project has a feature folder convention, place the screen and widgets there instead of copying everything into `main.dart`.

2. Implement the screen as reusable widgets:
   - Use `CustomScrollView` for the body.
   - Use one `_SliverGroupTitleAndContent`-style widget per date/status group.
   - Use `SliverMainAxisGroup` so the pinned header and its list are treated as one group.
   - Use `SliverPersistentHeader(pinned: true)` with a delegate for sticky section titles.
   - Use `SliverList.separated` or `SliverList.builder` plus explicit separators for card spacing.
   - Keep card rows stable: fixed icon container, `Expanded` title/subtitle column, amount text on the trailing edge.

3. Adapt data cleanly:
   - Map the project's real transaction entity into the fields needed by the card: icon/status visual, title, timestamp/subtitle, amount, and direction/type.
   - Do not preserve sample merchant data from `neobrui` unless the target project needs demo data.
   - For MyBL or Indonesian finance UIs, format amounts as Rupiah with project-local helpers if available; otherwise add a small formatter or use `intl`.

4. Preserve the visual behavior from the source screen:
   - App bar: centered title, taller toolbar if it matches the product style.
   - Header: surface background, 40 px extent, title aligned bottom-left, optional subtle translate/opacity animation based on shrink offset.
   - Card: horizontal margin 16, padding 16, no elevation unless the target design system uses shadow.
   - Negative/outgoing amounts use neutral or error color; incoming amounts use green/success color.

5. Verify:
   - Run `dart format` or `flutter format` equivalent.
   - Run Flutter analysis/tests available in the project.
   - If changing a running app, inspect on at least one compact mobile viewport/emulator for text overflow in title, timestamp, and amount.

## Reference

Read `references/pattern.md` when implementing the widgets. It contains the source-derived component structure and an adaptable code skeleton.
