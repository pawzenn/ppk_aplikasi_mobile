// lib/features/dashboard/pages/home_view.dart
import 'package:flutter/material.dart';

import '../../../core/lahan/current_lahan.dart';
import '../../../core/rtdb/events_streams.dart';
import '../../../core/services/device_state_service.dart';
import '../../analysis/pages/analysis_menu_page.dart';
import '../widgets/sound_control_card.dart';
import '../widgets/today_summary_card.dart';
import '../widgets/device_status_chip.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== Header + status alat =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Beranda',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E7A3F),
                  ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: CurrentLahan.instance.lahanId,
              builder: (context, lahanId, _) {
                return StreamBuilder(
                  stream:
                      DeviceStateService.instance.watchDeviceStatus(lahanId),
                  builder: (context, snapshot) {
                    final status = snapshot.data;

                    if (status == null) {
                      return const DeviceStatusChip(
                        isOnline: false,
                        lastSeen: null,
                      );
                    }

                    return DeviceStatusChip(
                      isOnline: status.isOnline,
                      lastSeen: status.lastSeen,
                    );
                  },
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ===== Kartu Total Hama Hari Ini =====
        ValueListenableBuilder<String>(
          valueListenable: CurrentLahan.instance.lahanId,
          builder: (context, lahanId, _) {
            return StreamBuilder<int>(
              stream: watchTodayTotalTikus(lahanId: lahanId),
              builder: (context, snap) {
                final total = snap.data ?? 0;
                return TodaySummaryCard(total: total);
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // ===== Tombol Hasil Analisis =====
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalysisMenuPage(),
              ),
            );
          },
          icon: const Icon(Icons.analytics_rounded, size: 20),
          label: const Text(
            'Hasil Analisis',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E7A3F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ===== Kontrol Suara Burung =====
        ValueListenableBuilder<String>(
          valueListenable: CurrentLahan.instance.lahanId,
          builder: (context, lahanId, _) {
            return SoundControlCard(lahanId: lahanId);
          },
        ),
      ],
    );
  }
}
