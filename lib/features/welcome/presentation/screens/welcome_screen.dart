// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_pattern_animate.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WelcomeView();
  }
}

class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late final Animation<double> _fadeInAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).disableAnimations) {
        _animationController.value = 1.0;
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const AuthPatternAnimate(),
          Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 96, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBack,
                        style: textTheme.headlineLarge!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        l10n.loginAs,
                        style: textTheme.headlineSmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      _RoleCard(
                        icon: Icons.school_rounded,
                        label: l10n.student,
                        isPrimary: true,
                        onTap: () => context.push(RouteNames.authStudent),
                      ),

                      const SizedBox(height: 16),

                      _RoleCard(
                        icon: Icons.supervisor_account_rounded,
                        label: l10n.parent,
                        onTap: () => context.push(RouteNames.authParent),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final iconBgColor = isPrimary
        ? colorScheme.onPrimary.withValues(alpha: 0.2)
        : colorScheme.primaryContainer;
    final iconColor = isPrimary
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;
    final labelColor = isPrimary
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final arrowColor = isPrimary
        ? colorScheme.onPrimary.withValues(alpha: 0.7)
        : colorScheme.onSurfaceVariant;

    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 0)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );

    final child = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: textTheme.titleMedium!.copyWith(
            color: labelColor,
          ),
        ),
        const Spacer(),
        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: arrowColor),
      ],
    );

    if (isPrimary) {
      return FilledButton(style: buttonStyle, onPressed: onTap, child: child);
    }
    return OutlinedButton(style: buttonStyle, onPressed: onTap, child: child);
  }
}
