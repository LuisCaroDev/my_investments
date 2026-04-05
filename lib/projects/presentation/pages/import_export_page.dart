import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/models/activity_model.dart';
import 'package:my_investments/projects/data/models/category_model.dart';
import 'package:my_investments/projects/data/models/financial_account_model.dart';
import 'package:my_investments/projects/data/models/project_model.dart';
import 'package:my_investments/projects/data/models/transaction_model.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/investments_cubit.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  late final TextEditingController _importController;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _importController = TextEditingController();
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

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

        final projects = ds.getProjects();
        final activities = ds.getActivities();
        final categories = ds.getCategories();
        final transactions = ds.getTransactions();
        final accounts = ds.getFinancialAccounts();

        final exportText = _buildExportText(
          projects: projects,
          activities: activities,
          categories: categories,
          transactions: transactions,
          accounts: accounts,
        );

        return Scaffold(
          headers: [
            AppBar(
              leading: [...AppBackButton.render(context)],
              title: Text(
                AppLocalizations.of(context)!.settings_import_export_label,
              ),
            ),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.import_export_export_tab,
                ).large.bold,
                const Gap(8),
                Text(
                  AppLocalizations.of(context)!.import_export_export_info,
                ).small,
                const Gap(12),
                TextArea(
                  initialValue: exportText,
                  readOnly: true,
                  minHeight: 320,
                ),
                const Gap(12),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: exportText));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.import_export_copy_button,
                    ),
                  ),
                ),
                const Gap(28),
                const Divider(),
                const Gap(20),
                Text(
                  AppLocalizations.of(context)!.import_export_import_tab,
                ).large.bold,
                const Gap(8),
                Text(
                  AppLocalizations.of(context)!.import_export_import_info,
                ).small,
                const Gap(12),
                TextArea(
                  controller: _importController,
                  placeholder: Text(
                    AppLocalizations.of(
                      context,
                    )!.import_export_import_placeholder,
                  ),
                  minHeight: 240,
                ),
                const Gap(12),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    onPressed: _importing
                        ? null
                        : () => _importData(context, ds),
                    child: Text(
                      AppLocalizations.of(context)!.import_export_import_tab,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildExportText({
    required List<Project> projects,
    required List<Activity> activities,
    required List<Category> categories,
    required List<Transaction> transactions,
    required List<FinancialAccount> accounts,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('## projects.csv');
    buffer.writeln(
      [
        'id',
        'name',
        'description',
        'global_budget',
        'type',
        'priority',
        'created_at',
      ].join(','),
    );
    for (final p in projects) {
      buffer.writeln(
        [
          _csv(p.id),
          _csv(p.name),
          _csv(p.description),
          _csv(p.globalBudget),
          _csv(p.type.name),
          _csv(p.priority),
          _csv(p.createdAt.toIso8601String()),
        ].join(','),
      );
    }

    buffer.writeln();
    buffer.writeln('## activities.csv');
    buffer.writeln(
      [
        'id',
        'project_id',
        'name',
        'description',
        'year',
        'budget',
        'created_at',
      ].join(','),
    );
    for (final a in activities) {
      buffer.writeln(
        [
          _csv(a.id),
          _csv(a.projectId),
          _csv(a.name),
          _csv(a.description),
          _csv(a.year),
          _csv(a.budget),
          _csv(a.createdAt.toIso8601String()),
        ].join(','),
      );
    }

    buffer.writeln();
    buffer.writeln('## categories.csv');
    buffer.writeln(['id', 'project_id', 'activity_id', 'name'].join(','));
    for (final c in categories) {
      buffer.writeln(
        [
          _csv(c.id),
          _csv(c.projectId),
          _csv(c.activityId),
          _csv(c.name),
        ].join(','),
      );
    }

    buffer.writeln();
    buffer.writeln('## transactions.csv');
    buffer.writeln(
      [
        'id',
        'project_id',
        'account_id',
        'activity_id',
        'type',
        'amount',
        'date',
        'description',
        'category_id',
        'created_at',
      ].join(','),
    );
    for (final t in transactions) {
      buffer.writeln(
        [
          _csv(t.id),
          _csv(t.projectId),
          _csv(t.accountId),
          _csv(t.activityId),
          _csv(t.type.name),
          _csv(t.amount),
          _csv(t.date.toIso8601String()),
          _csv(t.description),
          _csv(t.categoryId),
          _csv(t.createdAt.toIso8601String()),
        ].join(','),
      );
    }

    buffer.writeln();
    buffer.writeln('## accounts.csv');
    buffer.writeln(['id', 'name', 'type', 'balance', 'created_at'].join(','));
    for (final a in accounts) {
      buffer.writeln(
        [
          _csv(a.id),
          _csv(a.name),
          _csv(a.type.name),
          _csv(a.balance),
          _csv(a.createdAt.toIso8601String()),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  String _csv(Object? value) {
    final text = value?.toString() ?? '';
    final escaped = text.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<void> _importData(
    BuildContext context,
    ProjectsLocalDataSource ds,
  ) async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.import_export_confirm_title),
        content: Text(l10n.import_export_confirm_info),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.common_cancel),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.import_export_import_tab),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _importing = true);
    try {
      final parsed = _parseExport(raw);
      await ds.saveProjects(parsed.projects);
      await ds.saveActivities(parsed.activities);
      await ds.saveCategories(parsed.categories);
      await ds.saveTransactions(parsed.transactions);
      await ds.saveFinancialAccounts(parsed.accounts);

      if (context.mounted) {
        context.read<InvestmentsCubit>().loadInvestments();
        context.read<GoalsCubit>().loadGoals();
        context.read<AccountsCubit>().loadAccounts();
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.import_export_success_title),
            content: Text(l10n.import_export_success_info),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.common_close),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.import_export_error_title),
            content: Text(l10n.common_error_msg(e.toString())),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.common_close),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  _ParsedExport _parseExport(String raw) {
    final sections = _splitSections(raw);
    final projects = _parseProjects(sections['projects.csv'] ?? '');
    final activities = _parseActivities(sections['activities.csv'] ?? '');
    final categories = _parseCategories(sections['categories.csv'] ?? '');
    final transactions = _parseTransactions(sections['transactions.csv'] ?? '');
    final accounts = _parseAccounts(sections['accounts.csv'] ?? '');

    return _ParsedExport(
      projects: projects,
      activities: activities,
      categories: categories,
      transactions: transactions,
      accounts: accounts,
    );
  }

  Map<String, String> _splitSections(String raw) {
    final lines = raw.split('\n');
    final sections = <String, String>{};
    String? current;
    final buffer = StringBuffer();

    void flush() {
      if (current != null) {
        sections[current] = buffer.toString();
        buffer.clear();
      }
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('## ')) {
        flush();
        current = trimmed.substring(3).trim();
      } else {
        buffer.writeln(line);
      }
    }
    flush();
    return sections;
  }

  List<ProjectModel> _parseProjects(String csv) {
    final rows = _parseCsv(csv);
    if (rows.isEmpty) return [];
    final header = rows.first;
    return rows.skip(1).where((r) => r.length == header.length).map((r) {
      final map = _rowToMap(header, r);
      final typeRaw = (map['type'] ?? 'investment').trim();
      final type = ProjectType.values.byName(
        typeRaw == 'savings_goal' ? 'savingsGoal' : typeRaw,
      );
      return ProjectModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        description: _nullIfEmpty(map['description']),
        globalBudget: _toDouble(map['global_budget']),
        type: type,
        priority: _toInt(map['priority']) ?? 0,
        createdAt: DateTime.parse(
          map['created_at'] ?? DateTime.now().toString(),
        ),
      );
    }).toList();
  }

  List<ActivityModel> _parseActivities(String csv) {
    final rows = _parseCsv(csv);
    if (rows.isEmpty) return [];
    final header = rows.first;
    return rows.skip(1).where((r) => r.length == header.length).map((r) {
      final map = _rowToMap(header, r);
      return ActivityModel(
        id: map['id'] ?? '',
        projectId: map['project_id'] ?? '',
        name: map['name'] ?? '',
        description: _nullIfEmpty(map['description']),
        year: _toInt(map['year']),
        budget: _toDouble(map['budget']),
        createdAt: DateTime.parse(
          map['created_at'] ?? DateTime.now().toString(),
        ),
      );
    }).toList();
  }

  List<CategoryModel> _parseCategories(String csv) {
    final rows = _parseCsv(csv);
    if (rows.isEmpty) return [];
    final header = rows.first;
    return rows.skip(1).where((r) => r.length == header.length).map((r) {
      final map = _rowToMap(header, r);
      return CategoryModel(
        id: map['id'] ?? '',
        projectId: map['project_id'] ?? '',
        activityId: _nullIfEmpty(map['activity_id']),
        name: map['name'] ?? '',
      );
    }).toList();
  }

  List<TransactionModel> _parseTransactions(String csv) {
    final rows = _parseCsv(csv);
    if (rows.isEmpty) return [];
    final header = rows.first;
    return rows.skip(1).where((r) => r.length == header.length).map((r) {
      final map = _rowToMap(header, r);
      return TransactionModel(
        id: map['id'] ?? '',
        projectId: map['project_id'] ?? '',
        accountId: map['account_id'] ?? 'initial_statement',
        activityId: _nullIfEmpty(map['activity_id']),
        categoryId: _nullIfEmpty(map['category_id']),
        type: _parseTransactionType(map['type']),
        amount: _toDouble(map['amount']) ?? 0,
        date: DateTime.parse(map['date'] ?? DateTime.now().toString()),
        description: _nullIfEmpty(map['description']),
        createdAt: DateTime.parse(
          map['created_at'] ?? DateTime.now().toString(),
        ),
      );
    }).toList();
  }

  List<FinancialAccountModel> _parseAccounts(String csv) {
    final rows = _parseCsv(csv);
    if (rows.isEmpty) return [];
    final header = rows.first;
    return rows.skip(1).where((r) => r.length == header.length).map((r) {
      final map = _rowToMap(header, r);
      final typeRaw = (map['type'] ?? 'bank').trim();
      final type = FinancialAccountType.values.byName(
        typeRaw == 'loan_account' ? 'loan' : typeRaw,
      );
      return FinancialAccountModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        type: type,
        balance: _toDouble(map['balance']) ?? 0,
        createdAt: DateTime.parse(
          map['created_at'] ?? DateTime.now().toString(),
        ),
      );
    }).toList();
  }

  List<List<String>> _parseCsv(String csv) {
    final rows = <List<String>>[];
    final lines = csv.split('\n');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      rows.add(_parseCsvLine(line));
    }
    return rows;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  Map<String, String?> _rowToMap(List<String> header, List<String> row) {
    final map = <String, String?>{};
    for (var i = 0; i < header.length; i++) {
      map[header[i]] = i < row.length ? row[i] : null;
    }
    return map;
  }

  String? _nullIfEmpty(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : v;
  }

  double? _toDouble(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return null;
    return double.tryParse(v);
  }

  int? _toInt(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return null;
    return int.tryParse(v);
  }

  TransactionType _parseTransactionType(String? value) {
    final v = value?.trim();
    return switch (v) {
      'deposit' => TransactionType.deposit,
      'capitalInjection' => TransactionType.deposit, // Legacy migration
      _ => TransactionType.expense,
    };
  }
}

class _ParsedExport {
  final List<ProjectModel> projects;
  final List<ActivityModel> activities;
  final List<CategoryModel> categories;
  final List<TransactionModel> transactions;
  final List<FinancialAccountModel> accounts;

  const _ParsedExport({
    required this.projects,
    required this.activities,
    required this.categories,
    required this.transactions,
    required this.accounts,
  });
}
