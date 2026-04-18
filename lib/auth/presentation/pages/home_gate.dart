import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_investments/auth/presentation/bloc/auth_cubit.dart';
import 'package:my_investments/auth/presentation/bloc/auth_state.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/auth/presentation/pages/welcome_page.dart';
import 'package:my_investments/planning/presentation/pages/investments_page.dart';
import 'package:my_investments/core/storage/profile_ids.dart';

class HomeGate extends StatefulWidget {
  const HomeGate({super.key});

  static const route = '/';

  @override
  State<HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<HomeGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNavigation(context);
    });
  }

  void _checkNavigation(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    final isAuthenticated = authState is Authenticated;
    final isGuest = settingsState.isGuestMode;

    if (isAuthenticated || isGuest) {
      context.go(InvestmentsPage.route);
    } else {
      context.go(WelcomePage.route);
    }
  }

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
        _checkNavigation(context);
      },
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          _checkNavigation(context);
        },
        child: const Center(
          child:
              SizedBox.shrink(), // Or a loading spinner if splash is desired
        ),
      ),
    );
  }
}
