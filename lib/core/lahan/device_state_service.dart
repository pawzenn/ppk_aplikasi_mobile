// lib/core/lahan/device_state_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../utils/date_time_utils.dart';

/// Model sederhana untuk status perangkat di suatu lahan.
class DeviceState {
  final bool speakerConnected;
  final String appliedMode; // contoh: AUTO / MANUAL / -
  final int appliedVolume; // 0..100
  final DateTime? lastSeen; // waktu heartbeat terakhir

  DeviceState({
    required this.speakerConnected,
    required this.appliedMode,
    required this.appliedVolume,
    required this.lastSeen,
  });

  /// Heuristik sederhana: apakah alat dianggap ONLINE?
  bool get isOnline {
    if (lastSeen == null) return false;
    final diff = DateTime.now().difference(lastSeen!);
    return diff.inMinutes <= 2; // <= 2 menit masih dianggap online
  }

  /// Heuristik sederhana: apakah alat dianggap ON (aktif)?
  /// (Nanti bisa kamu refined lagi sesuai kebutuhan.)
  bool get isOn {
    if (!isOnline) return false;
    if (appliedMode.toUpperCase() == 'AUTO') return true;
    if (appliedMode.toUpperCase() == 'MANUAL' && appliedVolume > 0) {
      return true;
    }
    return false;
  }
}

/// Service untuk membaca node state/{lahan}
class DeviceStateService {
  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref();

  Stream<DeviceState> watchDeviceState(String lahanId) {
    final ref = _rootRef.child('state/$lahanId');

    return ref.onValue.map((e) {
      final m = (e.snapshot.value as Map?) ?? {};

      final speakerConnected = (m['speaker_connected'] ?? false) as bool;
      final appliedMode = (m['applied_mode'] ?? '-').toString();
      final appliedVolume = ((m['applied_volume'] ?? 0) as num).toInt();

      final ts = m['last_seen'];
      DateTime? lastSeen;
      if (ts != null) {
        lastSeen = fromTimestamp(ts);
      }

      return DeviceState(
        speakerConnected: speakerConnected,
        appliedMode: appliedMode,
        appliedVolume: appliedVolume,
        lastSeen: lastSeen,
      );
    });
  }
}
