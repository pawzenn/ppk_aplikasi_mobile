// lib/features/analysis/widgets/seven_days_section.dart
import 'package:flutter/material.dart';

import '../../../core/lahan/current_lahan.dart';
import '../../../core/rtdb/aggregates_streams.dart';
import '../../../shared/widgets/bar_chart_simple.dart';
import '../../../shared/widgets/section_header.dart';

class SevenDaysSection extends StatelessWidget {
  const SevenDaysSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: CurrentLahan.instance.lahanId,
      builder: (context, lahanId, _) {
        return StreamBuilder<List<DayDoc>>(
          stream: watchLast7Days(lahanId: lahanId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final items = snapshot.data ?? const <DayDoc>[];

            final labels = items
                .map(
                  (e) => e.dateKey.length >= 10
                      ? e.dateKey.substring(5) // "MM-dd"
                      : e.dateKey,
                )
                .toList();

            final values =
                items.map((e) => e.total.toDouble()).toList(growable: false);

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data untuk 7 hari terakhir',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(
                  title: 'Laporan 7 Hari Terakhir',
                  subtitle: 'Total hama per hari',
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 220,
                    child: BarChartSimple(
                      values: values,
                      bottomLabels: labels,
                      color: const Color(0xFF1E7A3F),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
