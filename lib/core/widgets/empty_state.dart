import 'package:shadcn_flutter/shadcn_flutter.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.mutedForeground,
            ),
            const Gap(16),
            Text(title).large.medium,
            if (subtitle != null) ...[
              const Gap(8),
              Text(subtitle!).muted.textCenter,
            ],
            if (action != null) ...[
              const Gap(20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
