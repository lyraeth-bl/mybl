// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app_profile_picture.dart';

/// A Material app bar for common application screens.
///
/// Use [AppTopBar] when a screen needs a reusable [AppBar] with a centered
/// title, optional leading profile action, optional notification action, and
/// custom trailing actions. Feature state, routing, and localization should be
/// supplied through the public properties rather than handled inside this
/// widget.
@immutable
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an application top bar.
  const AppTopBar({
    super.key,
    this.title,
    this.leading,
    this.profileImageUrl,
    this.profileInitials,
    this.profileTooltip,
    this.profilePictureRadius = 28,
    this.profilePadding = const EdgeInsetsDirectional.only(start: 12),
    this.profileSide,
    this.profileSideWidth = 2,
    this.actions,
    this.actionsPadding = const EdgeInsetsDirectional.only(end: 16),
    this.notificationCount,
    this.notificationIcon = Icons.notifications_outlined,
    this.notificationTooltip,
    this.notificationMaxCount = 9,
    this.automaticallyImplyLeading = true,
    this.leadingWidth,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.titleTextStyle,
    this.centerTitle = true,
    this.clipBehavior,
    this.onProfileTap,
    this.onNotificationTap,
  }) : assert(
         leading == null ||
             (profileImageUrl == null &&
                 profileInitials == null &&
                 profileTooltip == null &&
                 profileSide == null &&
                 onProfileTap == null),
         'Profile properties cannot be provided when leading is provided.',
       ),
       assert(
         profilePictureRadius > 0,
         'profilePictureRadius must be greater than zero.',
       ),
       assert(profileSideWidth >= 0, 'profileSideWidth must be non-negative.'),
       assert(
         notificationCount == null || notificationCount >= 0,
         'notificationCount must be non-negative.',
       ),
       assert(
         notificationMaxCount > 0,
         'notificationMaxCount must be greater than zero.',
       ),
       assert(toolbarHeight >= 0, 'toolbarHeight must be non-negative.');

  /// The primary widget displayed in the app bar.
  ///
  /// Usually a [Text] widget. When null, no title is displayed.
  final Widget? title;

  /// A custom widget displayed before [title].
  ///
  /// When provided, profile-related properties must be null.
  final Widget? leading;

  /// The URL for the leading profile image.
  ///
  /// When null or empty, [profileInitials] or the profile fallback icon is used.
  final String? profileImageUrl;

  /// Text displayed by the leading profile fallback.
  ///
  /// Usually this should be one or two user initials.
  final String? profileInitials;

  /// Text used by accessibility services for the profile action.
  final String? profileTooltip;

  /// The radius of the leading profile picture.
  final double profilePictureRadius;

  /// The padding around the leading profile picture.
  final EdgeInsetsGeometry profilePadding;

  /// The border drawn around the leading profile picture.
  ///
  /// Defaults to a border using [ColorScheme.outlineVariant].
  final BorderSide? profileSide;

  /// The width of the default profile border when [profileSide] is null.
  final double profileSideWidth;

  /// Additional widgets displayed after the notification action.
  final List<Widget>? actions;

  /// The padding around the app bar actions.
  final EdgeInsetsGeometry actionsPadding;

  /// The unread notification count displayed in the notification badge.
  ///
  /// When null and [onNotificationTap] is null, the notification action is
  /// omitted. When null and [onNotificationTap] is provided, the badge is hidden.
  final int? notificationCount;

  /// The icon used by the notification action.
  final IconData notificationIcon;

  /// Text used by accessibility services for the notification action.
  final String? notificationTooltip;

  /// The largest value shown before the notification badge displays overflow.
  final int notificationMaxCount;

  /// Whether the app bar should imply a leading widget when [leading] and the
  /// profile action are absent.
  final bool automaticallyImplyLeading;

  /// The width allocated for [leading] or the profile action.
  final double? leadingWidth;

  /// The height of the app bar toolbar.
  final double toolbarHeight;

  /// A widget displayed across the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// The z-coordinate at which to place this app bar.
  final double? elevation;

  /// The elevation applied when content scrolls under this app bar.
  final double? scrolledUnderElevation;

  /// The app bar background color.
  ///
  /// Defaults to the ambient [AppBarTheme] and Material defaults.
  final Color? backgroundColor;

  /// The default color for text and icons in the app bar.
  ///
  /// Defaults to the ambient [AppBarTheme] and Material defaults.
  final Color? foregroundColor;

  /// The color used to paint the app bar shadow.
  final Color? shadowColor;

  /// The Material surface tint color.
  final Color? surfaceTintColor;

  /// The text style used for [title].
  ///
  /// Defaults to [TextTheme.titleLarge] with a bold weight.
  final TextStyle? titleTextStyle;

  /// Whether [title] should be centered.
  final bool centerTitle;

  /// How the app bar clips its content.
  final Clip? clipBehavior;

  /// Called when the leading profile action is tapped.
  final VoidCallback? onProfileTap;

  /// Called when the notification action is tapped.
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? effectiveTitleTextStyle =
        titleTextStyle ??
        theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface);
    final List<Widget> effectiveActions = <Widget>[
      if (notificationCount != null || onNotificationTap != null)
        IconButton(
          onPressed: onNotificationTap,
          tooltip: notificationTooltip,
          icon: Badge.count(
            count: notificationCount ?? 0,
            isLabelVisible: (notificationCount ?? 0) > 0,
            maxCount: notificationMaxCount,
            child: Icon(notificationIcon, color: colorScheme.onSurface),
          ),
        ),
      ...?actions,
    ];

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? _buildProfileAction(context),
      leadingWidth: leadingWidth,
      title: title,
      titleTextStyle: effectiveTitleTextStyle,
      centerTitle: centerTitle,
      actions: effectiveActions.isEmpty ? null : effectiveActions,
      actionsPadding: actionsPadding,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainerLow,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor ?? colorScheme.surfaceContainerLow,
      clipBehavior: clipBehavior,
    );
  }

  Widget? _buildProfileAction(BuildContext context) {
    if (profileImageUrl == null &&
        profileInitials == null &&
        onProfileTap == null) {
      return null;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderSide effectiveProfileSide =
        profileSide ??
        BorderSide(color: colorScheme.outlineVariant, width: profileSideWidth);

    final Widget profileAction = InkWell(
      customBorder: const CircleBorder(),
      onTap: onProfileTap,
      child: AppProfilePicture(
        imageUrl: profileImageUrl,
        initials: profileInitials,
        radius: profilePictureRadius,
        side: effectiveProfileSide,
      ),
    );

    return Padding(
      padding: profilePadding,
      child: profileTooltip == null
          ? profileAction
          : Tooltip(message: profileTooltip!, child: profileAction),
    );
  }

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0;

    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}
