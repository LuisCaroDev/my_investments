import 'package:shadcn_flutter/shadcn_flutter.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title).large.bold),
            if (actionLabel != null && onAction != null)
              GhostButton(
                onPressed: onAction,
                size: ButtonSize.small,
                child: Text(actionLabel!),
              ),
            if (trailing != null) ...[
              const Gap(4),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}
