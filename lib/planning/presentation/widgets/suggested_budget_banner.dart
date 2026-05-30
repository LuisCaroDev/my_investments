import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:my_investments/core/extensions/currency_ext.dart';

class SuggestedBudgetBanner extends StatelessWidget {
  final double suggestedBudget;
  final VoidCallback onUpdate;

  const SuggestedBudgetBanner({
    super.key,
    required this.suggestedBudget,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedBudget = suggestedBudget.toCompactCurrency(context);

    return Alert(
      title: Row(
        spacing: 4,
        children: [
          Icon(RadixIcons.infoCircled),
          Text(l10n.common_auto_update_budget_label),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'El presupuesto calculado en base a gastos y actividades ($formattedBudget) es mayor al actual. ¿Deseas actualizarlo?',
          ),
          const Gap(12),
          PrimaryButton(
            size: ButtonSize.small,
            onPressed: onUpdate,
            child: const Text('Actualizar presupuesto'),
          ),
        ],
      ),
    );
  }
}
