import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/core/widgets/stat_card.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart'
    as domain;
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/project_detail_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/project_detail_state.dart';
import 'package:my_investments/projects/presentation/pages/activity_detail_page.dart';
import 'package:my_investments/projects/presentation/pages/category_management_page.dart';
import 'package:my_investments/projects/presentation/pages/transaction_list_page.dart';
import 'package:my_investments/projects/presentation/widgets/add_activity_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/add_transaction_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/budget_progress.dart';
import 'package:my_investments/projects/presentation/widgets/section_header.dart';
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';

class ProjectDetailPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
    required this.projectName,
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
        final ds = ProjectsLocalDataSource(prefs: snapshot.data!);
        final repo = ProjectsRepository(localDataSource: ds);
        return BlocProvider(
          create: (_) =>
              ProjectDetailCubit(repository: repo, projectId: projectId)
                ..load(),
          child: _ProjectDetailView(projectName: projectName),
        );
      },
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  final String projectName;

  const _ProjectDetailView({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        return Scaffold(
          headers: [
            AppBar(
              leading: [
                IconButton.ghost(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(RadixIcons.arrowLeft),
                ),
              ],
              title: Text(projectName),
            ),
          ],
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProjectDetailState state) {
    return switch (state) {
      ProjectDetailLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      ProjectDetailError(message: final msg) => Center(
        child: Text('Error: $msg'),
      ),
      ProjectDetailLoaded() => _ProjectDetailContent(state: state),
    };
  }
}

class _ProjectDetailContent extends StatelessWidget {
  final ProjectDetailLoaded state;

  const _ProjectDetailContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OutlineButton(
                  onPressed: () => _openCategoryManagement(context),
                  size: ButtonSize.small,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.bookmarkFilled, size: 14),
                      Gap(6),
                      Text('Categorías'),
                    ],
                  ),
                ),
                const Gap(6),
                PrimaryButton(
                  onPressed: () => _addActivity(context),
                  size: ButtonSize.small,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.plus, size: 14),
                      Gap(6),
                      Text('Actividad'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          // ── Budget Summary ───────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Depositado',
                  value: state.totalDeposited.toCompactCurrency(),
                  icon: RadixIcons.arrowUp,
                  valueColor: theme.colorScheme.primary,
                ),
              ),
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Gastado',
                  value: state.totalSpent.toCompactCurrency(),
                  icon: RadixIcons.arrowDown,
                  valueColor: theme.colorScheme.destructive,
                ),
              ),
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Balance',
                  value: state.balance.toCompactCurrency(),
                  icon: RadixIcons.dimensions,
                ),
              ),
              if (state.totalBudget > 0)
                SizedBox(
                  width: 200,
                  child: StatCard(
                    label: 'Presupuesto',
                    value: state.totalBudget.toCompactCurrency(),
                    icon: RadixIcons.target,
                  ),
                ),
            ],
          ),

          if (state.totalBudget > 0) ...[
            const Gap(16),
            Card(
              padding: const EdgeInsets.all(16),
              child: BudgetProgress(
                budget: state.totalBudget,
                deposited: state.totalDeposited,
                spent: state.totalSpent,
                formatCurrency: (v) => v.toCompactCurrency(),
              ),
            ),
          ],

          // ── Categories ───────────────────────
          if (state.projectCategories.isNotEmpty) ...[
            const Gap(24),
            const Text('Categorías del Proyecto').medium,
            const Gap(8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: state.projectCategories
                  .map((cat) => Chip(child: Text(cat.name)))
                  .toList(),
            ),
          ],

          // ── Project-Level Transactions ───────
          const Gap(24),
          SectionHeader(
            title: 'Ultimas transacciones',
            actionLabel: 'Ver mas',
            onAction: () => _openTransactionList(context),
          ),
          const Gap(12),
          if (state.projectLevelTransactions.isEmpty)
            const EmptyState(
              icon: RadixIcons.cardStack,
              title: 'Sin transacciones',
              subtitle: 'Agrega gastos o depósitos para este proyecto.',
            )
          else
            ..._latestTransactions(state.projectLevelTransactions).map(
              (t) => TransactionTile(
                transaction: t,
                categories: state.projectCategories,
                onEdit: () => _editTransaction(context, t),
                onDelete: () {
                  context.read<ProjectDetailCubit>().deleteTransaction(t.id);
                },
              ),
            ),

          // ── Activities ───────────────────────
          const Gap(24),
          const Text('Actividades').large.bold,
          const Gap(12),
          if (state.activitySummaries.isEmpty)
            const EmptyState(
              icon: RadixIcons.layers,
              title: 'Sin actividades',
              subtitle:
                  'Agrega actividades para organizar las fases '
                  'de tu proyecto.',
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: state.activitySummaries
                  .map(
                    (s) =>
                        SizedBox(
                          width: 340,
                          child: _ActivityCard(
                            summary: s,
                            onEdit: () => _editActivity(context, s.activity),
                            onDelete: () => _confirmDeleteActivity(
                              context,
                              s.activity,
                            ),
                          ),
                        ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  void _openCategoryManagement(BuildContext context) {
    final cubit = context.read<ProjectDetailCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryManagementPage(
          projectId: cubit.projectId,
          title: 'Categorías del Proyecto',
        ),
      ),
    );
  }

  void _openTransactionList(BuildContext context) {
    final cubit = context.read<ProjectDetailCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionListPage(
          projectId: cubit.projectId,
          title: 'Transacciones',
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) async {
    final state = context.read<ProjectDetailCubit>().state;
    if (state is! ProjectDetailLoaded) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.projectCategories,
        initialTransaction: transaction,
      ),
    );
    if (result != null && context.mounted) {
      final cubit = context.read<ProjectDetailCubit>();
      final updated = transaction.copyWith(
        type: result['type'] as TransactionType,
        amount: result['amount'] as double,
        date: result['date'] as DateTime,
        description: result['description'] as String?,
        categoryId: result['categoryId'] as String?,
      );
      cubit.updateTransaction(updated);
    }
  }

  List<Transaction> _latestTransactions(List<Transaction> items) {
    final sorted = List<Transaction>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  void _addActivity(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const AddActivityDialog(),
    );
    if (result != null && context.mounted) {
      final cubit = context.read<ProjectDetailCubit>();
      final activity = Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        name: result['name'] as String,
        description: result['description'] as String?,
        year: result['year'] as int?,
        budget: result['budget'] as double?,
        createdAt: DateTime.now(),
      );
      cubit.addActivity(activity);
    }
  }

  void _editActivity(BuildContext context, Activity activity) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddActivityDialog(
        initialName: activity.name,
        initialDescription: activity.description,
        initialYear: activity.year,
        initialBudget: activity.budget,
      ),
    );
    if (result != null && context.mounted) {
      final cubit = context.read<ProjectDetailCubit>();
      final updated = activity.copyWith(
        name: result['name'] as String,
        description: result['description'] as String?,
        year: result['year'] as int?,
        budget: result['budget'] as double?,
      );
      cubit.updateActivity(updated);
    }
  }

  void _confirmDeleteActivity(BuildContext context, Activity activity) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Escribe el nombre de la actividad para confirmar:',
              ).small,
              const Gap(8),
              TextField(
                controller: controller,
                placeholder: Text(activity.name),
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            onPressed: () {
              if (controller.text.trim() != activity.name.trim()) return;
              Navigator.of(ctx).pop();
              context.read<ProjectDetailCubit>().deleteActivity(activity.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivitySummary summary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.summary,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ProjectDetailCubit>();

    return CardButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityDetailPage(
              projectId: cubit.projectId,
              activityId: summary.activity.id,
              activityName: summary.activity.name,
            ),
          ),
        );
        if (context.mounted) {
          cubit.load();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    RadixIcons.layers,
                    size: 16,
                    color: theme.colorScheme.secondaryForeground,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary.activity.name).medium,
                      if (summary.activity.year != null)
                        Text('Año ${summary.activity.year}').muted.small,
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SecondaryBadge(
                      child: Text('${summary.transactionCount} tx'),
                    ),
                    const Gap(4),
                    IconButton.ghost(
                      onPressed: () => _showActionsMenu(context),
                      icon: const Icon(RadixIcons.dotsVertical, size: 16),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(12),
            if (summary.budget > 0)
              BudgetProgress(
                budget: summary.budget,
                deposited: summary.deposited,
                spent: summary.spent,
                formatCurrency: (v) => v.toCompactCurrency(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dep: ${summary.deposited.toCompactCurrency()}',
                  ).small(color: theme.colorScheme.primary),
                  Text(
                    'Gasto: ${summary.spent.toCompactCurrency()}',
                  ).small(color: theme.colorScheme.destructive),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    showDropdown<void>(
      context: context,
      anchorAlignment: Alignment.bottomRight,
      alignment: Alignment.topRight,
      builder: (ctx) => DropdownMenu(
        children: [
          MenuButton(
            leading: const Icon(RadixIcons.pencil1),
            child: const Text('Editar'),
            onPressed: (_) => onEdit(),
          ),
          MenuButton(
            leading: const Icon(RadixIcons.trash),
            child: const Text('Eliminar'),
            onPressed: (_) => onDelete(),
          ),
        ],
      ),
    );
  }
}
