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
  String get settings_account_title => 'Account';

  @override
  String get settings_sync_title => 'Sync and Account';

  @override
  String get settings_local_mode_title => 'Independent Local Mode';

  @override
  String get settings_local_mode_info => 'Your data is saved on this device.';

  @override
  String get settings_login_button => 'Log In';

  @override
  String get settings_logout_button => 'Log Out';

  @override
  String get settings_guest_logout_button => 'Exit guest mode';

  @override
  String get settings_sync_logged_in => 'Signed in';

  @override
  String get settings_sync_logged_in_info =>
      'Your data can sync with the cloud.';

  @override
  String get settings_sync_status_label => 'Sync Status';

  @override
  String get settings_sync_last_sync_label => 'Last sync';

  @override
  String get settings_sync_pending_label => 'Pending changes';

  @override
  String get settings_sync_mode_title => 'Online mode';

  @override
  String get settings_sync_mode_info =>
      'Automatically sync and back up your data.';

  @override
  String get settings_sync_never => 'Never';

  @override
  String get settings_sync_backup_button => 'Backup now';

  @override
  String get settings_sync_restore_button => 'Restore from cloud';

  @override
  String get settings_sync_not_configured => 'Supabase is not configured.';

  @override
  String get settings_sync_not_logged_in => 'You need to log in.';

  @override
  String get settings_sync_email_title => 'Email for login';

  @override
  String get settings_sync_email_hint => 'you@example.com';

  @override
  String get settings_sync_send_link_button => 'Send magic link';

  @override
  String get settings_sync_link_sent => 'Check your email to complete login.';

  @override
  String get settings_sync_backup_success => 'Backup completed.';

  @override
  String get settings_sync_restore_success => 'Restore completed.';

  @override
  String get settings_sync_restore_not_found => 'No backup found in the cloud.';

  @override
  String get settings_sync_up_to_date => 'Already up to date.';

  @override
  String get settings_sync_error_title => 'Sync error';

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
  String get settings_data_sync_title => 'Data & Sync';

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

  @override
  String get auth_login_title => 'Log In';

  @override
  String get auth_verify_title => 'Verify Code';

  @override
  String get auth_login_success =>
      'Successfully logged in. Your data has been synced.';

  @override
  String get auth_login_error_title => 'Error';

  @override
  String get auth_login_success_title => 'Success';

  @override
  String get auth_email_view_title => 'Enter your email';

  @override
  String get auth_email_view_subtitle =>
      'We will send you a security code to verify your account and sync your projects.';

  @override
  String get auth_email_label => 'EMAIL ADDRESS';

  @override
  String get auth_email_placeholder => 'email@example.com';

  @override
  String get auth_email_helper =>
      'We will send you an 8-digit code to your email to securely validate your access.';

  @override
  String get auth_email_send_button => 'Send code';

  @override
  String get auth_continue_with => 'OR CONTINUE WITH';

  @override
  String get auth_continue_apple => 'Continue with Apple';

  @override
  String get auth_continue_google => 'Continue with Google';

  @override
  String get auth_otp_view_title => 'Check your email';

  @override
  String auth_otp_view_subtitle(Object email) {
    return 'We have sent an 8-digit security code to: $email';
  }

  @override
  String get auth_otp_label => 'ACCESS CODE';

  @override
  String get auth_otp_helper => 'Enter the 8 digits received';

  @override
  String get auth_otp_verify_button => 'Verify';

  @override
  String get auth_otp_resend_button => 'Resend code';

  @override
  String get auth_otp_spam_helper =>
      'Didn\'t receive anything? Check your spam folder.';

  @override
  String get auth_terms_prefix => 'By continuing, you agree to our ';

  @override
  String get auth_terms_service => 'Terms of Service';

  @override
  String get auth_terms_and => ' and ';

  @override
  String get auth_terms_privacy => 'Privacy Policy';

  @override
  String get auth_terms_suffix => '.';

  @override
  String get welcome_title_prefix => 'Welcome to';

  @override
  String get welcome_title_suffix => 'My Investments';

  @override
  String get welcome_subtitle =>
      'Take control of your goals and projects with professional-grade tools.';

  @override
  String get welcome_feature1_title => 'Project Management';

  @override
  String get welcome_feature1_desc =>
      'Track your projects and saving goals with precision.';

  @override
  String get welcome_feature2_title => 'Total Synchronization';

  @override
  String get welcome_feature2_desc =>
      'Access your data from any device by logging in.';

  @override
  String get welcome_feature3_title => 'Local & Private';

  @override
  String get welcome_feature3_desc =>
      'Your data is yours. Save it locally or sync it securely.';

  @override
  String get welcome_login_button => 'Log In';

  @override
  String get welcome_guest_button => 'Continue as Guest';
}
