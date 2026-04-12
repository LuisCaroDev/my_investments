import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/core/widgets/responsive_container.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/router/app_router.dart';
import 'package:my_investments/l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      child: LayoutBuilder(
        builder: (context, contrains) {
          return SingleChildScrollView(
            child: SafeArea(
              child: ResponsiveContainer(
                minHeight: contrains.minHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 48.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono / Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.foreground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          RadixIcons.lightningBolt,
                          size: 40,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                    const Gap(32),
                    Text(
                      l10n.welcome_title_prefix,
                      textAlign: TextAlign.center,
                    ).h3,
                    Text(
                      l10n.welcome_title_suffix,
                      style: theme.typography.h3.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    Text(
                      l10n.welcome_subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ).xSmall,
                    const Gap(48),

                    // Features
                    _buildFeatureItem(
                      context,
                      icon: RadixIcons.cube,
                      title: l10n.welcome_feature1_title,
                      description: l10n.welcome_feature1_desc,
                    ),
                    const Gap(24),
                    _buildFeatureItem(
                      context,
                      icon: RadixIcons.update,
                      title: l10n.welcome_feature2_title,
                      description: l10n.welcome_feature2_desc,
                    ),
                    const Gap(24),
                    _buildFeatureItem(
                      context,
                      icon: RadixIcons.eyeNone,
                      title: l10n.welcome_feature3_title,
                      description: l10n.welcome_feature3_desc,
                    ),

                    const Gap(32),

                    // Buttons
                    PrimaryButton(
                      onPressed: () {
                        context.appRouter.push(
                          const LoginRoute(fromSettings: false),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.welcome_login_button),
                          const Gap(8),
                          const Icon(RadixIcons.arrowRight, size: 16),
                        ],
                      ),
                    ),
                    const Gap(16),
                    OutlineButton(
                      onPressed: () {
                        context.read<SettingsCubit>().setGuestMode(true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text(l10n.welcome_guest_button)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.primary.withLuminance(.95)
                : theme.colorScheme.primary.withLuminance(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title).normal.bold,
              const Gap(4),
              Text(
                description,
                style: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                ),
              ).small,
            ],
          ),
        ),
      ],
    );
  }
}
