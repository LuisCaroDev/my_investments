import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:my_investments/sync/data/sync_paths.dart';
import 'package:my_investments/sync/domain/entities/sync_manifest.dart';

class SyncRemoteDataSource {
  final SupabaseClient _client;

  const SyncRemoteDataSource({required SupabaseClient client})
    : _client = client;

  Future<SyncManifest?> fetchManifest({required String userId}) async {
    try {
      final data = await _client.storage
          .from(SyncPaths.bucket)
          .download(SyncPaths.manifestPath(userId));
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return SyncManifest.fromJson(json);
    } on Exception {
      return null;
    }
  }

  Future<void> uploadManifest({
    required String userId,
    required SyncManifest manifest,
  }) async {
    final bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(manifest.toJson())),
    );
    await _client.storage
        .from(SyncPaths.bucket)
        .uploadBinary(
          SyncPaths.manifestPath(userId),
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'application/json',
          ),
        );
  }

  Future<String?> downloadSnapshot({required String userId}) async {
    try {
      final data = await _client.storage
          .from(SyncPaths.bucket)
          .download(SyncPaths.latestSnapshotPath(userId));
      return utf8.decode(data);
    } on Exception {
      return null;
    }
  }

  Future<void> uploadSnapshot({
    required String userId,
    required String snapshot,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(snapshot));
    final path = SyncPaths.latestSnapshotPath(userId);
    log('path $path');
    await _client.storage
        .from(SyncPaths.bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'application/json',
          ),
        );
  }
}
