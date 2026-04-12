class SyncPaths {
  static const bucket = 'backups';

  static String userRoot(String userId) => userId;

  static String manifestPath(String userId) =>
      '${userRoot(userId)}/manifest.json';

  static String latestCsvPath(String userId) =>
      '${userRoot(userId)}/latest.csv';

  static String latestSnapshotPath(String userId) =>
      '${userRoot(userId)}/latest.json';
}
