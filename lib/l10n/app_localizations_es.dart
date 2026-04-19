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
  String get common_category => 'Tarea';

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
  String get projects_summary_funded => 'Financiado';

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
      'Escribe el nombre del proyecto para confirmar. Se eliminarán sus actividades, tareas y transacciones.';

  @override
  String get project_detail_summary_deposited => 'Depositado';

  @override
  String get project_detail_summary_spent => 'Gasto Total';

  @override
  String get project_detail_summary_operating => 'Balance Operativo';

  @override
  String get project_detail_summary_net_balance => 'Balance Neto';

  @override
  String get project_detail_summary_budget => 'Presupuesto';

  @override
  String get project_detail_categories_title => 'Tareas';

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
  String get activity_detail_summary_net_balance => 'Balance Neto';

  @override
  String get activity_detail_summary_budget => 'Presupuesto';

  @override
  String get activity_detail_categories_title => 'Tareas';

  @override
  String get activity_detail_add_category_button => 'Tarea';

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
  String get transaction_list_filter_category => 'Filtrar por tarea';

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
  String get category_mgmt_activity_title => 'Tareas de la Actividad';

  @override
  String get category_mgmt_project_title => 'Tareas del Proyecto';

  @override
  String get category_mgmt_empty => 'No hay tareas todavía.';

  @override
  String get settings_title => 'Configuración';

  @override
  String get settings_account_title => 'Cuenta';

  @override
  String get settings_sync_title => 'Sincronización y Cuenta';

  @override
  String get settings_local_mode_title => 'Modo Local Independiente';

  @override
  String get settings_local_mode_info =>
      'Tus datos se guardan en este dispositivo.';

  @override
  String get settings_login_button => 'Iniciar sesión';

  @override
  String get settings_logout_button => 'Cerrar sesión';

  @override
  String get settings_guest_logout_button => 'Salir de invitado';

  @override
  String get settings_sync_logged_in => 'Sesión iniciada';

  @override
  String get settings_sync_logged_in_info =>
      'Tus datos pueden sincronizarse con la nube.';

  @override
  String get settings_sync_status_label => 'Estado de sincronización';

  @override
  String get settings_sync_last_sync_label => 'Última sincronización';

  @override
  String get settings_sync_pending_label => 'Cambios pendientes';

  @override
  String get settings_sync_mode_title => 'Modo online';

  @override
  String get settings_sync_mode_info =>
      'Sincroniza y respalda tus datos automáticamente.';

  @override
  String get settings_sync_never => 'Nunca';

  @override
  String get settings_sync_backup_button => 'Hacer backup';

  @override
  String get settings_sync_restore_button => 'Restaurar desde la nube';

  @override
  String get settings_sync_not_configured => 'Supabase no está configurado.';

  @override
  String get settings_sync_not_logged_in => 'Necesitas iniciar sesión.';

  @override
  String get settings_sync_email_title => 'Email para iniciar sesión';

  @override
  String get settings_sync_email_hint => 'tu@correo.com';

  @override
  String get settings_sync_send_link_button => 'Enviar magic link';

  @override
  String get settings_sync_link_sent =>
      'Revisa tu correo para completar el inicio de sesión.';

  @override
  String get settings_sync_backup_success => 'Backup completado.';

  @override
  String get settings_sync_restore_success => 'Restauración completada.';

  @override
  String get settings_sync_restore_not_found =>
      'No se encontró backup en la nube.';

  @override
  String get settings_sync_up_to_date => 'Ya está actualizado.';

  @override
  String get settings_sync_error_title => 'Error de sincronización';

  @override
  String get settings_preferences_title => 'Preferencias';

  @override
  String get settings_language_label => 'Idioma de la App';

  @override
  String get settings_theme_label => 'Tema de la App';

  @override
  String get settings_currency_label => 'Tipo de Moneda';

  @override
  String get settings_system_default => 'Sistema';

  @override
  String get settings_theme_light => 'Claro';

  @override
  String get settings_theme_dark => 'Oscuro';

  @override
  String get settings_language_dialog_title => 'Seleccionar Idioma';

  @override
  String get settings_theme_dialog_title => 'Seleccionar Tema';

  @override
  String get settings_data_title => 'Datos';

  @override
  String get settings_data_sync_title => 'Datos y Sincronización';

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
  String get dialog_tx_new_deposit => 'Nuevo Depósito';

  @override
  String get dialog_tx_new_expense => 'Nuevo Gasto';

  @override
  String get dialog_tx_type_label => 'Tipo';

  @override
  String get dialog_tx_type_expense => 'Gasto';

  @override
  String get dialog_tx_type_deposit => 'Depósito';

  @override
  String get dialog_tx_amount_label => 'Monto';

  @override
  String get dialog_tx_date_label => 'Fecha';

  @override
  String get dialog_tx_description_placeholder =>
      'Detalle de la transacción...';

  @override
  String get dialog_tx_account_select => 'Seleccionar Cuenta';

  @override
  String get dialog_tx_category_label => 'Tarea (opcional)';

  @override
  String get dialog_tx_category_select => 'Seleccionar Tarea';

  @override
  String get dialog_tx_category_none => 'Sin tarea';

  @override
  String get dialog_tx_delete_title => 'Eliminar transacción';

  @override
  String get dialog_tx_delete_confirm =>
      '¿Seguro que quieres eliminar esta transacción?';

  @override
  String get dialog_category_edit_project_title => 'Editar Tarea de Proyecto';

  @override
  String get dialog_category_new_project_title => 'Nueva Tarea de Proyecto';

  @override
  String get dialog_category_edit_title => 'Editar Tarea';

  @override
  String get dialog_category_new_title => 'Nueva Tarea';

  @override
  String get dialog_category_name_placeholder => 'Ej: Fumigación';

  @override
  String get dialog_category_project_info =>
      'Esta tarea estará disponible en todas las actividades del proyecto.';

  @override
  String get widget_budget_progress_budget => 'Presupuesto:';

  @override
  String get widget_budget_progress_deposited => 'Depositado:';

  @override
  String get widget_budget_progress_spent => 'Gastado:';

  @override
  String get widget_budget_progress_funded => 'Financiado:';

  @override
  String get widget_budget_progress_remaining => 'Por Financiar:';

  @override
  String get widget_tx_tile_project_label => '(proyecto)';

  @override
  String get nav_investments => 'Inversiones';

  @override
  String get nav_goals => 'Metas';

  @override
  String get nav_accounts => 'Cuentas';

  @override
  String get goals_title => 'Metas de Ahorro';

  @override
  String get goals_empty =>
      'Aún no hay metas de ahorro. ¡Agrega tu primera meta!';

  @override
  String get accounts_title => 'Cuentas Financieras';

  @override
  String get accounts_empty => 'Aún no hay cuentas agregadas.';

  @override
  String get dialog_priority_title => 'Prioridades de Proyectos';

  @override
  String get dialog_account_title => 'Agregar Cuenta';

  @override
  String get dialog_account_name => 'Nombre de la Cuenta';

  @override
  String get dialog_account_type => 'Tipo de Cuenta';

  @override
  String get dialog_account_type_bank => 'Banco';

  @override
  String get dialog_account_type_loan => 'Préstamo';

  @override
  String get dialog_account_balance_label => 'Saldo';

  @override
  String get auth_login_title => 'Iniciar sesión';

  @override
  String get auth_verify_title => 'Verificar Código';

  @override
  String get auth_login_success =>
      'Sesión iniciada correctamente. Sus datos se han sincronizado.';

  @override
  String get auth_login_error_title => 'Error';

  @override
  String get auth_login_success_title => 'Éxito';

  @override
  String get auth_email_view_title => 'Ingresa tu correo';

  @override
  String get auth_email_view_subtitle =>
      'Te enviaremos un código de seguridad para verificar tu cuenta y sincronizar tus proyectos.';

  @override
  String get auth_email_label => 'DIRECCIÓN DE CORREO ELECTRÓNICO';

  @override
  String get auth_email_placeholder => 'correo@ejemplo.com';

  @override
  String get auth_email_helper =>
      'Te enviaremos un código de 8 dígitos al correo para validar tu acceso de forma segura.';

  @override
  String get auth_email_send_button => 'Enviar código';

  @override
  String get auth_continue_with => 'O CONTINUAR CON';

  @override
  String get auth_continue_apple => 'Continuar con Apple';

  @override
  String get auth_continue_google => 'Continuar con Google';

  @override
  String get auth_otp_view_title => 'Revisa tu correo';

  @override
  String auth_otp_view_subtitle(Object email) {
    return 'Hemos enviado un código de seguridad de 8 dígitos a: $email';
  }

  @override
  String get auth_otp_label => 'CÓDIGO DE ACCESO';

  @override
  String get auth_otp_helper => 'Ingresa los 8 dígitos recibidos';

  @override
  String get auth_otp_verify_button => 'Verificar';

  @override
  String get auth_otp_resend_button => 'Reenviar código';

  @override
  String get auth_otp_spam_helper =>
      '¿No recibiste nada? Revisa tu carpeta de spam.';

  @override
  String get auth_terms_prefix => 'Al continuar, aceptas nuestros ';

  @override
  String get auth_terms_service => 'Términos de Servicio';

  @override
  String get auth_terms_and => ' y ';

  @override
  String get auth_terms_privacy => 'Política de Privacidad';

  @override
  String get auth_terms_suffix => '.';

  @override
  String get welcome_title_prefix => 'Bienvenido a';

  @override
  String get welcome_title_suffix => 'Mis Inversiones';

  @override
  String get welcome_subtitle =>
      'Toma el control de tus metas y proyectos con herramientas de nivel profesional.';

  @override
  String get welcome_feature1_title => 'Gestión de Proyectos';

  @override
  String get welcome_feature1_desc =>
      'Sigue tus proyectos y metas de ahorro con datos precisos.';

  @override
  String get welcome_feature2_title => 'Sincronización Total';

  @override
  String get welcome_feature2_desc =>
      'Accede a tus datos desde cualquier dispositivo iniciando sesión.';

  @override
  String get welcome_feature3_title => 'Local y Privado';

  @override
  String get welcome_feature3_desc =>
      'Tus datos son tuyos. Guárdalos localmente o sincronízalos de forma segura.';

  @override
  String get welcome_login_button => 'Iniciar sesión';

  @override
  String get welcome_guest_button => 'Continuar como invitado';
}
