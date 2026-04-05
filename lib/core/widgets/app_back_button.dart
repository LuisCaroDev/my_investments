import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppBackButton extends StatelessWidget {
  static List<Widget> render(BuildContext context, {IconData? icon}) {
    if (!Navigator.of(context).canPop()) {
      return [];
    }

    return [AppBackButton._(icon: icon)];
  }

  const AppBackButton._({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return const SizedBox.shrink();
    }

    return IconButton.outline(
      onPressed: () => Navigator.of(context).pop(),
      icon: Icon(icon ?? RadixIcons.chevronLeft),
      size: ButtonSize.small,
      density: ButtonDensity.icon,
    );
  }
}
