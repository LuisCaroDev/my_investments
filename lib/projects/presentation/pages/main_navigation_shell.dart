import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/projects/presentation/pages/accounts_page.dart';
import 'package:my_investments/projects/presentation/pages/goals_page.dart';
import 'package:my_investments/projects/presentation/pages/investments_page.dart';
import 'package:my_investments/core/presentation/pages/settings_page.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_state.dart';
import 'package:my_investments/projects/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/investments_cubit.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final pages = [
      const InvestmentsPage(),
      const GoalsPage(),
      const AccountsPage(),
      const SettingsPage(),
    ];

    // const buttonStyle = ButtonStyle.ghost(density: ButtonDensity.icon);
    // const selectedButtonStyle = ButtonStyle.fixed(density: ButtonDensity.icon);

    return BlocListener<AccountsCubit, AccountsState>(
      listener: (context, state) {
        if (state is AccountsLoaded) {
          context.read<InvestmentsCubit>().loadInvestments();
          context.read<GoalsCubit>().loadGoals();
        }
      },
      child: Scaffold(
        footers: isDesktop
            ? const []
            : [
                Divider(height: 1),
                NavigationBar(
                  expanded: true,
                  alignment: NavigationBarAlignment.spaceBetween,
                  keepMainAxisSize: true,
                  keepCrossAxisSize: true,
                  onSelected: (key) {
                    if (key is ValueKey<int>) {
                      setState(() => _selectedIndex = key.value);
                    }
                  },
                  selectedKey: ValueKey(_selectedIndex),
                  children: [
                    Expanded(
                      child: NavigationItem(
                        key: const ValueKey<int>(0),
                        label: Text(l10n.nav_investments),
                        child: const Icon(RadixIcons.cube),
                      ),
                    ),
                    Gap(4),
                    Expanded(
                      child: NavigationItem(
                        key: const ValueKey<int>(1),
                        label: Text(l10n.nav_goals),
                        child: const Icon(RadixIcons.target),
                      ),
                    ),
                    Gap(4),
                    Expanded(
                      child: NavigationItem(
                        key: const ValueKey<int>(2),
                        label: Text(l10n.nav_accounts),
                        child: const Icon(RadixIcons.pieChart),
                      ),
                    ),
                    Gap(4),
                    Expanded(
                      child: NavigationItem(
                        key: const ValueKey<int>(3),
                        label: Text(l10n.settings_title),
                        child: const Icon(RadixIcons.gear),
                      ),
                    ),
                  ],
                ),
                Gap(MediaQuery.of(context).padding.bottom),
              ],
        child: isDesktop
            ? Row(
                children: [
                  NavigationSidebar(
                    header: [
                      SliverToBoxAdapter(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text('Workspace').h4.muted,
                            ),
                            Divider(height: 1),
                          ],
                        ),
                      ),
                    ],
                    spacing: 4,
                    selectedKey: ValueKey(_selectedIndex),
                    onSelected: (key) {
                      if (key is ValueKey<int>) {
                        setState(() => _selectedIndex = key.value);
                      }
                    },
                    children: [
                      NavigationItem(
                        key: const ValueKey<int>(0),
                        label: Text(l10n.nav_investments),
                        child: const Icon(RadixIcons.cube),
                      ),
                      NavigationItem(
                        key: const ValueKey<int>(1),
                        label: Text(l10n.nav_goals),
                        child: const Icon(RadixIcons.target),
                      ),
                      NavigationItem(
                        key: const ValueKey<int>(2),
                        label: Text(l10n.nav_accounts),
                        child: const Icon(RadixIcons.pieChart),
                      ),
                      NavigationItem(
                        key: const ValueKey<int>(3),
                        label: Text(l10n.settings_title),
                        child: const Icon(RadixIcons.gear),
                      ),
                    ],
                  ),
                  VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(index: _selectedIndex, children: pages),
                  ),
                ],
              )
            : IndexedStack(index: _selectedIndex, children: pages),
      ),
    );
  }
}
