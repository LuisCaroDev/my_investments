import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/core/widgets/stat_card.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/presentation/bloc/projects_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/projects_state.dart';
import 'package:my_investments/projects/presentation/pages/import_export_page.dart';
import 'package:my_investments/projects/presentation/pages/project_detail_page.dart';
import 'package:my_investments/projects/presentation/widgets/add_project_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/budget_progress.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Mis Inversiones'),
          trailing: [
            GhostButton(
              onPressed: () => _openImportExport(context),
              size: ButtonSize.small,
              child: const Icon(RadixIcons.upload),
            ),
          ],
        ),
      ],
      floatingFooter: true,
      footers: [
        Align(
          alignment: Alignment.bottomRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                onPressed: () => _showAddProjectDialog(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RadixIcons.plus, size: 16),
                    Gap(6),
                    Text('Nuevo Proyecto'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      child: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          return switch (state) {
            ProjectsInitial() || ProjectsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProjectsError(message: final msg) => Center(
                child: Text('Error: $msg'),
              ),
            ProjectsLoaded(summaries: final summaries) =>
              summaries.isEmpty
                  ? EmptyState(
                      icon: RadixIcons.archive,
                      title: 'Aún no tienes proyectos',
                      subtitle:
                          'Crea tu primer proyecto de inversión para comenzar a registrar gastos y presupuestos.',
                    )
                  : _ProjectsList(summaries: summaries),
          };
        },
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const AddProjectDialog(),
    );
    if (result != null && context.mounted) {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name'] as String,
        description: result['description'] as String?,
        globalBudget: result['budget'] as double?,
        createdAt: DateTime.now(),
      );
      context.read<ProjectsCubit>().addProject(project);
    }
  }

  void _openImportExport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ImportExportPage()),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  final List<ProjectSummary> summaries;

  const _ProjectsList({required this.summaries});

  @override
  Widget build(BuildContext context) {
    // Calculate portfolio totals
    final totalBudget =
        summaries.fold(0.0, (sum, s) => sum + s.totalBudget);
    final totalSpent =
        summaries.fold(0.0, (sum, s) => sum + s.totalSpent);
    final totalDeposited =
        summaries.fold(0.0, (sum, s) => sum + s.totalDeposited);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Portfolio Summary ─────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Inversión Total',
                  value: totalDeposited.toCompactCurrency(),
                  icon: RadixIcons.barChart,
                ),
              ),
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Gasto Total',
                  value: totalSpent.toCompactCurrency(),
                  icon: RadixIcons.minusCircled,
                  valueColor: Theme.of(context).colorScheme.destructive,
                ),
              ),
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Presupuesto',
                  value: totalBudget.toCompactCurrency(),
                  icon: RadixIcons.target,
                ),
              ),
              SizedBox(
                width: 200,
                child: StatCard(
                  label: 'Proyectos',
                  value: summaries.length.toString(),
                  icon: RadixIcons.cube,
                ),
              ),
            ],
          ),
          const Gap(24),

          // ── Projects Grid ────────────────────
          const Text('Proyectos').large.bold,
          const Gap(12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: summaries
                .map((s) => SizedBox(
                      width: 340,
                      child: _ProjectCard(summary: s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectSummary summary;

  const _ProjectCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectDetailPage(
              projectId: summary.project.id,
              projectName: summary.project.name,
            ),
          ),
        );
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    RadixIcons.cube,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary.project.name).medium,
                      if (summary.project.description != null)
                        Text(summary.project.description!).muted.small,
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SecondaryBadge(
                      child: Text('${summary.activityCount} act.'),
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
            const Gap(16),
            if (summary.totalBudget > 0)
              BudgetProgress(
                budget: summary.totalBudget,
                deposited: summary.totalDeposited,
                spent: summary.totalSpent,
                formatCurrency: (v) => v.toCompactCurrency(),
              ),
            if (summary.totalBudget == 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Depositado').muted.small,
                      Text(summary.totalDeposited.toCompactCurrency())
                          .semiBold(color: theme.colorScheme.primary),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Gastado').muted.small,
                      Text(summary.totalSpent.toCompactCurrency())
                          .semiBold(color: theme.colorScheme.destructive),
                    ],
                  ),
                ],
              ),
            ],
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
            onPressed: (_) => _editProject(context),
          ),
          MenuButton(
            leading: const Icon(RadixIcons.trash),
            child: const Text('Eliminar'),
            onPressed: (_) => _confirmDeleteProject(context),
          ),
        ],
      ),
    );
  }

  void _editProject(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddProjectDialog(
        initialName: summary.project.name,
        initialDescription: summary.project.description,
        initialBudget: summary.project.globalBudget,
      ),
    );
    if (result != null && context.mounted) {
      final updated = summary.project.copyWith(
        name: result['name'] as String,
        description: result['description'] as String?,
        globalBudget: result['budget'] as double?,
      );
      context.read<ProjectsCubit>().updateProject(updated);
    }
  }

  void _confirmDeleteProject(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escribe el nombre del proyecto para confirmar. '
                'Se eliminarán sus actividades, categorías y transacciones.',
              ).small,
              const Gap(8),
              TextField(
                controller: controller,
                placeholder: Text(summary.project.name),
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            onPressed: () {
              if (controller.text.trim() != summary.project.name.trim()) return;
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProjectsCubit>().deleteProject(summary.project.id);
    }
  }
}
