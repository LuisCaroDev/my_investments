import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart'
    as domain;
import 'package:my_investments/planning/presentation/bloc/operational_task_management_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/operational_task_management_state.dart';
import 'package:my_investments/planning/presentation/widgets/add_operational_task_dialog.dart';
import 'package:my_investments/planning/presentation/widgets/operational_task_tile.dart';

class OperationalTaskManagementPage extends StatelessWidget {
  final String projectId;
  final String title;
  final String? activityId;

  const OperationalTaskManagementPage({
    super.key,
    required this.projectId,
    required this.title,
    this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final planningDs = PlanningLocalDataSource(prefs: snapshot.data!);
        final accountsDs = AccountsLocalDataSource(prefs: snapshot.data!);
        final accountsRepo = AccountsRepository(localDataSource: accountsDs);
        final planningRepo = PlanningRepository(
          localDataSource: planningDs,
          transactionsReader: accountsRepo,
        );
        return BlocProvider(
          create: (_) => OperationalTaskManagementCubit(
            repository: planningRepo,
            projectId: projectId,
            activityId: activityId,
          )..load(),
          child: _OperationalTaskManagementView(title: title),
        );
      },
    );
  }
}

class _OperationalTaskManagementView extends StatelessWidget {
  final String title;

  const _OperationalTaskManagementView({required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperationalTaskManagementCubit,
        OperationalTaskManagementState>(
      builder: (context, state) {
        return Scaffold(
          headers: [
            AppBar(
              leading: [
                ...AppBackButton.render(context),
              ],
              title: Text(title),
            ),
            Divider(height: 1),
          ],
          floatingFooter: true,
          footers: [
            Align(
              alignment: Alignment.bottomRight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    onPressed: () => _addCategory(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RadixIcons.plus, size: 16),
                        const Gap(6),
                        Text(AppLocalizations.of(context)!.common_category),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    OperationalTaskManagementState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      bottom: false,
      child: switch (state) {
        OperationalTaskManagementLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        OperationalTaskManagementError(message: final msg) => Center(
          child: Text(l10n.common_error_msg(msg)),
        ),
        OperationalTaskManagementLoaded() =>
          _OperationalTaskManagementContent(state: state),
      },
    );
  }

  void _addCategory(BuildContext context) async {
    final cubit = context.read<OperationalTaskManagementCubit>();
    final isProjectLevel = cubit.activityId == null;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) =>
          AddOperationalTaskDialog(isProjectLevel: isProjectLevel),
    );
    if (result != null && context.mounted) {
      final task = domain.OperationalTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        activityId: cubit.activityId,
        name: result,
      );
      cubit.addOperationalTask(task);
    }
  }
}

class _OperationalTaskManagementContent extends StatelessWidget {
  final OperationalTaskManagementLoaded state;

  const _OperationalTaskManagementContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasActivityScope =
        context.read<OperationalTaskManagementCubit>().activityId != null;

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: theme.density.baseContentPadding,
        left: theme.density.baseContentPadding,
        right: theme.density.baseContentPadding,
        bottom: theme.density.baseContentPadding + 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasActivityScope) ...[
            Text(l10n.category_mgmt_activity_title).medium,
            const Gap(8),
            if (state.activityOperationalTasks.isEmpty)
              Text(l10n.category_mgmt_empty).muted
            else
              ...state.activityOperationalTasks.map(
                (task) => OperationalTaskTile(
                  task: task,
                  onEdit: () => _editCategory(context, task),
                  onDelete: () => _deleteCategory(context, task),
                ),
              ),
            const Gap(20),
          ],
          Text(l10n.category_mgmt_project_title).medium,
          const Gap(8),
          if (state.projectOperationalTasks.isEmpty)
            Text(l10n.category_mgmt_empty).muted
          else
            ...state.projectOperationalTasks.map(
              (task) => OperationalTaskTile(
                task: task,
                onEdit: () => _editCategory(context, task),
                onDelete: () => _deleteCategory(context, task),
              ),
            ),
        ],
      ),
    );
  }

  void _editCategory(BuildContext context, domain.OperationalTask task) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AddOperationalTaskDialog(
        isProjectLevel: task.activityId == null,
        initialName: task.name,
      ),
    );
    if (result != null && context.mounted) {
      context.read<OperationalTaskManagementCubit>().updateOperationalTask(
        task.copyWith(name: result),
      );
    }
  }

  void _deleteCategory(BuildContext context, domain.OperationalTask task) {
    context.read<OperationalTaskManagementCubit>().deleteOperationalTask(task.id);
  }
}
