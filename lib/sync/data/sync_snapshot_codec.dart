import 'dart:convert';

class SyncSnapshotCodec {
  static const currentVersion = 1;

  static String encode(Map<String, List<Map<String, dynamic>>> data) {
    return jsonEncode({
      'version': currentVersion,
      'data': data,
    });
  }

  static Map<String, List<Map<String, dynamic>>> decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in data.entries) {
      final list = (entry.value as List?) ?? [];
      result[entry.key] = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return result;
  }
}
