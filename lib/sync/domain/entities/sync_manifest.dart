class SyncManifest {
  final int version;
  final DateTime updatedAt;
  final String deviceId;
  final String? checksum;

  const SyncManifest({
    required this.version,
    required this.updatedAt,
    required this.deviceId,
    this.checksum,
  });

  factory SyncManifest.fromJson(Map<String, dynamic> json) {
    return SyncManifest(
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      checksum: json['checksum'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
      if (checksum != null) 'checksum': checksum,
    };
  }
}
