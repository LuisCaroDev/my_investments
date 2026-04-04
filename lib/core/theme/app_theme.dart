import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorSchemes.lightSlate.emerald,
      radius: 0.75,
    );
  }

  static ThemeData dark() {
    return ThemeData(colorScheme: ColorSchemes.darkSlate.emerald, radius: 0.75);
  }
}
