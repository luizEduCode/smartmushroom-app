import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color foregroundColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    Widget? leading;
    if (showMenuButton) {
      leading = IconButton(
        icon: Icon(Icons.menu, color: foregroundColor),
        onPressed: onMenuPressed,
      );
    } else if (showBackButton) {
      leading = IconButton(
        icon: Icon(Icons.arrow_back, color: foregroundColor),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle ??
            TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }
}
