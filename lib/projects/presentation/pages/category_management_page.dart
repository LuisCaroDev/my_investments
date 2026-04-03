import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/category.dart'
    as domain;
import 'package:my_investments/projects/presentation/bloc/category_management_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/category_management_state.dart';
import 'package:my_investments/projects/presentation/widgets/add_category_dialog.dart';

class CategoryManagementPage extends StatelessWidget {
  final String projectId;
  final String title;
  final String? activityId;

  const CategoryManagementPage({
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
        final ds = ProjectsLocalDataSource(prefs: snapshot.data!);
        final repo = ProjectsRepository(localDataSource: ds);
        return BlocProvider(
          create: (_) => CategoryManagementCubit(
            repository: repo,
            projectId: projectId,
            activityId: activityId,
          )..load(),
          child: _CategoryManagementView(title: title),
        );
      },
    );
  }
}

class _CategoryManagementView extends StatelessWidget {
  final String title;

  const _CategoryManagementView({required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryManagementCubit, CategoryManagementState>(
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
              title: Text(title),
              trailing: [
                PrimaryButton(
                  onPressed: () => _addCategory(context),
                  size: ButtonSize.small,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(RadixIcons.plus, size: 14),
                      const Gap(6),
                      Text(AppLocalizations.of(context)!.common_category),
                    ],
                  ),
                ),
              ],
            ),
          ],
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CategoryManagementState state) {
    final l10n = AppLocalizations.of(context)!;
    return switch (state) {
      CategoryManagementLoading() =>
        const Center(child: CircularProgressIndicator()),
      CategoryManagementError(message: final msg) =>
        Center(child: Text(l10n.common_error_msg(msg))),
      CategoryManagementLoaded() => _CategoryManagementContent(state: state),
    };
  }

  void _addCategory(BuildContext context) async {
    final cubit = context.read<CategoryManagementCubit>();
    final isProjectLevel = cubit.activityId == null;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AddCategoryDialog(isProjectLevel: isProjectLevel),
    );
    if (result != null && context.mounted) {
      final category = domain.Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        activityId: cubit.activityId,
        name: result,
      );
      cubit.addCategory(category);
    }
  }
}

class _CategoryManagementContent extends StatelessWidget {
  final CategoryManagementLoaded state;

  const _CategoryManagementContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasActivityScope =
        context.read<CategoryManagementCubit>().activityId != null;

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasActivityScope) ...[
            Text(l10n.category_mgmt_activity_title).medium,
            const Gap(8),
            if (state.activityCategories.isEmpty)
              Text(l10n.category_mgmt_empty).muted
            else
              ...state.activityCategories.map(
                (cat) => _CategoryRow(
                  category: cat,
                  canEdit: true,
                ),
              ),
            const Gap(20),
          ],
          Text(l10n.category_mgmt_project_title).medium,
          const Gap(8),
          if (state.projectCategories.isEmpty)
            Text(l10n.category_mgmt_empty).muted
          else
            ...state.projectCategories.map(
              (cat) => _CategoryRow(
                category: cat,
                canEdit: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final domain.Category category;
  final bool canEdit;

  const _CategoryRow({
    required this.category,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(category.name)),
            if (canEdit) ...[
              IconButton.ghost(
                onPressed: () => _editCategory(context),
                icon: const Icon(RadixIcons.pencil1, size: 14),
              ),
              IconButton.ghost(
                onPressed: () => _deleteCategory(context),
                icon: const Icon(RadixIcons.trash, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editCategory(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AddCategoryDialog(
        isProjectLevel: category.activityId == null,
        initialName: category.name,
      ),
    );
    if (result != null && context.mounted) {
      context.read<CategoryManagementCubit>().updateCategory(
            category.copyWith(name: result),
          );
    }
  }

  void _deleteCategory(BuildContext context) {
    context.read<CategoryManagementCubit>().deleteCategory(category.id);
  }
}
