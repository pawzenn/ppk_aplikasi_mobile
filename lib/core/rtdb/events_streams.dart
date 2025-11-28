// lib/core/rtdb/events_streams.dart
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

/// RTDB root ref
final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();

/// Model event deteksi hama
class EventItem {
  final String id;
  final String klas; // contoh: "tikus"
  final DateTime timeLocal; // waktu lokal
  final double conf; // confidence (0..1)

  EventItem({
    required this.id,
    required this.klas,
    required this.timeLocal,
    required this.conf,
  });
}

/// Ambil teks kelas dari beberapa kemungkinan field (class / label / bbox)
String _readClass(Map m) {
  final a = (m['class'] ?? m['label'] ?? '').toString();
  final b = (m['normalized_class'] ?? '').toString();
  final c = (m['bbox'] is Map)
      ? (((m['bbox'] as Map)['normalized_class'] ?? (m['bbox'] as Map)['class'])
              ?.toString() ??
          '')
      : '';
  final pick =
      [a, b, c].firstWhere((s) => s.trim().isNotEmpty, orElse: () => '');
  return pick.toLowerCase();
}

/// Stream total tikus "hari ini" dari /events/{lahan}
Stream<int> watchTodayTotalTikus({String lahanId = 'lahan1'}) {
  int startOfDayEpoch(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 1000;
  int endOfDayEpoch(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59).millisecondsSinceEpoch ~/
      1000;

  final now = DateTime.now();
  final start = startOfDayEpoch(now);
  final end = endOfDayEpoch(now);

  final q = _rtdb
      .child('events/$lahanId')
      .orderByChild('ts')
      .startAt(start)
      .endAt(end);

  return q.onValue.map((event) {
    final snap = event.snapshot.value;
    if (snap == null) return 0;

    final Map<dynamic, dynamic> map = snap is Map
        ? Map<dynamic, dynamic>.from(snap)
        : snap is List
            ? {for (var i = 0; i < snap.length; i++) '$i': snap[i]}
            : {};

    int count = 0;
    for (final raw in map.values) {
      if (raw == null) continue;
      final m = Map<dynamic, dynamic>.from(raw as Map);
      final cls = (m['class'] ?? m['label'] ?? '').toString().toLowerCase();
      if (!cls.contains('tikus')) continue;
      count++;
    }
    return count;
  });
}

/// Stream event 48 jam terakhir dari /events/{lahan}
Stream<List<EventItem>> watchRecentEvents({
  String lahanId = 'lahan1',
  Duration window = const Duration(hours: 48),
  int maxItems = 200,
  String onlyClass = 'tikus',
  double minConf = 0.0,
}) {
  final now = DateTime.now();
  final startTs = now.subtract(window).millisecondsSinceEpoch ~/ 1000;

  final q = _rtdb
      .child('events/$lahanId')
      .orderByChild('ts')
      .startAt(startTs.toDouble()); // RTDB sering butuh double utk orderByChild

  return q.onValue.map((snap) {
    final raw = snap.snapshot.value;
    if (raw == null) return <EventItem>[];

    final Map<dynamic, dynamic> map = raw is Map
        ? Map<dynamic, dynamic>.from(raw)
        : raw is List
            ? {for (var i = 0; i < raw.length; i++) '$i': raw[i]}
            : {};

    final items = <EventItem>[];

    map.forEach((key, val) {
      if (val == null) return;
      final m = Map<dynamic, dynamic>.from(val as Map);

      final ts = m['ts'];
      if (ts == null) return;
      final t = (ts is int)
          ? DateTime.fromMillisecondsSinceEpoch(
                  ts > 2000000000 ? ts : ts * 1000)
              .toLocal()
          : DateTime.now();

      final klas = _readClass(m);

      final conf =
          ((m['conf'] ?? (m['bbox']?['conf'] ?? 0.0)) as num).toDouble();
      if (onlyClass.isNotEmpty && !klas.contains(onlyClass.toLowerCase())) {
        return;
      }
      if (conf < minConf) return;

      items.add(
        EventItem(
          id: key.toString(),
          klas: klas,
          timeLocal: t,
          conf: conf,
        ),
      );
    });

    items.sort((a, b) => b.timeLocal.compareTo(a.timeLocal));
    return items.take(maxItems).toList();
  });
}
