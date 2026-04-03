import 'package:shadcn_flutter/shadcn_flutter.dart';

class ShadcnLocalizationsEs extends ShadcnLocalizations {
  ShadcnLocalizationsEs([super.locale = 'es']);

  @override
  String get formNotEmpty => 'Este campo no puede estar vacío';

  @override
  String get invalidValue => 'Valor inválido';

  @override
  String get invalidEmail => 'Correo electrónico inválido';

  @override
  String get invalidURL => 'URL inválida';

  @override
  String formLessThan(double value) => 'Debe ser menor que $value';

  @override
  String formGreaterThan(double value) => 'Debe ser mayor que $value';

  @override
  String formLessThanOrEqualTo(double value) =>
      'Debe ser menor o igual que $value';

  @override
  String formGreaterThanOrEqualTo(double value) =>
      'Debe ser mayor o igual que $value';

  @override
  String formBetweenInclusively(double min, double max) =>
      'Debe estar entre $min y $max (inclusive)';

  @override
  String formBetweenExclusively(double min, double max) =>
      'Debe estar entre $min y $max (exclusivo)';

  @override
  String formLengthLessThan(int value) => 'Debe tener al menos $value caracteres';

  @override
  String formLengthGreaterThan(int value) =>
      'Debe tener como máximo $value caracteres';

  @override
  String get formPasswordDigits => 'Debe contener al menos un dígito';

  @override
  String get formPasswordLowercase => 'Debe contener al menos una minúscula';

  @override
  String get formPasswordUppercase => 'Debe contener al menos una mayúscula';

  @override
  String get formPasswordSpecial => 'Debe contener al menos un carácter especial';

  @override
  String get commandSearch => 'Escribe un comando o busca...';

  @override
  String get commandEmpty => 'No se encontraron resultados.';

  @override
  String get datePickerSelectYear => 'Seleccionar un año';

  @override
  String get abbreviatedMonday => 'Lu';

  @override
  String get abbreviatedTuesday => 'Ma';

  @override
  String get abbreviatedWednesday => 'Mi';

  @override
  String get abbreviatedThursday => 'Ju';

  @override
  String get abbreviatedFriday => 'Vi';

  @override
  String get abbreviatedSaturday => 'Sá';

  @override
  String get abbreviatedSunday => 'Do';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get abbreviatedJanuary => 'Ene';

  @override
  String get abbreviatedFebruary => 'Feb';

  @override
  String get abbreviatedMarch => 'Mar';

  @override
  String get abbreviatedApril => 'Abr';

  @override
  String get abbreviatedMay => 'May';

  @override
  String get abbreviatedJune => 'Jun';

  @override
  String get abbreviatedJuly => 'Jul';

  @override
  String get abbreviatedAugust => 'Ago';

  @override
  String get abbreviatedSeptember => 'Sep';

  @override
  String get abbreviatedOctober => 'Oct';

  @override
  String get abbreviatedNovember => 'Nov';

  @override
  String get abbreviatedDecember => 'Dic';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonSave => 'Guardar';

  @override
  String get timeHour => 'Hora';

  @override
  String get timeMinute => 'Minuto';

  @override
  String get timeSecond => 'Segundo';

  @override
  String get timeAM => 'AM';

  @override
  String get timePM => 'PM';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorAlpha => 'Alfa';

  @override
  String get colorHue => 'Tono';

  @override
  String get colorSaturation => 'Sat';

  @override
  String get colorValue => 'Val';

  @override
  String get colorLightness => 'Lum';

  @override
  String get menuCut => 'Cortar';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuPaste => 'Pegar';

  @override
  String get menuSelectAll => 'Seleccionar todo';

  @override
  String get menuUndo => 'Deshacer';

  @override
  String get menuRedo => 'Rehacer';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get menuShare => 'Compartir';

  @override
  String get menuSearchWeb => 'Buscar en la web';

  @override
  String get menuLiveTextInput => 'Entrada de texto en vivo';

  @override
  String get placeholderDatePicker => 'Seleccionar fecha';

  @override
  String get placeholderTimePicker => 'Seleccionar hora';

  @override
  String get placeholderColorPicker => 'Seleccionar color';

  @override
  String get buttonPrevious => 'Anterior';

  @override
  String get buttonNext => 'Siguiente';

  @override
  String get refreshTriggerPull => 'Tirar para refrescar';

  @override
  String get refreshTriggerRelease => 'Soltar para refrescar';

  @override
  String get refreshTriggerRefreshing => 'Refrescando...';

  @override
  String get refreshTriggerComplete => 'Refresco completado';

  @override
  String get colorPickerTabRecent => 'Reciente';

  @override
  String get colorPickerTabRGB => 'RGB';

  @override
  String get colorPickerTabHSV => 'HSV';

  @override
  String get colorPickerTabHSL => 'HSL';

  @override
  String get colorPickerTabHEX => 'HEX';

  @override
  String get commandMoveUp => 'Mover arriba';

  @override
  String get commandMoveDown => 'Mover abajo';

  @override
  String get commandActivate => 'Seleccionar';

  @override
  String dataTableSelectedRows(int count, int total) =>
      '$count de $total fila(s) seleccionadas.';

  @override
  String get dataTableNext => 'Siguiente';

  @override
  String get dataTablePrevious => 'Anterior';

  @override
  String get dataTableColumns => 'Columnas';

  @override
  String get timeDaysAbbreviation => 'DD';

  @override
  String get timeHoursAbbreviation => 'HH';

  @override
  String get timeMinutesAbbreviation => 'MM';

  @override
  String get timeSecondsAbbreviation => 'SS';

  @override
  String get placeholderDurationPicker => 'Seleccionar duración';

  @override
  String get durationDay => 'Día';

  @override
  String get durationHour => 'Hora';

  @override
  String get durationMinute => 'Minuto';

  @override
  String get durationSecond => 'Segundo';
}
