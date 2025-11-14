import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/core/theme/theme_notifier.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final bool enableThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
    this.enableThemeToggle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color foregroundColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    return AppBar(
      leading:
          showBackButton
              ? IconButton(
                icon: Icon(Icons.arrow_back, color: foregroundColor),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
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
      actions: [
        ...?actions,
        if (enableThemeToggle) const _ThemeToggleButton(),
      ],
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, _) {
        final isDark = themeViewModel.isDarkMode;
        return IconButton(
          tooltip: isDark ? 'Alternar para modo claro' : 'Alternar para modo escuro',
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: color,
          ),
          onPressed: themeViewModel.toggleTheme,
        );
      },
    );
  }
}
