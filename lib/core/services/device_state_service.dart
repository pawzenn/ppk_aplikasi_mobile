// lib/core/services/device_state_service.dart
import 'package:firebase_database/firebase_database.dart';

class DeviceStatus {
  final bool isOnline;
  final DateTime? lastSeen;

  const DeviceStatus({
    required this.isOnline,
    required this.lastSeen,
  });
}

class DeviceStateService {
  DeviceStateService._();
  static final instance = DeviceStateService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Stream status alat dari node state/{lahanId}
  Stream<DeviceStatus> watchDeviceStatus(
    String lahanId, {
    Duration onlineThreshold = const Duration(minutes: 2),
  }) {
    final ref = _db.ref('state/$lahanId');

    return ref.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) {
        return const DeviceStatus(isOnline: false, lastSeen: null);
      }

      final map =
          raw is Map ? Map<dynamic, dynamic>.from(raw) : <dynamic, dynamic>{};
      final ts = map['last_seen'];

      DateTime? lastSeen;
      bool isOnline = false;

      if (ts is int) {
        // bisa detik atau milidetik
        lastSeen = DateTime.fromMillisecondsSinceEpoch(
          ts > 2000000000 ? ts : ts * 1000,
        ).toLocal();

        final now = DateTime.now();
        final diff = now.difference(lastSeen).abs();
        isOnline = diff <= onlineThreshold;
      }

      return DeviceStatus(
        isOnline: isOnline,
        lastSeen: lastSeen,
      );
    });
  }
}
