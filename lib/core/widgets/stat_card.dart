import 'package:shadcn_flutter/shadcn_flutter.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon!, size: 14, color: theme.colorScheme.mutedForeground),
                const Gap(6),
              ],
              Expanded(
                child: Text(label).muted.small,
              ),
            ],
          ),
          const Gap(8),
          valueColor != null
              ? Text(value).large.bold(color: valueColor)
              : Text(value).large.bold,
        ],
      ),
    );
  }
}
