// lib/core/utils/date_time_utils.dart
import 'package:intl/intl.dart';

/// Menghasilkan key tanggal 'yyyy-MM-dd' berbasis tanggal lokal (tanpa jam)
String keyOfDate(DateTime d) {
  return DateFormat('yyyy-MM-dd').format(
    DateTime(d.year, d.month, d.day),
  );
}

/// Key untuk hari ini (lokal)
String todayKey() => keyOfDate(DateTime.now());

/// Key awal bulan 'yyyy-MM-01'
String monthStartKey(DateTime month) {
  return DateFormat('yyyy-MM-01').format(
    DateTime(month.year, month.month, 1),
  );
}

/// Key akhir bulan 'yyyy-MM-dd' (tanggal terakhir)
String monthEndKey(DateTime month) {
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateFormat('yyyy-MM-dd').format(
    DateTime(month.year, month.month, lastDay),
  );
}

/// Mengembalikan hanya bagian tanggal (year, month, day) dalam zona lokal
DateTime asLocalDate(DateTime d) => DateTime(d.year, d.month, d.day);

/// Konversi timestamp (detik atau milidetik) menjadi DateTime lokal
DateTime fromTimestamp(dynamic ts) {
  if (ts is int) {
    if (ts > 2000000000) {
      // milidetik
      return DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
    }
    // detik
    return DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal();
  }
  return DateTime.now();
}

/// Parse string waktu 'yyyy-MM-dd HH:mm:ss' sebagai UTC lalu diubah ke lokal.
/// Mengembalikan null jika format tidak valid.
DateTime? parseTimeLocal(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(s, true).toLocal();
    return dt;
  } catch (_) {
    return null;
  }
}
