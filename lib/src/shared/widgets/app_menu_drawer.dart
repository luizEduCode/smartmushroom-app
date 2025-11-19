import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/src/core/di/app_dependencies.dart';
import 'package:smartmushroom_app/src/core/theme/theme_notifier.dart';
import 'package:smartmushroom_app/src/features/auth/presentation/pages/ip_page.dart';
import 'package:smartmushroom_app/src/features/auth/presentation/pages/login_screen.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSystemDark = theme.brightness == Brightness.dark;
    final authRepository = AppDependencies.instance.authRepository;
    final rawName = authRepository.user?.nome ?? '';
    final userName = rawName.trim().isEmpty ? 'Batata' : rawName.trim();
    final avatarLabel =
        userName.characters.isNotEmpty
            ? userName.characters.first.toUpperCase()
            : 'O';
    final storage = GetStorage();
    final storedIp = storage.read<String>('server_ip')?.trim();
    final bool isServerConfigured = storedIp != null && storedIp.isNotEmpty;
    final connectionLabel =
        isServerConfigured ? 'Operacao conectada' : 'IP nao configurado';
    final connectionDetail =
        isServerConfigured ? 'IP $storedIp' : 'Configure em Preferencias';
    final Color connectionColor =
        isServerConfigured ? colorScheme.tertiary : colorScheme.error;
    final IconData connectionIcon =
        isServerConfigured ? Icons.circle : Icons.warning_amber_rounded;

    return Drawer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _MenuCard(
                    backgroundColor: theme.colorScheme.secondary,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          child: Text(
                            avatarLabel,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color:
                                  isSystemDark
                                      ? Colors.white
                                      : colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    connectionIcon,
                                    size: 12,
                                    color: connectionColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        connectionLabel,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        connectionDetail,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.85),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _MenuSectionLabel(text: 'Preferencias'),
                          Consumer<ThemeViewModel>(
                            builder: (_, themeViewModel, __) {
                              final bool isDarkMode = themeViewModel.isDarkMode;
                              final String modeLabel =
                                  isDarkMode ? 'Modo escuro' : 'Modo claro';
                              final IconData themeIcon =
                                  isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode;
                              final Color iconColor = colorScheme.primary;
                              final Color themeCardColor =
                                  isDarkMode
                                      ? colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.9)
                                      : colorScheme.secondaryContainer
                                          .withValues(alpha: 0.85);
                              return _MenuCard(
                                backgroundColor: themeCardColor,
                                child: Row(
                                  children: [
                                    _IconBadge(
                                      icon: themeIcon,
                                      color: iconColor,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tema',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            modeLabel,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: isDarkMode,
                                      activeThumbColor: colorScheme.primary,
                                      onChanged:
                                          (_) => themeViewModel.toggleTheme(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _MenuSectionLabel(text: 'Sistema'),
                          _MenuCard(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ConfigIPPage(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                _IconBadge(
                                  icon: Icons.route_outlined,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Configurar IP',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Defina o servidor ativo',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _MenuCard(
                    onTap: () => _confirmLogout(context),
                    child: Row(
                      children: [
                        _IconBadge(
                          icon: Icons.logout,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logout',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Encerrar sessao',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward,
                          color: colorScheme.error.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SmartMushroom - Monitoramento inteligente',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSectionLabel extends StatelessWidget {
  const _MenuSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          letterSpacing: 0.6,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.child, this.onTap, this.backgroundColor});

  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(24);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor ?? colorScheme.surfaceContainerHigh,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 48,
      child: Center(child: Icon(icon, color: color)),
    );
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final shouldLogout = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Encerrar sessao'),
          content: const Text('Tem certeza de que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sair'),
            ),
          ],
        ),
  );

  if (shouldLogout != true) return;

  navigator.pop();

  try {
    await AppDependencies.instance.authRepository.logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  } catch (_) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel realizar o logout. Tente novamente.'),
        ),
      );
  }
}
