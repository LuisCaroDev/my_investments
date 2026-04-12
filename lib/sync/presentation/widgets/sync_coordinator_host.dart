import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/auth/presentation/bloc/auth_cubit.dart';
import 'package:my_investments/auth/presentation/bloc/auth_state.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/sync/domain/usecases/sync_coordinator.dart';

class SyncCoordinatorHost extends StatefulWidget {
  final SyncCoordinator coordinator;
  final Widget child;

  const SyncCoordinatorHost({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  State<SyncCoordinatorHost> createState() => _SyncCoordinatorHostState();
}

class _SyncCoordinatorHostState extends State<SyncCoordinatorHost> {
  @override
  void initState() {
    super.initState();
    widget.coordinator.ensureInitialized();
  }

  @override
  void didUpdateWidget(covariant SyncCoordinatorHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinator != widget.coordinator) {
      oldWidget.coordinator.dispose();
      widget.coordinator.ensureInitialized();
    }
  }

  @override
  void dispose() {
    widget.coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthCubitState>(
          listenWhen: (prev, next) => next is Authenticated,
          listener: (context, state) {
            widget.coordinator.onAuthenticated();
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (prev, next) =>
              prev.syncEnabled != next.syncEnabled,
          listener: (context, state) {
            widget.coordinator.onSyncEnabledChanged(state.syncEnabled);
          },
        ),
      ],
      child: widget.child,
    );
  }
}
