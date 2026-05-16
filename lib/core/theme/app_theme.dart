import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorSchemes.lightSlate.emerald,
      radius: 0.6,
      scaling: .8,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorSchemes.darkSlate.emerald,
      radius: .6,
      scaling: .8,
    );
  }
}
