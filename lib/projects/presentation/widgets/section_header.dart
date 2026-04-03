import 'package:shadcn_flutter/shadcn_flutter.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title).large.bold),
        if (actionLabel != null && onAction != null)
          GhostButton(
            onPressed: onAction,
            size: ButtonSize.small,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
