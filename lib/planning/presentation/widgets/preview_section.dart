import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/planning/presentation/widgets/section_header.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PreviewSection<T> extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final Widget? headerBottom;
  final List<T> items;
  final int previewCount;
  final double spacing;
  final double emptyTopSpacing;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final List<T> Function(List<T> items)? transformItems;

  const PreviewSection({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.headerBottom,
    this.previewCount = 3,
    this.spacing = 8,
    this.emptyTopSpacing = 12,
    this.transformItems,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems =
        (transformItems == null ? items : transformItems!(items))
            .take(previewCount)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          actionLabel: actionLabel,
          onAction: onAction,
          trailing: trailing,
        ),
        if (headerBottom != null) ...[
          const Gap(12),
          headerBottom!,
        ],
        if (items.isEmpty) ...[
          Gap(emptyTopSpacing),
          EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          ),
        ] else ...[
          Gap(spacing),
          Column(
            spacing: spacing,
            children: visibleItems.map((item) => itemBuilder(context, item)).toList(),
          ),
        ],
      ],
    );
  }
}
