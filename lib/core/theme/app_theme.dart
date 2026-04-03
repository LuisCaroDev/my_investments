import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(colorScheme: ColorSchemes.lightStone, radius: 0.75);
  }

  static ThemeData dark() {
    return ThemeData(colorScheme: ColorSchemes.darkStone, radius: 0.75);
  }
}
