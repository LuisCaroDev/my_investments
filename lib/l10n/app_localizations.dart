import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @common_cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get common_cancel;

  /// No description provided for @common_edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get common_edit;

  /// No description provided for @common_delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get common_delete;

  /// No description provided for @common_add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get common_add;

  /// No description provided for @common_save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get common_save;

  /// No description provided for @common_create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get common_create;

  /// No description provided for @common_close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get common_close;

  /// No description provided for @common_error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_error_msg.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String common_error_msg(Object message);

  /// No description provided for @common_category.
  ///
  /// In es, this message translates to:
  /// **'Tarea'**
  String get common_category;

  /// No description provided for @common_activity.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get common_activity;

  /// No description provided for @common_project.
  ///
  /// In es, this message translates to:
  /// **'Proyecto'**
  String get common_project;

  /// No description provided for @common_name_label.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get common_name_label;

  /// No description provided for @common_description_label.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get common_description_label;

  /// No description provided for @common_description_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Describe el elemento...'**
  String get common_description_placeholder;

  /// No description provided for @projects_title.
  ///
  /// In es, this message translates to:
  /// **'Mis Inversiones'**
  String get projects_title;

  /// No description provided for @projects_add_button.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Proyecto'**
  String get projects_add_button;

  /// No description provided for @projects_empty_title.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes proyectos'**
  String get projects_empty_title;

  /// No description provided for @projects_empty_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer proyecto de inversión para comenzar a registrar gastos y presupuestos.'**
  String get projects_empty_subtitle;

  /// No description provided for @projects_summary_deposited.
  ///
  /// In es, this message translates to:
  /// **'Depositado'**
  String get projects_summary_deposited;

  /// No description provided for @projects_summary_spent.
  ///
  /// In es, this message translates to:
  /// **'Gasto Total'**
  String get projects_summary_spent;

  /// No description provided for @projects_summary_budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get projects_summary_budget;

  /// No description provided for @projects_summary_funded.
  ///
  /// In es, this message translates to:
  /// **'Financiado'**
  String get projects_summary_funded;

  /// No description provided for @projects_summary_net_balance.
  ///
  /// In es, this message translates to:
  /// **'Balance Neto'**
  String get projects_summary_net_balance;

  /// No description provided for @projects_list_title.
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get projects_list_title;

  /// No description provided for @projects_item_activity_count.
  ///
  /// In es, this message translates to:
  /// **'{count} act.'**
  String projects_item_activity_count(Object count);

  /// No description provided for @projects_delete_title.
  ///
  /// In es, this message translates to:
  /// **'Eliminar proyecto'**
  String get projects_delete_title;

  /// No description provided for @projects_delete_confirmation.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del proyecto para confirmar. Se eliminarán sus actividades, tareas y transacciones.'**
  String get projects_delete_confirmation;

  /// No description provided for @project_detail_summary_deposited.
  ///
  /// In es, this message translates to:
  /// **'Depositado'**
  String get project_detail_summary_deposited;

  /// No description provided for @project_detail_summary_spent.
  ///
  /// In es, this message translates to:
  /// **'Gasto Total'**
  String get project_detail_summary_spent;

  /// No description provided for @project_detail_summary_operating.
  ///
  /// In es, this message translates to:
  /// **'Balance Operativo'**
  String get project_detail_summary_operating;

  /// No description provided for @project_detail_summary_net_balance.
  ///
  /// In es, this message translates to:
  /// **'Balance Neto'**
  String get project_detail_summary_net_balance;

  /// No description provided for @project_detail_summary_budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get project_detail_summary_budget;

  /// No description provided for @project_detail_categories_title.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get project_detail_categories_title;

  /// No description provided for @project_detail_transactions_title.
  ///
  /// In es, this message translates to:
  /// **'Últimas transacciones'**
  String get project_detail_transactions_title;

  /// No description provided for @project_detail_transactions_see_more.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get project_detail_transactions_see_more;

  /// No description provided for @project_detail_transactions_empty.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones'**
  String get project_detail_transactions_empty;

  /// No description provided for @project_detail_transactions_empty_info.
  ///
  /// In es, this message translates to:
  /// **'Agrega gastos, depósitos o inyecciones de capital para este proyecto.'**
  String get project_detail_transactions_empty_info;

  /// No description provided for @project_detail_activities_title.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get project_detail_activities_title;

  /// No description provided for @project_detail_activities_empty.
  ///
  /// In es, this message translates to:
  /// **'Sin actividades'**
  String get project_detail_activities_empty;

  /// No description provided for @project_detail_activities_empty_info.
  ///
  /// In es, this message translates to:
  /// **'Agrega actividades para organizar las fases de tu proyecto.'**
  String get project_detail_activities_empty_info;

  /// No description provided for @project_detail_add_activity_button.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get project_detail_add_activity_button;

  /// No description provided for @project_detail_activity_year.
  ///
  /// In es, this message translates to:
  /// **'Año {year}'**
  String project_detail_activity_year(Object year);

  /// No description provided for @project_detail_activity_transaction_count.
  ///
  /// In es, this message translates to:
  /// **'{count} tx'**
  String project_detail_activity_transaction_count(Object count);

  /// No description provided for @activity_detail_summary_deposited.
  ///
  /// In es, this message translates to:
  /// **'Depositado'**
  String get activity_detail_summary_deposited;

  /// No description provided for @activity_detail_summary_spent.
  ///
  /// In es, this message translates to:
  /// **'Gasto Total'**
  String get activity_detail_summary_spent;

  /// No description provided for @activity_detail_summary_operating.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get activity_detail_summary_operating;

  /// No description provided for @activity_detail_summary_net_balance.
  ///
  /// In es, this message translates to:
  /// **'Balance Neto'**
  String get activity_detail_summary_net_balance;

  /// No description provided for @activity_detail_summary_budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get activity_detail_summary_budget;

  /// No description provided for @activity_detail_categories_title.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get activity_detail_categories_title;

  /// No description provided for @activity_detail_add_category_button.
  ///
  /// In es, this message translates to:
  /// **'Tarea'**
  String get activity_detail_add_category_button;

  /// No description provided for @activity_detail_category_project_label.
  ///
  /// In es, this message translates to:
  /// **'(proyecto)'**
  String get activity_detail_category_project_label;

  /// No description provided for @activity_detail_transactions_title.
  ///
  /// In es, this message translates to:
  /// **'Últimas transacciones'**
  String get activity_detail_transactions_title;

  /// No description provided for @activity_detail_transactions_see_more.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get activity_detail_transactions_see_more;

  /// No description provided for @activity_detail_transactions_empty.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones'**
  String get activity_detail_transactions_empty;

  /// No description provided for @activity_detail_transactions_empty_info.
  ///
  /// In es, this message translates to:
  /// **'Agrega gastos, depósitos o inyecciones de capital para esta actividad.'**
  String get activity_detail_transactions_empty_info;

  /// No description provided for @transaction_list_page_title.
  ///
  /// In es, this message translates to:
  /// **'Transacciones'**
  String get transaction_list_page_title;

  /// No description provided for @transaction_list_filter_category.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por tarea'**
  String get transaction_list_filter_category;

  /// No description provided for @transaction_list_sort_label.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get transaction_list_sort_label;

  /// No description provided for @transaction_list_category_all.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get transaction_list_category_all;

  /// No description provided for @transaction_list_empty.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones'**
  String get transaction_list_empty;

  /// No description provided for @transaction_list_empty_filter.
  ///
  /// In es, this message translates to:
  /// **'No hay transacciones para este filtro.'**
  String get transaction_list_empty_filter;

  /// No description provided for @transaction_list_sort_date_desc.
  ///
  /// In es, this message translates to:
  /// **'Fecha (reciente)'**
  String get transaction_list_sort_date_desc;

  /// No description provided for @transaction_list_sort_date_asc.
  ///
  /// In es, this message translates to:
  /// **'Fecha (antigua)'**
  String get transaction_list_sort_date_asc;

  /// No description provided for @transaction_list_sort_amount_desc.
  ///
  /// In es, this message translates to:
  /// **'Monto (mayor)'**
  String get transaction_list_sort_amount_desc;

  /// No description provided for @transaction_list_sort_amount_asc.
  ///
  /// In es, this message translates to:
  /// **'Monto (menor)'**
  String get transaction_list_sort_amount_asc;

  /// No description provided for @category_mgmt_activity_title.
  ///
  /// In es, this message translates to:
  /// **'Tareas de la Actividad'**
  String get category_mgmt_activity_title;

  /// No description provided for @category_mgmt_project_title.
  ///
  /// In es, this message translates to:
  /// **'Tareas del Proyecto'**
  String get category_mgmt_project_title;

  /// No description provided for @category_mgmt_empty.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas todavía.'**
  String get category_mgmt_empty;

  /// No description provided for @settings_title.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings_title;

  /// No description provided for @settings_sync_title.
  ///
  /// In es, this message translates to:
  /// **'Sincronización y Cuenta'**
  String get settings_sync_title;

  /// No description provided for @settings_local_mode_title.
  ///
  /// In es, this message translates to:
  /// **'Modo Local Independiente'**
  String get settings_local_mode_title;

  /// No description provided for @settings_local_mode_info.
  ///
  /// In es, this message translates to:
  /// **'Tus datos se guardan en este dispositivo.'**
  String get settings_local_mode_info;

  /// No description provided for @settings_login_button.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get settings_login_button;

  /// No description provided for @settings_logout_button.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settings_logout_button;

  /// No description provided for @settings_guest_logout_button.
  ///
  /// In es, this message translates to:
  /// **'Salir de invitado'**
  String get settings_guest_logout_button;

  /// No description provided for @settings_sync_logged_in.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada'**
  String get settings_sync_logged_in;

  /// No description provided for @settings_sync_logged_in_info.
  ///
  /// In es, this message translates to:
  /// **'Tus datos pueden sincronizarse con la nube.'**
  String get settings_sync_logged_in_info;

  /// No description provided for @settings_sync_status_label.
  ///
  /// In es, this message translates to:
  /// **'Estado de sincronización'**
  String get settings_sync_status_label;

  /// No description provided for @settings_sync_last_sync_label.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización'**
  String get settings_sync_last_sync_label;

  /// No description provided for @settings_sync_pending_label.
  ///
  /// In es, this message translates to:
  /// **'Cambios pendientes'**
  String get settings_sync_pending_label;

  /// No description provided for @settings_sync_mode_title.
  ///
  /// In es, this message translates to:
  /// **'Modo online'**
  String get settings_sync_mode_title;

  /// No description provided for @settings_sync_mode_info.
  ///
  /// In es, this message translates to:
  /// **'Sincroniza y respalda tus datos automáticamente.'**
  String get settings_sync_mode_info;

  /// No description provided for @settings_sync_never.
  ///
  /// In es, this message translates to:
  /// **'Nunca'**
  String get settings_sync_never;

  /// No description provided for @settings_sync_backup_button.
  ///
  /// In es, this message translates to:
  /// **'Hacer backup'**
  String get settings_sync_backup_button;

  /// No description provided for @settings_sync_restore_button.
  ///
  /// In es, this message translates to:
  /// **'Restaurar desde la nube'**
  String get settings_sync_restore_button;

  /// No description provided for @settings_sync_not_configured.
  ///
  /// In es, this message translates to:
  /// **'Supabase no está configurado.'**
  String get settings_sync_not_configured;

  /// No description provided for @settings_sync_not_logged_in.
  ///
  /// In es, this message translates to:
  /// **'Necesitas iniciar sesión.'**
  String get settings_sync_not_logged_in;

  /// No description provided for @settings_sync_email_title.
  ///
  /// In es, this message translates to:
  /// **'Email para iniciar sesión'**
  String get settings_sync_email_title;

  /// No description provided for @settings_sync_email_hint.
  ///
  /// In es, this message translates to:
  /// **'tu@correo.com'**
  String get settings_sync_email_hint;

  /// No description provided for @settings_sync_send_link_button.
  ///
  /// In es, this message translates to:
  /// **'Enviar magic link'**
  String get settings_sync_send_link_button;

  /// No description provided for @settings_sync_link_sent.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo para completar el inicio de sesión.'**
  String get settings_sync_link_sent;

  /// No description provided for @settings_sync_backup_success.
  ///
  /// In es, this message translates to:
  /// **'Backup completado.'**
  String get settings_sync_backup_success;

  /// No description provided for @settings_sync_restore_success.
  ///
  /// In es, this message translates to:
  /// **'Restauración completada.'**
  String get settings_sync_restore_success;

  /// No description provided for @settings_sync_restore_not_found.
  ///
  /// In es, this message translates to:
  /// **'No se encontró backup en la nube.'**
  String get settings_sync_restore_not_found;

  /// No description provided for @settings_sync_up_to_date.
  ///
  /// In es, this message translates to:
  /// **'Ya está actualizado.'**
  String get settings_sync_up_to_date;

  /// No description provided for @settings_sync_error_title.
  ///
  /// In es, this message translates to:
  /// **'Error de sincronización'**
  String get settings_sync_error_title;

  /// No description provided for @settings_preferences_title.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settings_preferences_title;

  /// No description provided for @settings_language_label.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la App'**
  String get settings_language_label;

  /// No description provided for @settings_theme_label.
  ///
  /// In es, this message translates to:
  /// **'Tema de la App'**
  String get settings_theme_label;

  /// No description provided for @settings_currency_label.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Moneda'**
  String get settings_currency_label;

  /// No description provided for @settings_system_default.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settings_system_default;

  /// No description provided for @settings_theme_light.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settings_theme_dark;

  /// No description provided for @settings_language_dialog_title.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get settings_language_dialog_title;

  /// No description provided for @settings_theme_dialog_title.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Tema'**
  String get settings_theme_dialog_title;

  /// No description provided for @settings_data_title.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get settings_data_title;

  /// No description provided for @settings_import_export_label.
  ///
  /// In es, this message translates to:
  /// **'Importar / Exportar JSON'**
  String get settings_import_export_label;

  /// No description provided for @settings_import_export_info.
  ///
  /// In es, this message translates to:
  /// **'Respalda tus datos manualmente'**
  String get settings_import_export_info;

  /// No description provided for @import_export_export_tab.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get import_export_export_tab;

  /// No description provided for @import_export_import_tab.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get import_export_import_tab;

  /// No description provided for @import_export_copy_button.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get import_export_copy_button;

  /// No description provided for @import_export_export_info.
  ///
  /// In es, this message translates to:
  /// **'Copia este contenido y guárdalo como .csv (incluye 4 tablas).'**
  String get import_export_export_info;

  /// No description provided for @import_export_import_info.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí tu export en formato CSV. Esto reemplazará todos los datos actuales.'**
  String get import_export_import_info;

  /// No description provided for @import_export_import_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Pega el contenido exportado aquí...'**
  String get import_export_import_placeholder;

  /// No description provided for @import_export_confirm_title.
  ///
  /// In es, this message translates to:
  /// **'Confirmar importación'**
  String get import_export_confirm_title;

  /// No description provided for @import_export_confirm_info.
  ///
  /// In es, this message translates to:
  /// **'Esto reemplazará todos los datos actuales. ¿Deseas continuar?'**
  String get import_export_confirm_info;

  /// No description provided for @import_export_success_title.
  ///
  /// In es, this message translates to:
  /// **'Importación exitosa'**
  String get import_export_success_title;

  /// No description provided for @import_export_success_info.
  ///
  /// In es, this message translates to:
  /// **'Los datos fueron importados.'**
  String get import_export_success_info;

  /// No description provided for @import_export_error_title.
  ///
  /// In es, this message translates to:
  /// **'Error al importar'**
  String get import_export_error_title;

  /// No description provided for @dialog_project_edit_title.
  ///
  /// In es, this message translates to:
  /// **'Editar Proyecto'**
  String get dialog_project_edit_title;

  /// No description provided for @dialog_project_new_title.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Proyecto'**
  String get dialog_project_new_title;

  /// No description provided for @dialog_project_name_label.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get dialog_project_name_label;

  /// No description provided for @dialog_project_name_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Ej: Inversión en Palma'**
  String get dialog_project_name_placeholder;

  /// No description provided for @dialog_project_description_label.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get dialog_project_description_label;

  /// No description provided for @dialog_project_description_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Describe el proyecto...'**
  String get dialog_project_description_placeholder;

  /// No description provided for @dialog_project_budget_label.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto Global (opcional)'**
  String get dialog_project_budget_label;

  /// No description provided for @dialog_activity_edit_title.
  ///
  /// In es, this message translates to:
  /// **'Editar Actividad'**
  String get dialog_activity_edit_title;

  /// No description provided for @dialog_activity_new_title.
  ///
  /// In es, this message translates to:
  /// **'Nueva Actividad'**
  String get dialog_activity_new_title;

  /// No description provided for @dialog_activity_name_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Ej: Siembra 2025'**
  String get dialog_activity_name_placeholder;

  /// No description provided for @dialog_activity_description_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Describe la actividad...'**
  String get dialog_activity_description_placeholder;

  /// No description provided for @dialog_activity_year_label.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get dialog_activity_year_label;

  /// No description provided for @dialog_activity_budget_label.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get dialog_activity_budget_label;

  /// No description provided for @dialog_activity_delete_title.
  ///
  /// In es, this message translates to:
  /// **'Eliminar actividad'**
  String get dialog_activity_delete_title;

  /// No description provided for @dialog_activity_delete_confirmation.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre de la actividad para confirmar:'**
  String get dialog_activity_delete_confirmation;

  /// No description provided for @dialog_tx_edit_expense.
  ///
  /// In es, this message translates to:
  /// **'Editar Gasto'**
  String get dialog_tx_edit_expense;

  /// No description provided for @dialog_tx_edit_deposit.
  ///
  /// In es, this message translates to:
  /// **'Editar Depósito'**
  String get dialog_tx_edit_deposit;

  /// No description provided for @dialog_tx_new_deposit.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Depósito'**
  String get dialog_tx_new_deposit;

  /// No description provided for @dialog_tx_new_expense.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Gasto'**
  String get dialog_tx_new_expense;

  /// No description provided for @dialog_tx_type_label.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get dialog_tx_type_label;

  /// No description provided for @dialog_tx_type_expense.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get dialog_tx_type_expense;

  /// No description provided for @dialog_tx_type_deposit.
  ///
  /// In es, this message translates to:
  /// **'Depósito'**
  String get dialog_tx_type_deposit;

  /// No description provided for @dialog_tx_amount_label.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get dialog_tx_amount_label;

  /// No description provided for @dialog_tx_date_label.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get dialog_tx_date_label;

  /// No description provided for @dialog_tx_description_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Detalle de la transacción...'**
  String get dialog_tx_description_placeholder;

  /// No description provided for @dialog_tx_account_select.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Cuenta'**
  String get dialog_tx_account_select;

  /// No description provided for @dialog_tx_category_label.
  ///
  /// In es, this message translates to:
  /// **'Tarea (opcional)'**
  String get dialog_tx_category_label;

  /// No description provided for @dialog_tx_category_select.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Tarea'**
  String get dialog_tx_category_select;

  /// No description provided for @dialog_tx_category_none.
  ///
  /// In es, this message translates to:
  /// **'Sin tarea'**
  String get dialog_tx_category_none;

  /// No description provided for @dialog_tx_delete_title.
  ///
  /// In es, this message translates to:
  /// **'Eliminar transacción'**
  String get dialog_tx_delete_title;

  /// No description provided for @dialog_tx_delete_confirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta transacción?'**
  String get dialog_tx_delete_confirm;

  /// No description provided for @dialog_category_edit_project_title.
  ///
  /// In es, this message translates to:
  /// **'Editar Tarea de Proyecto'**
  String get dialog_category_edit_project_title;

  /// No description provided for @dialog_category_new_project_title.
  ///
  /// In es, this message translates to:
  /// **'Nueva Tarea de Proyecto'**
  String get dialog_category_new_project_title;

  /// No description provided for @dialog_category_edit_title.
  ///
  /// In es, this message translates to:
  /// **'Editar Tarea'**
  String get dialog_category_edit_title;

  /// No description provided for @dialog_category_new_title.
  ///
  /// In es, this message translates to:
  /// **'Nueva Tarea'**
  String get dialog_category_new_title;

  /// No description provided for @dialog_category_name_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Ej: Fumigación'**
  String get dialog_category_name_placeholder;

  /// No description provided for @dialog_category_project_info.
  ///
  /// In es, this message translates to:
  /// **'Esta tarea estará disponible en todas las actividades del proyecto.'**
  String get dialog_category_project_info;

  /// No description provided for @widget_budget_progress_budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto:'**
  String get widget_budget_progress_budget;

  /// No description provided for @widget_budget_progress_deposited.
  ///
  /// In es, this message translates to:
  /// **'Depositado:'**
  String get widget_budget_progress_deposited;

  /// No description provided for @widget_budget_progress_spent.
  ///
  /// In es, this message translates to:
  /// **'Gastado:'**
  String get widget_budget_progress_spent;

  /// No description provided for @widget_budget_progress_funded.
  ///
  /// In es, this message translates to:
  /// **'Financiado:'**
  String get widget_budget_progress_funded;

  /// No description provided for @widget_budget_progress_remaining.
  ///
  /// In es, this message translates to:
  /// **'Por Financiar:'**
  String get widget_budget_progress_remaining;

  /// No description provided for @widget_tx_tile_project_label.
  ///
  /// In es, this message translates to:
  /// **'(proyecto)'**
  String get widget_tx_tile_project_label;

  /// No description provided for @nav_investments.
  ///
  /// In es, this message translates to:
  /// **'Inversiones'**
  String get nav_investments;

  /// No description provided for @nav_goals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get nav_goals;

  /// No description provided for @nav_accounts.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get nav_accounts;

  /// No description provided for @goals_title.
  ///
  /// In es, this message translates to:
  /// **'Metas de Ahorro'**
  String get goals_title;

  /// No description provided for @goals_empty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay metas de ahorro. ¡Agrega tu primera meta!'**
  String get goals_empty;

  /// No description provided for @accounts_title.
  ///
  /// In es, this message translates to:
  /// **'Cuentas Financieras'**
  String get accounts_title;

  /// No description provided for @accounts_empty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cuentas agregadas.'**
  String get accounts_empty;

  /// No description provided for @dialog_priority_title.
  ///
  /// In es, this message translates to:
  /// **'Prioridades de Proyectos'**
  String get dialog_priority_title;

  /// No description provided for @dialog_account_title.
  ///
  /// In es, this message translates to:
  /// **'Agregar Cuenta'**
  String get dialog_account_title;

  /// No description provided for @dialog_account_name.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la Cuenta'**
  String get dialog_account_name;

  /// No description provided for @dialog_account_type.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Cuenta'**
  String get dialog_account_type;

  /// No description provided for @dialog_account_type_bank.
  ///
  /// In es, this message translates to:
  /// **'Banco'**
  String get dialog_account_type_bank;

  /// No description provided for @dialog_account_type_loan.
  ///
  /// In es, this message translates to:
  /// **'Préstamo'**
  String get dialog_account_type_loan;

  /// No description provided for @dialog_account_balance_label.
  ///
  /// In es, this message translates to:
  /// **'Saldo'**
  String get dialog_account_balance_label;

  /// No description provided for @auth_login_title.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get auth_login_title;

  /// No description provided for @auth_verify_title.
  ///
  /// In es, this message translates to:
  /// **'Verificar Código'**
  String get auth_verify_title;

  /// No description provided for @auth_login_success.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada correctamente. Sus datos se han sincronizado.'**
  String get auth_login_success;

  /// No description provided for @auth_login_error_title.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get auth_login_error_title;

  /// No description provided for @auth_login_success_title.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get auth_login_success_title;

  /// No description provided for @auth_email_view_title.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get auth_email_view_title;

  /// No description provided for @auth_email_view_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código de seguridad para verificar tu cuenta y sincronizar tus proyectos.'**
  String get auth_email_view_subtitle;

  /// No description provided for @auth_email_label.
  ///
  /// In es, this message translates to:
  /// **'DIRECCIÓN DE CORREO ELECTRÓNICO'**
  String get auth_email_label;

  /// No description provided for @auth_email_placeholder.
  ///
  /// In es, this message translates to:
  /// **'correo@ejemplo.com'**
  String get auth_email_placeholder;

  /// No description provided for @auth_email_helper.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código de 8 dígitos al correo para validar tu acceso de forma segura.'**
  String get auth_email_helper;

  /// No description provided for @auth_email_send_button.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get auth_email_send_button;

  /// No description provided for @auth_continue_with.
  ///
  /// In es, this message translates to:
  /// **'O CONTINUAR CON'**
  String get auth_continue_with;

  /// No description provided for @auth_continue_apple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get auth_continue_apple;

  /// No description provided for @auth_continue_google.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get auth_continue_google;

  /// No description provided for @auth_otp_view_title.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get auth_otp_view_title;

  /// No description provided for @auth_otp_view_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un código de seguridad de 8 dígitos a: {email}'**
  String auth_otp_view_subtitle(Object email);

  /// No description provided for @auth_otp_label.
  ///
  /// In es, this message translates to:
  /// **'CÓDIGO DE ACCESO'**
  String get auth_otp_label;

  /// No description provided for @auth_otp_helper.
  ///
  /// In es, this message translates to:
  /// **'Ingresa los 8 dígitos recibidos'**
  String get auth_otp_helper;

  /// No description provided for @auth_otp_verify_button.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get auth_otp_verify_button;

  /// No description provided for @auth_otp_resend_button.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get auth_otp_resend_button;

  /// No description provided for @auth_otp_spam_helper.
  ///
  /// In es, this message translates to:
  /// **'¿No recibiste nada? Revisa tu carpeta de spam.'**
  String get auth_otp_spam_helper;

  /// No description provided for @auth_terms_prefix.
  ///
  /// In es, this message translates to:
  /// **'Al continuar, aceptas nuestros '**
  String get auth_terms_prefix;

  /// No description provided for @auth_terms_service.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get auth_terms_service;

  /// No description provided for @auth_terms_and.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get auth_terms_and;

  /// No description provided for @auth_terms_privacy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get auth_terms_privacy;

  /// No description provided for @auth_terms_suffix.
  ///
  /// In es, this message translates to:
  /// **'.'**
  String get auth_terms_suffix;

  /// No description provided for @welcome_title_prefix.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a'**
  String get welcome_title_prefix;

  /// No description provided for @welcome_title_suffix.
  ///
  /// In es, this message translates to:
  /// **'Mis Inversiones'**
  String get welcome_title_suffix;

  /// No description provided for @welcome_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Toma el control de tus metas y proyectos con herramientas de nivel profesional.'**
  String get welcome_subtitle;

  /// No description provided for @welcome_feature1_title.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Proyectos'**
  String get welcome_feature1_title;

  /// No description provided for @welcome_feature1_desc.
  ///
  /// In es, this message translates to:
  /// **'Sigue tus proyectos y metas de ahorro con datos precisos.'**
  String get welcome_feature1_desc;

  /// No description provided for @welcome_feature2_title.
  ///
  /// In es, this message translates to:
  /// **'Sincronización Total'**
  String get welcome_feature2_title;

  /// No description provided for @welcome_feature2_desc.
  ///
  /// In es, this message translates to:
  /// **'Accede a tus datos desde cualquier dispositivo iniciando sesión.'**
  String get welcome_feature2_desc;

  /// No description provided for @welcome_feature3_title.
  ///
  /// In es, this message translates to:
  /// **'Local y Privado'**
  String get welcome_feature3_title;

  /// No description provided for @welcome_feature3_desc.
  ///
  /// In es, this message translates to:
  /// **'Tus datos son tuyos. Guárdalos localmente o sincronízalos de forma segura.'**
  String get welcome_feature3_desc;

  /// No description provided for @welcome_login_button.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get welcome_login_button;

  /// No description provided for @welcome_guest_button.
  ///
  /// In es, this message translates to:
  /// **'Continuar como invitado'**
  String get welcome_guest_button;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
