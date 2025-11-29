// lib/features/dashboard/pages/notifications_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/rtdb/events_streams.dart';
import '../../../core/lahan/current_lahan.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final fmtDay = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final fmtTime = DateFormat('HH:mm', 'id_ID');

    return ValueListenableBuilder<String>(
      valueListenable: CurrentLahan.instance.lahanId,
      builder: (context, lahanId, _) {
        return StreamBuilder<List<EventItem>>(
          stream: watchRecentEvents(
            lahanId: lahanId,
            window: const Duration(hours: 48),
            onlyClass: 'tikus',
            minConf: 0.0,
            maxItems: 200,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final data = snap.data ?? const <EventItem>[];
            if (data.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada deteksi dalam 2 hari terakhir',
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

            String? lastDateKey;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = data[i];
                final dateKey = DateFormat('yyyy-MM-dd').format(e.timeLocal);

                final isNewGroup = dateKey != lastDateKey;
                if (isNewGroup) lastDateKey = dateKey;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNewGroup) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                        child: Text(
                          fmtDay.format(e.timeLocal),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8F5E9),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8F4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.pest_control_rounded,
                            color: Color(0xFF1E7A3F),
                            size: 24,
                          ),
                        ),
                        title: const Text(
                          'Hama terdeteksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Pukul ${fmtTime.format(e.timeLocal)}'
                            '${e.conf > 0 ? ' • ${(e.conf * 100).toStringAsFixed(0)}% akurat' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
