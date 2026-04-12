import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';
import 'package:my_investments/sync/data/repositories/sync_repository.dart';
import 'package:my_investments/sync/data/sync_snapshot_codec.dart';
import 'package:my_investments/sync/domain/usecases/sync_service.dart';
import 'package:my_investments/core/storage/profile_ids.dart';
import 'package:my_investments/sync/data/datasources/sync_local_ds.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataConflictHandler {
  static Future<bool> handleConflictOrSync(
    BuildContext context,
    User user,
  ) async {
    final prefs = context.read<SharedPreferences>();
    final syncRepo = context.read<SyncRepository>();
    final syncService = context.read<SyncService>();

    final guestPlanningDs = PlanningLocalDataSource(
      prefs: prefs,
      profileId: guestProfileId,
    );
    final guestAccountsDs = AccountsLocalDataSource(
      prefs: prefs,
      profileId: guestProfileId,
    );
    final guestSyncLocalDs = SyncLocalDataSource(
      prefs: prefs,
      profileId: guestProfileId,
    );
    final userPlanningDs = PlanningLocalDataSource(
      prefs: prefs,
      profileId: userProfileId(user.id),
    );
    final userAccountsDs = AccountsLocalDataSource(
      prefs: prefs,
      profileId: userProfileId(user.id),
    );
    final userSyncLocalDs = SyncLocalDataSource(
      prefs: prefs,
      profileId: userProfileId(user.id),
    );

    final localProjects = guestPlanningDs.getProjects().length;
    final localActivities = guestPlanningDs.getActivities().length;
    final localCategories = guestPlanningDs.getCategories().length;
    final localTransactions = guestAccountsDs.getTransactions().length;
    final totalLocal =
        localProjects + localActivities + localCategories + localTransactions;

    if (totalLocal == 0) {
      // No local data, just try to pull cloud
      try {
        await syncService.pullIfRemoteNewer(
          userId: user.id,
          providers: [userPlanningDs, userAccountsDs],
        );
      } catch (_) {}
      return false; // no conflict
    }

    final rawSnapshot = await syncRepo.downloadSnapshot(user.id);
    if (rawSnapshot == null) {
      // No cloud data, push local data
      try {
        await _replaceUserWithGuestData(
          guestPlanningDs: guestPlanningDs,
          guestAccountsDs: guestAccountsDs,
          userPlanningDs: userPlanningDs,
          userAccountsDs: userAccountsDs,
          userSyncLocalDs: userSyncLocalDs,
        );
        await syncService.pushSnapshot(
          userId: user.id,
          providers: [userPlanningDs, userAccountsDs],
        );
      } catch (_) {}
      await _clearGuestData(
        guestPlanningDs: guestPlanningDs,
        guestAccountsDs: guestAccountsDs,
        guestSyncLocalDs: guestSyncLocalDs,
      );
      return false; // no conflict
    }

    final cloudData = SyncSnapshotCodec.decode(rawSnapshot);
    final cloudProjects = cloudData['projects']?.length ?? 0;
    final cloudActivities = cloudData['activities']?.length ?? 0;
    final cloudCategories = cloudData['categories']?.length ?? 0;
    final cloudTransactions = cloudData['transactions']?.length ?? 0;
    final totalCloud =
        cloudProjects + cloudActivities + cloudCategories + cloudTransactions;

    if (totalCloud == 0) {
      try {
        await _replaceUserWithGuestData(
          guestPlanningDs: guestPlanningDs,
          guestAccountsDs: guestAccountsDs,
          userPlanningDs: userPlanningDs,
          userAccountsDs: userAccountsDs,
          userSyncLocalDs: userSyncLocalDs,
        );
        await syncService.pushSnapshot(
          userId: user.id,
          providers: [userPlanningDs, userAccountsDs],
        );
      } catch (_) {}
      await _clearGuestData(
        guestPlanningDs: guestPlanningDs,
        guestAccountsDs: guestAccountsDs,
        guestSyncLocalDs: guestSyncLocalDs,
      );
      return false;
    }

    // We have data in both
    bool? keepLocal = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Conflicto de Datos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hemos detectado datos tanto locales como en la nube. '
                '¿Cuáles deseas conservar? (La otra fuente será sobreescrita)',
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'En Dispositivo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Proyectos: \$localProjects'),
                        Text('Actividades: \$localActivities'),
                        Text('Categorías: \$localCategories'),
                        Text('Transacciones: \$localTransactions'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'En la Nube',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Proyectos: \$cloudProjects'),
                        Text('Actividades: \$cloudActivities'),
                        Text('Categorías: \$cloudCategories'),
                        Text('Transacciones: \$cloudTransactions'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.pop(ctx, false), // Keep Cloud
              child: const Text('Descargar Nube'),
            ),
            PrimaryButton(
              onPressed: () => Navigator.pop(ctx, true), // Keep Local
              child: const Text('Mantener Local'),
            ),
          ],
        );
      },
    );

    if (keepLocal == true) {
      // Wipe cloud and push new snapshot (from guest into user)
      await _replaceUserWithGuestData(
        guestPlanningDs: guestPlanningDs,
        guestAccountsDs: guestAccountsDs,
        userPlanningDs: userPlanningDs,
        userAccountsDs: userAccountsDs,
        userSyncLocalDs: userSyncLocalDs,
      );
      final currentLocalData = {
        'projects': userPlanningDs.exportSnapshot()['projects'] ?? [],
        'activities': userPlanningDs.exportSnapshot()['activities'] ?? [],
        'categories': userPlanningDs.exportSnapshot()['categories'] ?? [],
        'accounts': userAccountsDs.exportSnapshot()['accounts'] ?? [],
        'transactions': userAccountsDs.exportSnapshot()['transactions'] ?? [],
      };
      final encoded = SyncSnapshotCodec.encode(currentLocalData);
      await syncRepo.uploadSnapshot(user.id, encoded);
      await userSyncLocalDs.clearPendingChanges();
    } else {
      // Wipe local and import snapshot
      await userPlanningDs.saveProjects([]);
      await userPlanningDs.saveActivities([]);
      await userPlanningDs.saveCategories([]);
      await userAccountsDs.saveFinancialAccounts([]);
      await userAccountsDs.saveTransactions([]);

      await userPlanningDs.importSnapshot(cloudData);
      await userAccountsDs.importSnapshot(cloudData);
      await userSyncLocalDs.clearPendingChanges();
    }
    await _clearGuestData(
      guestPlanningDs: guestPlanningDs,
      guestAccountsDs: guestAccountsDs,
      guestSyncLocalDs: guestSyncLocalDs,
    );
    return true;
  }

  static Future<void> _replaceUserWithGuestData({
    required PlanningLocalDataSource guestPlanningDs,
    required AccountsLocalDataSource guestAccountsDs,
    required PlanningLocalDataSource userPlanningDs,
    required AccountsLocalDataSource userAccountsDs,
    required SyncLocalDataSource userSyncLocalDs,
  }) async {
    final guestSnapshot = {
      'projects': guestPlanningDs.exportSnapshot()['projects'] ?? [],
      'activities': guestPlanningDs.exportSnapshot()['activities'] ?? [],
      'categories': guestPlanningDs.exportSnapshot()['categories'] ?? [],
      'accounts': guestAccountsDs.exportSnapshot()['accounts'] ?? [],
      'transactions': guestAccountsDs.exportSnapshot()['transactions'] ?? [],
    };
    await userPlanningDs.saveProjects([]);
    await userPlanningDs.saveActivities([]);
    await userPlanningDs.saveCategories([]);
    await userAccountsDs.saveFinancialAccounts([]);
    await userAccountsDs.saveTransactions([]);
    await userPlanningDs.importSnapshot(guestSnapshot);
    await userAccountsDs.importSnapshot(guestSnapshot);
    await userSyncLocalDs.clearPendingChanges();
  }

  static Future<void> _clearGuestData({
    required PlanningLocalDataSource guestPlanningDs,
    required AccountsLocalDataSource guestAccountsDs,
    required SyncLocalDataSource guestSyncLocalDs,
  }) async {
    await guestPlanningDs.saveProjects([]);
    await guestPlanningDs.saveActivities([]);
    await guestPlanningDs.saveCategories([]);
    await guestAccountsDs.saveFinancialAccounts([]);
    await guestAccountsDs.saveTransactions([]);
    await guestSyncLocalDs.clearPendingChanges();
  }
}
