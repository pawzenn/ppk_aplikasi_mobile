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

  static const _weekLabels = [
    '1–7',
    '8–14',
    '15–21',
    '22–28',
    '29–31',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: CurrentLahan.instance.lahanId,
      builder: (context, lahanId, _) {
        return StreamBuilder<List<List<DayDoc>>>(
          stream: watchMonthWeeks(month, lahanId: lahanId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final weeks = snapshot.data ?? List.generate(5, (_) => <DayDoc>[]);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header bulan + tombol prev/next
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onPrev,
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: const Color(0xFF1E7A3F),
                      ),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E7A3F),
                            ),
                      ),
                      IconButton(
                        onPressed: onNext,
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: const Color(0xFF1E7A3F),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Loop per minggu
                for (var i = 0; i < weeks.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E7A3F),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Minggu ${i + 1}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E7A3F),
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${_weekLabels[i]})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      child: _buildWeekChart(weeks[i]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeekChart(List<DayDoc> days) {
    if (days.isEmpty) {
      return BarChartSimple(
        values: const [0],
        bottomLabels: const ['-'],
        color: const Color(0xFF1E7A3F),
      );
    }

    final sorted = [...days]..sort((a, b) => a.dateKey.compareTo(b.dateKey));

    final labels = <String>[];
    final values = <double>[];

    for (final d in sorted) {
      try {
        final dt = DateTime.parse(d.dateKey);
        labels.add(dt.day.toString());
      } catch (_) {
        labels.add(d.dateKey);
      }
      values.add(d.total.toDouble());
    }

    return BarChartSimple(
      values: values,
      bottomLabels: labels,
      color: const Color(0xFF1E7A3F),
    );
  }
}
