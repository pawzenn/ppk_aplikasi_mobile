// lib/features/lahan/widgets/lahan_picker_bottom_sheet.dart
import 'package:flutter/material.dart';

import '../../../core/lahan/current_lahan.dart';
import '../../../core/utils/mapping_utils.dart';

/// Tampilkan bottom sheet untuk memilih lahan yang aktif.
/// Memakai data dari /acl/{uid}, /lahan_meta, dan state/{lahan}/last_seen.
Future<void> showLahanPicker(BuildContext context) async {
  final rootContext = context; // untuk SnackBar
  final current = CurrentLahan.instance.lahanId.value;

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      String tempSelected = current;

      return StreamBuilder<List<LahanItem>>(
        stream: watchUserLahan(),
        builder: (sheetContext, snapshot) {
          final items = snapshot.data ?? const <LahanItem>[];

          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Tidak ada lahan yang dapat diakses.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pastikan akun Anda sudah memiliki akses lahan di sistem.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return StatefulBuilder(
            builder: (sheetContext, setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pilih Lahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final it in items)
                      RadioListTile<String>(
                        value: it.id,
                        groupValue: tempSelected,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => tempSelected = v);
                        },
                        title: Text(it.label),
                        subtitle: Text(it.id),
                        secondary: Icon(
                          Icons.circle,
                          size: 12,
                          color: it.online ? Colors.green : Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: (tempSelected != current)
                                ? () async {
                                    await CurrentLahan.instance
                                        .setLahan(tempSelected);

                                    if (rootContext.mounted) {
                                      ScaffoldMessenger.of(rootContext)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Berpindah ke ${labelFromLahanId(tempSelected)}',
                                          ),
                                        ),
                                      );
                                    }

                                    Navigator.pop(sheetContext);
                                  }
                                : null,
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
