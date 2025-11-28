// lib/core/utils/mapping_utils.dart

/// Mapping ID lahan ke label yang lebih ramah pengguna.
/// Bisa kamu ubah sesuai kebutuhan (ambil dari RTDB juga boleh nanti).
String labelFromLahanId(String id) {
  const mapping = {
    'lahan1': 'Lahan 1',
    'lahan2': 'Lahan 2',
  };

  return mapping[id] ?? id;
}
