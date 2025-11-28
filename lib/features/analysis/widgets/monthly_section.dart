// lib/features/analysis/widgets/monthly_section.dart
import 'package:flutter/material.dart';

import '../../../core/lahan/current_lahan.dart';
import '../../../core/rtdb/aggregates_streams.dart';
import '../../../shared/widgets/bar_chart_simple.dart';

class MonthlySection extends StatelessWidget {
  final DateTime month;
  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthlySection({
    super.key,
    required this.month,
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: CurrentLahan.instance.lahanId,
      builder: (context, lahanId, _) {
        return StreamBuilder<MonthBuckets>(
          stream: watchMonth5Buckets(month, lahanId: lahanId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final buckets = snapshot.data ??
                MonthBuckets(
                  const [0, 0, 0, 0, 0],
                  const ['1–7', '8–14', '15–21', '22–28', '29–31'],
                );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onPrev,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    IconButton(
                      onPressed: onNext,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                for (var i = 0; i < buckets.totals.length; i++) ...[
                  Text(
                    'Minggu ${i + 1} (${buckets.labels[i]})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 160,
                        child: BarChartSimple(
                          values: [buckets.totals[i].toDouble()],
                          bottomLabels: [buckets.labels[i]],
                          color: const Color(0xFF1E7A3F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
