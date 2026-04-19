import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:go_router/go_router.dart';
import 'package:my_investments/auth/presentation/pages/login_page.dart';
import 'package:my_investments/planning/presentation/pages/import_export_page.dart';
import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/core/constants/supabase_config.dart';
import 'package:my_investments/accounts/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/investments_cubit.dart';
import 'package:my_investments/sync/data/repositories/sync_repository.dart';
import 'package:my_investments/sync/domain/usecases/sync_service.dart';
import 'package:my_investments/core/storage/profile_ids.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';

class SettingsPage extends StatefulWidget {
  static const route = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _syncWorking = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsCubit>().state;
    final syncRepo = context.watch<SyncRepository>();

    final isConfigured = SupabaseConfig.isConfigured;
    final user = isConfigured
        ? Supabase.instance.client.auth.currentUser
        : null;
    final isLoggedIn = user != null;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(l10n.settings_title),
          leading: [...AppBackButton.render(context)],
        ),
        Divider(height: 1),
      ],
      child: SingleChildScrollView(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Cuenta ──────────────────────────────
                Text(l10n.settings_account_title).h4,
                const Gap(16),
                _buildAccountCard(
                  context,
                  theme: theme,
                  l10n: l10n,
                  settingsState: settingsState,
                  isLoggedIn: isLoggedIn,
                  user: user,
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
                        const Gap(8),
                        CardButton(
                          onPressed: () => _showThemeDialog(context, state),
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
                                      _getThemeModeName(
                                        context,
                                        state.themeMode,
                                      ),
                                    ).muted,
                                  ],
                                ),
                              ),
                              const Icon(RadixIcons.chevronRight),
                            ],
                          ),
                        ),
                        const Gap(8),
                        // Moneda
                        CardButton(
                          onPressed: () => _showCurrencyDialog(context, state),
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
                      ],
                    );
                  },
                ),
                const Gap(32),

                // ── Datos y Sincronización ──────────────────────────────
                Text(l10n.settings_data_sync_title).h4,
                const Gap(16),
                _buildSyncCard(
                  context,
                  theme: theme,
                  l10n: l10n,
                  settingsState: settingsState,
                  syncRepo: syncRepo,
                  isLoggedIn: isLoggedIn,
                ),
                const Gap(8),
                CardButton(
                  onPressed: () {
                    context.push(ImportExportPage.route);
                  },
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context, {
    required ThemeData theme,
    required AppLocalizations l10n,
    required SettingsState settingsState,
    required bool isLoggedIn,
    User? user,
  }) {
    return Card(
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
                    Text(
                      isLoggedIn
                          ? (user?.email ?? l10n.settings_sync_logged_in)
                          : l10n.settings_local_mode_title,
                    ).medium.bold,
                    Text(
                      isLoggedIn
                          ? l10n.settings_sync_logged_in_info
                          : l10n.settings_local_mode_info,
                    ).xSmall.muted,
                  ],
                ),
              ),
            ],
          ),
          if (!isLoggedIn) ...[
            const Gap(16),
            PrimaryButton(
              onPressed: _syncWorking ? null : () => _login(context),
              child: Text(l10n.settings_login_button),
            ),
            if (settingsState.isGuestMode) ...[
              const Gap(8),
              OutlineButton(
                onPressed: _syncWorking ? null : _logoutGuest,
                child: Text(l10n.settings_guest_logout_button),
              ),
            ],
          ] else ...[
            const Gap(16),
            OutlineButton(
              onPressed: _syncWorking ? null : _logout,
              child: Text(l10n.settings_logout_button),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncCard(
    BuildContext context, {
    required ThemeData theme,
    required AppLocalizations l10n,
    required SettingsState settingsState,
    required SyncRepository syncRepo,
    required bool isLoggedIn,
  }) {
    final pendingCount = syncRepo.getPendingChanges().length;
    final lastSync = syncRepo.getLastSync();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.settings_sync_status_label).small.bold,
          const Gap(6),
          Text(
            '${l10n.settings_sync_last_sync_label}: '
            '${lastSync?.toLocal().toIso8601String() ?? l10n.settings_sync_never}',
          ).xSmall.muted,
          Text(
            '${l10n.settings_sync_pending_label}: $pendingCount',
          ).xSmall.muted,
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settings_sync_mode_title).medium,
                    Text(l10n.settings_sync_mode_info).xSmall.muted,
                  ],
                ),
              ),
              Switch(
                value: settingsState.syncEnabled,
                onChanged: isLoggedIn
                    ? (value) =>
                          context.read<SettingsCubit>().setSyncEnabled(value)
                    : null,
              ),
            ],
          ),
          const Gap(16),
          PrimaryButton(
            onPressed: isLoggedIn && !_syncWorking
                ? () => _backupNow(context)
                : null,
            child: Text(l10n.settings_sync_backup_button),
          ),
          const Gap(8),
          OutlineButton(
            onPressed: isLoggedIn && !_syncWorking
                ? () => _restoreNow(context)
                : null,
            child: Text(l10n.settings_sync_restore_button),
          ),
        ],
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

  Future<void> _login(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) {
      await _showInfoDialog(
        context,
        title: l10n.settings_sync_error_title,
        message: l10n.settings_sync_not_configured,
      );
      return;
    }

    await context.push('${LoginPage.route}?fromSettings=true');

    // Check if we logged in
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      await context.read<SettingsCubit>().setSyncEnabled(false);
      await context.read<SettingsCubit>().setActiveProfileId(guestProfileId);
      await context.read<SettingsCubit>().setGuestMode(false);
      setState(() {});
      context.go('/');
    }
  }

  Future<void> _logoutGuest() async {
    if (!mounted) return;
    await context.read<SettingsCubit>().setSyncEnabled(false);
    await context.read<SettingsCubit>().setActiveProfileId(guestProfileId);
    await context.read<SettingsCubit>().setGuestMode(false);
    setState(() {});
    context.go('/');
  }

  Future<void> _backupNow(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) {
      await _showInfoDialog(
        context,
        title: l10n.settings_sync_error_title,
        message: l10n.settings_sync_not_configured,
      );
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      await _showInfoDialog(
        context,
        title: l10n.settings_sync_error_title,
        message: l10n.settings_sync_not_logged_in,
      );
      return;
    }

    setState(() => _syncWorking = true);
    try {
      final service = context.read<SyncService>();
      final planningDs = context.read<PlanningLocalDataSource>();
      final accountsDs = context.read<AccountsLocalDataSource>();
      await service.pushSnapshot(
        userId: user.id,
        providers: [planningDs, accountsDs],
      );
      if (context.mounted) {
        await _showInfoDialog(
          context,
          title: l10n.settings_sync_status_label,
          message: l10n.settings_sync_backup_success,
        );
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        await _showInfoDialog(
          context,
          title: l10n.settings_sync_error_title,
          // message: 'adsd'
          message: l10n.common_error_msg(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _syncWorking = false);
      }
    }
  }

  Future<void> _restoreNow(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) {
      await _showInfoDialog(
        context,
        title: l10n.settings_sync_error_title,
        message: l10n.settings_sync_not_configured,
      );
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      await _showInfoDialog(
        context,
        title: l10n.settings_sync_error_title,
        message: l10n.settings_sync_not_logged_in,
      );
      return;
    }

    setState(() => _syncWorking = true);
    try {
      final service = context.read<SyncService>();
      final planningDs = context.read<PlanningLocalDataSource>();
      final accountsDs = context.read<AccountsLocalDataSource>();
      final outcome = await service.pullIfRemoteNewer(
        userId: user.id,
        providers: [planningDs, accountsDs],
      );
      if (context.mounted) {
        switch (outcome) {
          case SyncPullOutcome.noRemote:
            await _showInfoDialog(
              context,
              title: l10n.settings_sync_status_label,
              message: l10n.settings_sync_restore_not_found,
            );
            break;
          case SyncPullOutcome.upToDate:
            await _showInfoDialog(
              context,
              title: l10n.settings_sync_status_label,
              message: l10n.settings_sync_up_to_date,
            );
            break;
          case SyncPullOutcome.pulled:
            context.read<InvestmentsCubit>().loadInvestments();
            context.read<GoalsCubit>().loadGoals();
            context.read<AccountsCubit>().loadAccounts();
            await _showInfoDialog(
              context,
              title: l10n.settings_sync_status_label,
              message: l10n.settings_sync_restore_success,
            );
            break;
        }
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        await _showInfoDialog(
          context,
          title: l10n.settings_sync_error_title,
          message: l10n.common_error_msg(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _syncWorking = false);
      }
    }
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_close),
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
