// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_add => 'Agregar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_create => 'Crear';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_error => 'Error';

  @override
  String common_error_msg(Object message) {
    return 'Error: $message';
  }

  @override
  String get common_category => 'Categoría';

  @override
  String get common_activity => 'Actividad';

  @override
  String get common_project => 'Proyecto';

  @override
  String get common_name_label => 'Nombre';

  @override
  String get common_description_label => 'Descripción (opcional)';

  @override
  String get common_description_placeholder => 'Describe el elemento...';

  @override
  String get projects_title => 'Mis Inversiones';

  @override
  String get projects_add_button => 'Nuevo Proyecto';

  @override
  String get projects_empty_title => 'Aún no tienes proyectos';

  @override
  String get projects_empty_subtitle =>
      'Crea tu primer proyecto de inversión para comenzar a registrar gastos y presupuestos.';

  @override
  String get projects_summary_deposited => 'Depositado';

  @override
  String get projects_summary_spent => 'Gasto Total';

  @override
  String get projects_summary_budget => 'Presupuesto';

  @override
  String get projects_summary_capital => 'Capital Inyectado';

  @override
  String get projects_summary_net_balance => 'Balance Neto';

  @override
  String get projects_list_title => 'Proyectos';

  @override
  String projects_item_activity_count(Object count) {
    return '$count act.';
  }

  @override
  String get projects_delete_title => 'Eliminar proyecto';

  @override
  String get projects_delete_confirmation =>
      'Escribe el nombre del proyecto para confirmar. Se eliminarán sus actividades, categorías y transacciones.';

  @override
  String get project_detail_summary_deposited => 'Depositado';

  @override
  String get project_detail_summary_spent => 'Gasto Total';

  @override
  String get project_detail_summary_operating => 'Balance Operativo';

  @override
  String get project_detail_summary_capital => 'Capital Inyectado';

  @override
  String get project_detail_summary_net_balance => 'Balance Neto';

  @override
  String get project_detail_summary_budget => 'Presupuesto';

  @override
  String get project_detail_categories_title => 'Categorías';

  @override
  String get project_detail_transactions_title => 'Últimas transacciones';

  @override
  String get project_detail_transactions_see_more => 'Ver más';

  @override
  String get project_detail_transactions_empty => 'Sin transacciones';

  @override
  String get project_detail_transactions_empty_info =>
      'Agrega gastos, depósitos o inyecciones de capital para este proyecto.';

  @override
  String get project_detail_activities_title => 'Actividades';

  @override
  String get project_detail_activities_empty => 'Sin actividades';

  @override
  String get project_detail_activities_empty_info =>
      'Agrega actividades para organizar las fases de tu proyecto.';

  @override
  String get project_detail_add_activity_button => 'Actividad';

  @override
  String project_detail_activity_year(Object year) {
    return 'Año $year';
  }

  @override
  String project_detail_activity_transaction_count(Object count) {
    return '$count tx';
  }

  @override
  String get activity_detail_summary_deposited => 'Depositado';

  @override
  String get activity_detail_summary_spent => 'Gasto Total';

  @override
  String get activity_detail_summary_operating => 'Balance';

  @override
  String get activity_detail_summary_capital => 'Capital Inyectado';

  @override
  String get activity_detail_summary_net_balance => 'Balance Neto';

  @override
  String get activity_detail_summary_budget => 'Presupuesto';

  @override
  String get activity_detail_categories_title => 'Categorías';

  @override
  String get activity_detail_add_category_button => 'Categoría';

  @override
  String get activity_detail_category_project_label => '(proyecto)';

  @override
  String get activity_detail_transactions_title => 'Últimas transacciones';

  @override
  String get activity_detail_transactions_see_more => 'Ver más';

  @override
  String get activity_detail_transactions_empty => 'Sin transacciones';

  @override
  String get activity_detail_transactions_empty_info =>
      'Agrega gastos, depósitos o inyecciones de capital para esta actividad.';

  @override
  String get transaction_list_page_title => 'Transacciones';

  @override
  String get transaction_list_filter_category => 'Filtrar por categoría';

  @override
  String get transaction_list_sort_label => 'Ordenar';

  @override
  String get transaction_list_category_all => 'Todas';

  @override
  String get transaction_list_empty => 'Sin transacciones';

  @override
  String get transaction_list_empty_filter =>
      'No hay transacciones para este filtro.';

  @override
  String get transaction_list_sort_date_desc => 'Fecha (reciente)';

  @override
  String get transaction_list_sort_date_asc => 'Fecha (antigua)';

  @override
  String get transaction_list_sort_amount_desc => 'Monto (mayor)';

  @override
  String get transaction_list_sort_amount_asc => 'Monto (menor)';

  @override
  String get category_mgmt_activity_title => 'Categorías de la Actividad';

  @override
  String get category_mgmt_project_title => 'Categorías del Proyecto';

  @override
  String get category_mgmt_empty => 'No hay categorías todavía.';

  @override
  String get settings_title => 'Configuración';

  @override
  String get settings_sync_title => 'Sincronización y Cuenta';

  @override
  String get settings_local_mode_title => 'Modo Local Independiente';

  @override
  String get settings_local_mode_info =>
      'Tus datos se guardan en este dispositivo.';

  @override
  String get settings_login_button => 'Iniciar Sesión (Próximamente)';

  @override
  String get settings_preferences_title => 'Preferencias';

  @override
  String get settings_language_label => 'Idioma de la App';

  @override
  String get settings_currency_label => 'Tipo de Moneda';

  @override
  String get settings_system_default => 'Sistema';

  @override
  String get settings_language_dialog_title => 'Seleccionar Idioma';

  @override
  String get settings_data_title => 'Datos';

  @override
  String get settings_import_export_label => 'Importar / Exportar JSON';

  @override
  String get settings_import_export_info => 'Respalda tus datos manualmente';

  @override
  String get import_export_export_tab => 'Exportar';

  @override
  String get import_export_import_tab => 'Importar';

  @override
  String get import_export_copy_button => 'Copiar';

  @override
  String get import_export_export_info =>
      'Copia este contenido y guárdalo como .csv (incluye 4 tablas).';

  @override
  String get import_export_import_info =>
      'Pega aquí tu export en formato CSV. Esto reemplazará todos los datos actuales.';

  @override
  String get import_export_import_placeholder =>
      'Pega el contenido exportado aquí...';

  @override
  String get import_export_confirm_title => 'Confirmar importación';

  @override
  String get import_export_confirm_info =>
      'Esto reemplazará todos los datos actuales. ¿Deseas continuar?';

  @override
  String get import_export_success_title => 'Importación exitosa';

  @override
  String get import_export_success_info => 'Los datos fueron importados.';

  @override
  String get import_export_error_title => 'Error al importar';

  @override
  String get dialog_project_edit_title => 'Editar Proyecto';

  @override
  String get dialog_project_new_title => 'Nuevo Proyecto';

  @override
  String get dialog_project_name_label => 'Nombre';

  @override
  String get dialog_project_name_placeholder => 'Ej: Inversión en Palma';

  @override
  String get dialog_project_description_label => 'Descripción (opcional)';

  @override
  String get dialog_project_description_placeholder =>
      'Describe el proyecto...';

  @override
  String get dialog_project_budget_label => 'Presupuesto Global (opcional)';

  @override
  String get dialog_activity_edit_title => 'Editar Actividad';

  @override
  String get dialog_activity_new_title => 'Nueva Actividad';

  @override
  String get dialog_activity_name_placeholder => 'Ej: Siembra 2025';

  @override
  String get dialog_activity_description_placeholder =>
      'Describe la actividad...';

  @override
  String get dialog_activity_year_label => 'Año';

  @override
  String get dialog_activity_budget_label => 'Presupuesto';

  @override
  String get dialog_activity_delete_title => 'Eliminar actividad';

  @override
  String get dialog_activity_delete_confirmation =>
      'Escribe el nombre de la actividad para confirmar:';

  @override
  String get dialog_tx_edit_expense => 'Editar Gasto';

  @override
  String get dialog_tx_edit_deposit => 'Editar Depósito';

  @override
  String get dialog_tx_edit_capital => 'Editar Inyección de capital';

  @override
  String get dialog_tx_new_deposit => 'Nuevo Depósito';

  @override
  String get dialog_tx_new_expense => 'Nuevo Gasto';

  @override
  String get dialog_tx_new_capital => 'Nueva Inyección de capital';

  @override
  String get dialog_tx_type_label => 'Tipo';

  @override
  String get dialog_tx_type_expense => 'Gasto';

  @override
  String get dialog_tx_type_deposit => 'Depósito';

  @override
  String get dialog_tx_type_capital => 'Capital';

  @override
  String get dialog_tx_amount_label => 'Monto';

  @override
  String get dialog_tx_date_label => 'Fecha';

  @override
  String get dialog_tx_description_placeholder =>
      'Detalle de la transacción...';

  @override
  String get dialog_tx_category_label => 'Categoría (opcional)';

  @override
  String get dialog_tx_category_select => 'Seleccionar Categoría';

  @override
  String get dialog_tx_category_none => 'Sin categoría';

  @override
  String get dialog_tx_delete_title => 'Eliminar transacción';

  @override
  String get dialog_tx_delete_confirm =>
      '¿Seguro que quieres eliminar esta transacción?';

  @override
  String get dialog_category_edit_project_title =>
      'Editar Categoría de Proyecto';

  @override
  String get dialog_category_new_project_title => 'Nueva Categoría de Proyecto';

  @override
  String get dialog_category_edit_title => 'Editar Categoría';

  @override
  String get dialog_category_new_title => 'Nueva Categoría';

  @override
  String get dialog_category_name_placeholder => 'Ej: Compra de palma';

  @override
  String get dialog_category_project_info =>
      'Esta categoría estará disponible en todas las actividades del proyecto.';

  @override
  String get widget_budget_progress_budget => 'Presupuesto:';

  @override
  String get widget_budget_progress_deposited => 'Depositado:';

  @override
  String get widget_budget_progress_spent => 'Gastado:';

  @override
  String get widget_tx_tile_project_label => '(proyecto)';
}
