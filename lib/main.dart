import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/theme/app_theme.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/presentation/bloc/projects_cubit.dart';
import 'package:my_investments/projects/presentation/pages/projects_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyInvestmentsApp(prefs: prefs));
}

class MyInvestmentsApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyInvestmentsApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final ds = ProjectsLocalDataSource(prefs: prefs);
    final repo = ProjectsRepository(localDataSource: ds);

    return BlocProvider(
      create: (_) => ProjectsCubit(repository: repo)..loadProjects(),
      child: ShadcnApp(
        title: 'My Investments',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const ProjectsPage(),
      ),
    );
  }
}
