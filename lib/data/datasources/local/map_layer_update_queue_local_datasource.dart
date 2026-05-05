import 'package:hive/hive.dart';

class PendingMapLayerUpdate {
  final String queueId;
  final String layerId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  const PendingMapLayerUpdate({
    required this.queueId,
    required this.layerId,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
  });

  PendingMapLayerUpdate copyWith({int? retryCount, String? lastError}) {
    return PendingMapLayerUpdate(
      queueId: queueId,
      layerId: layerId,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'queue_id': queueId,
      'layer_id': layerId,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
      'last_error': lastError,
    };
  }

  static PendingMapLayerUpdate fromMap(Map<dynamic, dynamic> map) {
    final payloadValue = map['payload'];
    final payload = payloadValue is Map
        ? Map<String, dynamic>.from(payloadValue)
        : <String, dynamic>{};

    return PendingMapLayerUpdate(
      queueId: map['queue_id']?.toString() ?? '',
      layerId: map['layer_id']?.toString() ?? '',
      payload: payload,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      retryCount: (map['retry_count'] as num?)?.toInt() ?? 0,
      lastError: map['last_error']?.toString(),
    );
  }
}

abstract class MapLayerUpdateQueueLocalDataSource {
  Future<void> enqueue({
    required String queueId,
    required String layerId,
    required Map<String, dynamic> payload,
  });

  Future<List<PendingMapLayerUpdate>> getAll();
  Future<void> remove(String queueId);
  Future<void> markAttemptFailed({
    required String queueId,
    required String error,
  });
}

class MapLayerUpdateQueueLocalDataSourceImpl
    implements MapLayerUpdateQueueLocalDataSource {
  static const String _boxName = 'pending_map_layer_updates';

  Future<Box<Map>> _openBox() async {
    return Hive.openBox<Map>(_boxName);
  }

  @override
  Future<void> enqueue({
    required String queueId,
    required String layerId,
    required Map<String, dynamic> payload,
  }) async {
    final box = await _openBox();
    final item = PendingMapLayerUpdate(
      queueId: queueId,
      layerId: layerId,
      payload: payload,
      createdAt: DateTime.now(),
      retryCount: 0,
    );
    await box.put(queueId, item.toMap());
  }

  @override
  Future<List<PendingMapLayerUpdate>> getAll() async {
    final box = await _openBox();

    final items =
        box.values
            .map((raw) => PendingMapLayerUpdate.fromMap(raw))
            .where((item) => item.queueId.isNotEmpty && item.layerId.isNotEmpty)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return items;
  }

  @override
  Future<void> remove(String queueId) async {
    final box = await _openBox();
    await box.delete(queueId);
  }

  @override
  Future<void> markAttemptFailed({
    required String queueId,
    required String error,
  }) async {
    final box = await _openBox();
    final raw = box.get(queueId);
    if (raw == null) return;

    final current = PendingMapLayerUpdate.fromMap(raw);
    final updated = current.copyWith(
      retryCount: current.retryCount + 1,
      lastError: error,
    );

    await box.put(queueId, updated.toMap());
  }
}
