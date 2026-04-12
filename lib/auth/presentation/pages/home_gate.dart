import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/auth/presentation/bloc/auth_cubit.dart';
import 'package:my_investments/auth/presentation/bloc/auth_state.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/planning/presentation/pages/main_navigation_shell.dart';
import 'package:my_investments/auth/presentation/pages/welcome_page.dart';
import 'package:my_investments/core/storage/profile_ids.dart';

class HomeGate extends StatelessWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthCubitState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          final expected = userProfileId(authState.user.id);
          final settings = context.read<SettingsCubit>().state;
          if (settings.activeProfileId != expected) {
            context.read<SettingsCubit>().setActiveProfileId(expected);
          }
        }
      },
      child: BlocBuilder<AuthCubit, AuthCubitState>(
        builder: (context, authState) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final isAuthenticated = authState is Authenticated;
              final isGuest = settingsState.isGuestMode;

              if (isAuthenticated || isGuest) {
                return const MainNavigationShell();
              }

              return const WelcomePage();
            },
          );
        },
      ),
    );
  }
}
