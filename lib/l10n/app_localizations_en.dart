// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_add => 'Add';

  @override
  String get common_save => 'Save';

  @override
  String get common_create => 'Create';

  @override
  String get common_close => 'Close';

  @override
  String get common_error => 'Error';

  @override
  String common_error_msg(Object message) {
    return 'Error: $message';
  }

  @override
  String get common_category => 'Task';

  @override
  String get common_activity => 'Activity';

  @override
  String get common_project => 'Project';

  @override
  String get common_name_label => 'Name';

  @override
  String get common_description_label => 'Description (optional)';

  @override
  String get common_description_placeholder => 'Describe the element...';

  @override
  String get projects_title => 'My Investments';

  @override
  String get projects_add_button => 'New Project';

  @override
  String get projects_empty_title => 'You don\'t have any projects yet';

  @override
  String get projects_empty_subtitle =>
      'Create your first investment project to start recording expenses and budgets.';

  @override
  String get projects_summary_deposited => 'Deposited';

  @override
  String get projects_summary_spent => 'Total Spent';

  @override
  String get projects_summary_budget => 'Budget';

  @override
  String get projects_summary_funded => 'Funded';

  @override
  String get projects_summary_net_balance => 'Net Balance';

  @override
  String get projects_list_title => 'Projects';

  @override
  String projects_item_activity_count(Object count) {
    return '$count act.';
  }

  @override
  String get projects_delete_title => 'Delete project';

  @override
  String get projects_delete_confirmation =>
      'Write the project name to confirm. Its activities, tasks and transactions will be deleted.';

  @override
  String get project_detail_summary_deposited => 'Deposited';

  @override
  String get project_detail_summary_spent => 'Total Spent';

  @override
  String get project_detail_summary_operating => 'Operating Balance';

  @override
  String get project_detail_summary_net_balance => 'Net Balance';

  @override
  String get project_detail_summary_budget => 'Budget';

  @override
  String get project_detail_categories_title => 'Tasks';

  @override
  String get project_detail_transactions_title => 'Latest transactions';

  @override
  String get project_detail_transactions_see_more => 'See more';

  @override
  String get project_detail_transactions_empty => 'No transactions';

  @override
  String get project_detail_transactions_empty_info =>
      'Add expenses, deposits or capital injections for this project.';

  @override
  String get project_detail_activities_title => 'Activities';

  @override
  String get project_detail_activities_empty => 'No activities';

  @override
  String get project_detail_activities_empty_info =>
      'Add activities to organize your project phases.';

  @override
  String get project_detail_add_activity_button => 'Activity';

  @override
  String project_detail_activity_year(Object year) {
    return 'Year $year';
  }

  @override
  String project_detail_activity_transaction_count(Object count) {
    return '$count tx';
  }

  @override
  String get activity_detail_summary_deposited => 'Deposited';

  @override
  String get activity_detail_summary_spent => 'Total Spent';

  @override
  String get activity_detail_summary_operating => 'Balance';

  @override
  String get activity_detail_summary_net_balance => 'Net Balance';

  @override
  String get activity_detail_summary_budget => 'Budget';

  @override
  String get activity_detail_categories_title => 'Tasks';

  @override
  String get activity_detail_add_category_button => 'Task';

  @override
  String get activity_detail_category_project_label => '(project)';

  @override
  String get activity_detail_transactions_title => 'Latest transactions';

  @override
  String get activity_detail_transactions_see_more => 'See more';

  @override
  String get activity_detail_transactions_empty => 'No transactions';

  @override
  String get activity_detail_transactions_empty_info =>
      'Add expenses, deposits or capital injections for this activity.';

  @override
  String get transaction_list_page_title => 'Transactions';

  @override
  String get transaction_list_filter_category => 'Filter by task';

  @override
  String get transaction_list_sort_label => 'Sort';

  @override
  String get transaction_list_category_all => 'All';

  @override
  String get transaction_list_empty => 'No transactions';

  @override
  String get transaction_list_empty_filter =>
      'No transactions for this filter.';

  @override
  String get transaction_list_sort_date_desc => 'Date (recent)';

  @override
  String get transaction_list_sort_date_asc => 'Date (old)';

  @override
  String get transaction_list_sort_amount_desc => 'Amount (higher)';

  @override
  String get transaction_list_sort_amount_asc => 'Amount (lower)';

  @override
  String get category_mgmt_activity_title => 'Activity Tasks';

  @override
  String get category_mgmt_project_title => 'Project Tasks';

  @override
  String get category_mgmt_empty => 'No tasks yet.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_sync_title => 'Sync and Account';

  @override
  String get settings_local_mode_title => 'Independent Local Mode';

  @override
  String get settings_local_mode_info => 'Your data is saved on this device.';

  @override
  String get settings_login_button => 'Log In (Coming Soon)';

  @override
  String get settings_preferences_title => 'Preferences';

  @override
  String get settings_language_label => 'App Language';

  @override
  String get settings_theme_label => 'App Theme';

  @override
  String get settings_currency_label => 'Currency Type';

  @override
  String get settings_system_default => 'System';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_language_dialog_title => 'Select Language';

  @override
  String get settings_theme_dialog_title => 'Select Theme';

  @override
  String get settings_data_title => 'Data';

  @override
  String get settings_import_export_label => 'Import / Export JSON';

  @override
  String get settings_import_export_info => 'Back up your data manually';

  @override
  String get import_export_export_tab => 'Export';

  @override
  String get import_export_import_tab => 'Import';

  @override
  String get import_export_copy_button => 'Copy';

  @override
  String get import_export_export_info =>
      'Copy this content and save it as .csv (includes 4 tables).';

  @override
  String get import_export_import_info =>
      'Paste your CSV format export here. This will replace all current data.';

  @override
  String get import_export_import_placeholder =>
      'Paste exported content here...';

  @override
  String get import_export_confirm_title => 'Confirm import';

  @override
  String get import_export_confirm_info =>
      'This will replace all current data. Do you want to continue?';

  @override
  String get import_export_success_title => 'Import successful';

  @override
  String get import_export_success_info => 'Data was imported.';

  @override
  String get import_export_error_title => 'Error importing';

  @override
  String get dialog_project_edit_title => 'Edit Project';

  @override
  String get dialog_project_new_title => 'New Project';

  @override
  String get dialog_project_name_label => 'Name';

  @override
  String get dialog_project_name_placeholder => 'E.g.: Palm Investment';

  @override
  String get dialog_project_description_label => 'Description (optional)';

  @override
  String get dialog_project_description_placeholder =>
      'Describe the project...';

  @override
  String get dialog_project_budget_label => 'Global Budget (optional)';

  @override
  String get dialog_activity_edit_title => 'Edit Activity';

  @override
  String get dialog_activity_new_title => 'New Activity';

  @override
  String get dialog_activity_name_placeholder => 'E.g.: Planting 2025';

  @override
  String get dialog_activity_description_placeholder =>
      'Describe the activity...';

  @override
  String get dialog_activity_year_label => 'Year';

  @override
  String get dialog_activity_budget_label => 'Budget';

  @override
  String get dialog_activity_delete_title => 'Delete activity';

  @override
  String get dialog_activity_delete_confirmation =>
      'Write the activity name to confirm:';

  @override
  String get dialog_tx_edit_expense => 'Edit Expense';

  @override
  String get dialog_tx_edit_deposit => 'Edit Deposit';

  @override
  String get dialog_tx_new_deposit => 'New Deposit';

  @override
  String get dialog_tx_new_expense => 'New Expense';

  @override
  String get dialog_tx_type_label => 'Type';

  @override
  String get dialog_tx_type_expense => 'Expense';

  @override
  String get dialog_tx_type_deposit => 'Deposit';

  @override
  String get dialog_tx_amount_label => 'Amount';

  @override
  String get dialog_tx_date_label => 'Date';

  @override
  String get dialog_tx_description_placeholder => 'Transaction detail...';

  @override
  String get dialog_tx_account_select => 'Select Account';

  @override
  String get dialog_tx_category_label => 'Task (optional)';

  @override
  String get dialog_tx_category_select => 'Select Task';

  @override
  String get dialog_tx_category_none => 'No task';

  @override
  String get dialog_tx_delete_title => 'Delete transaction';

  @override
  String get dialog_tx_delete_confirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get dialog_category_edit_project_title => 'Edit Project Task';

  @override
  String get dialog_category_new_project_title => 'New Project Task';

  @override
  String get dialog_category_edit_title => 'Edit Task';

  @override
  String get dialog_category_new_title => 'New Task';

  @override
  String get dialog_category_name_placeholder => 'E.g.: Fumigation';

  @override
  String get dialog_category_project_info =>
      'This task will be available in all project activities.';

  @override
  String get widget_budget_progress_budget => 'Budget:';

  @override
  String get widget_budget_progress_deposited => 'Deposited:';

  @override
  String get widget_budget_progress_spent => 'Spent:';

  @override
  String get widget_budget_progress_funded => 'Funded:';

  @override
  String get widget_budget_progress_remaining => 'Remaining to Fund:';

  @override
  String get widget_tx_tile_project_label => '(project)';

  @override
  String get nav_investments => 'Investments';

  @override
  String get nav_goals => 'Goals';

  @override
  String get nav_accounts => 'Accounts';

  @override
  String get goals_title => 'Savings Goals';

  @override
  String get goals_empty => 'No savings goals yet. Add your first goal!';

  @override
  String get accounts_title => 'Financial Accounts';

  @override
  String get accounts_empty => 'No accounts added yet.';

  @override
  String get dialog_priority_title => 'Project Priorities';

  @override
  String get dialog_account_title => 'Add Account';

  @override
  String get dialog_account_name => 'Account Name';

  @override
  String get dialog_account_type => 'Account Type';

  @override
  String get dialog_account_type_bank => 'Bank';

  @override
  String get dialog_account_type_loan => 'Loan';

  @override
  String get dialog_account_balance_label => 'Balance';
}
