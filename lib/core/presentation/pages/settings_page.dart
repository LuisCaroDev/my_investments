import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/projects/presentation/pages/import_export_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(l10n.settings_title),
          leading: [
            GhostButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(RadixIcons.chevronLeft),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Sincronización / Nube ──────────────────────────────
            Text(l10n.settings_sync_title).h4,
            const Gap(16),
            Card(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(RadixIcons.avatar),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.settings_local_mode_title).large.bold,
                            Text(l10n.settings_local_mode_info).muted,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  PrimaryButton(
                    onPressed: null, // Disabled
                    child: Text(l10n.settings_login_button),
                  ),
                ],
              ),
            ),
            const Gap(32),

            // ── Preferencias ──────────────────────────────
            Text(l10n.settings_preferences_title).h4,
            const Gap(16),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Idioma
                    CardButton(
                      onPressed: () => _showLocaleDialog(context, state),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(RadixIcons.globe),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.settings_language_label).medium,
                                  Text(
                                    _getLocaleName(context, state.appLocale),
                                  ).muted,
                                ],
                              ),
                            ),
                            const Icon(RadixIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    CardButton(
                      onPressed: () => _showThemeDialog(context, state),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(RadixIcons.moon),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.settings_theme_label).medium,
                                  Text(
                                    _getThemeModeName(context, state.themeMode),
                                  ).muted,
                                ],
                              ),
                            ),
                            const Icon(RadixIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    // Moneda
                    CardButton(
                      onPressed: () => _showCurrencyDialog(context, state),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(RadixIcons.component1),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.settings_currency_label).medium,
                                  Text(
                                    state.currencySymbol != null
                                        ? '${state.currencySymbol} (${state.currencyLocale ?? l10n.settings_system_default})'
                                        : l10n.settings_system_default,
                                  ).muted,
                                ],
                              ),
                            ),
                            const Icon(RadixIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Gap(32),

            // ── Datos ──────────────────────────────
            Text(l10n.settings_data_title).h4,
            const Gap(16),
            CardButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportExportPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(RadixIcons.upload),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.settings_import_export_label).medium,
                          Text(l10n.settings_import_export_info).muted,
                        ],
                      ),
                    ),
                    const Icon(RadixIcons.chevronRight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocaleName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return l10n.settings_system_default;
    }
  }

  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.settings_theme_light;
      case ThemeMode.dark:
        return l10n.settings_theme_dark;
      case ThemeMode.system:
        return l10n.settings_system_default;
    }
  }

  void _showLocaleDialog(BuildContext context, SettingsState state) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_language_dialog_title),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OptionButton(
                label: l10n.settings_system_default,
                isSelected: state.appLocale == 'system',
                onPressed: () {
                  context.read<SettingsCubit>().updateAppLocale('system');
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: 'Español',
                isSelected: state.appLocale == 'es',
                onPressed: () {
                  context.read<SettingsCubit>().updateAppLocale('es');
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: 'English',
                isSelected: state.appLocale == 'en',
                onPressed: () {
                  context.read<SettingsCubit>().updateAppLocale('en');
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsState state) {
    final currentVal = state.currencySymbol ?? 'system';
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_currency_label),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OptionButton(
                label: l10n.settings_system_default,
                isSelected: currentVal == 'system',
                onPressed: () {
                  context.read<SettingsCubit>().updateCurrency(null, null);
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: 'USD (\$)',
                isSelected: currentVal == '\$',
                onPressed: () {
                  context.read<SettingsCubit>().updateCurrency('en_US', '\$');
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: 'EUR (€)',
                isSelected: currentVal == '€',
                onPressed: () {
                  context.read<SettingsCubit>().updateCurrency('es_ES', '€');
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: 'PEN (S/)',
                isSelected: currentVal == 'S/',
                onPressed: () {
                  context.read<SettingsCubit>().updateCurrency('es_PE', 'S/');
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsState state) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_theme_dialog_title),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OptionButton(
                label: l10n.settings_system_default,
                isSelected: state.themeMode == ThemeMode.system,
                onPressed: () {
                  context.read<SettingsCubit>().updateThemeMode(
                    ThemeMode.system,
                  );
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: l10n.settings_theme_light,
                isSelected: state.themeMode == ThemeMode.light,
                onPressed: () {
                  context.read<SettingsCubit>().updateThemeMode(
                    ThemeMode.light,
                  );
                  Navigator.of(ctx).pop();
                },
              ),
              const Gap(8),
              _OptionButton(
                label: l10n.settings_theme_dark,
                isSelected: state.themeMode == ThemeMode.dark,
                onPressed: () {
                  context.read<SettingsCubit>().updateThemeMode(ThemeMode.dark);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return PrimaryButton(onPressed: onPressed, child: Text(label));
    }
    return OutlineButton(onPressed: onPressed, child: Text(label));
  }
}
