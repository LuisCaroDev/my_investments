import 'package:flutter/material.dart' show MaterialPageRoute; // For MaterialPageRoute
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/projects/presentation/pages/import_export_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Configuración'),
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
            const Text('Sincronización y Cuenta').h4,
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
                            const Text('Modo Local Independiente').large.bold,
                            const Text('Tus datos se guardan en este dispositivo.').muted,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const PrimaryButton(
                    onPressed: null, // Disabled
                    child: Text('Iniciar Sesión (Próximamente)'),
                  ),
                ],
              ),
            ),
            const Gap(32),

            // ── Preferencias ──────────────────────────────
            const Text('Preferencias').h4,
            const Gap(16),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return Card(
                  padding: const EdgeInsets.all(8),
                  child: Column(
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
                                    const Text('Idioma de la App').medium,
                                    Text(_getLocaleName(state.appLocale)).muted,
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
                                    const Text('Tipo de Moneda').medium,
                                    Text(
                                      state.currencySymbol != null
                                          ? '${state.currencySymbol} (${state.currencyLocale ?? "Por Defecto"})'
                                          : 'Por Defecto del Sistema',
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
                  ),
                );
              },
            ),
            const Gap(32),

            // ── Datos ──────────────────────────────
            const Text('Datos').h4,
            const Gap(16),
            Card(
              padding: const EdgeInsets.all(8),
              child: CardButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ImportExportPage(),
                    ),
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
                            const Text('Importar / Exportar JSON').medium,
                            const Text('Respalda tus datos manualmente').muted,
                          ],
                        ),
                      ),
                      const Icon(RadixIcons.chevronRight),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocaleName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Sistema';
    }
  }

  void _showLocaleDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OptionButton(
              label: 'Sistema',
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
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsState state) {
    final currentVal = state.currencySymbol ?? 'system';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tipo de Moneda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OptionButton(
              label: 'Por Defecto del Sistema',
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
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
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
      return PrimaryButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return OutlineButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
