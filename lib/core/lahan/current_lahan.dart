// lib/core/lahan/current_lahan.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan dan mem-broadcast ID lahan yang sedang aktif.
/// - disimpan ke SharedPreferences (supaya persist)
/// - disesuaikan dengan ACL di RTDB: /acl/{uid}
class CurrentLahan {
  static const _prefKey = 'current_lahan_id';
  static final CurrentLahan instance = CurrentLahan._();
  CurrentLahan._();

  /// Default fallback (kalau user belum pernah pilih)
  /// Boleh kamu ubah, tapi saat init akan dioverride oleh ACL jika ada.
  final ValueNotifier<String> lahanId = ValueNotifier<String>('lahan1');

  /// Dipanggil dari main() sekali saat startup.
  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();

    // 1. Ambil dari SharedPreferences kalau sudah pernah disimpan
    final saved = sp.getString(_prefKey);
    if (saved != null && saved.isNotEmpty) {
      lahanId.value = saved;
    }

    // 2. Jika user sudah login & punya ACL, pilihkan lahan pertama yang ada di ACL
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final aclSnap = await FirebaseDatabase.instance.ref('acl/$uid').get();

      if (aclSnap.exists) {
        final m = (aclSnap.value as Map?) ?? {};
        if (m.isNotEmpty) {
          final firstKey = m.keys.first.toString();

          // Kalau lahan yang tersimpan tidak ada di ACL, pakai lahan pertama
          if (!m.containsKey(lahanId.value)) {
            lahanId.value = firstKey;
            await sp.setString(_prefKey, firstKey);
          }
        }
      }
    }
  }

  /// Ganti lahan aktif dan simpan ke SharedPreferences
  Future<void> setLahan(String id) async {
    lahanId.value = id;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_prefKey, id);
  }
}

/// Item lahan untuk ditampilkan di list picker
class LahanItem {
  final String id;
  final String label;
  final bool online;

  LahanItem({
    required this.id,
    required this.label,
    required this.online,
  });
}

/// Stream daftar lahan yang dimiliki user berdasarkan ACL: /acl/{uid}
/// Lalu join dengan /lahan_meta dan /state/{lahan}/last_seen (status online)
Stream<List<LahanItem>> watchUserLahan() async* {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    yield const <LahanItem>[];
    return;
  }

  final db = FirebaseDatabase.instance.ref();

  // Dengarkan ACL user
  await for (final aclEv in db.child('acl/$uid').onValue) {
    final aclMap = (aclEv.snapshot.value as Map?) ?? {};
    final ids = aclMap.keys.map((e) => e.toString()).toList()..sort();

    // Ambil lahan_meta (opsional)
    final metaSnap = await db.child('lahan_meta').get();
    final meta = (metaSnap.value as Map?) ?? {};

    // Cek online dari state/{lahan}/last_seen
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final items = <LahanItem>[];
    for (final id in ids) {
      final label = (meta[id]?['display_name'] ?? id).toString();

      final lsSnap = await db.child('state/$id/last_seen').get();
      final ls = (lsSnap.value as int?) ?? 0;
      final online = (nowSec - ls) <= 120; // online jika update <= 2 menit

      items.add(LahanItem(id: id, label: label, online: online));
    }

    yield items;
  }
}
