import 'package:shadcn_flutter/shadcn_flutter.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.minHeight,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: Alignment.center,
      constraints: minHeight != null
          ? BoxConstraints(minHeight: minHeight!)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: child,
      ),
    );
  }
}
