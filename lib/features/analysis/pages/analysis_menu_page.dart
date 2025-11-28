// lib/features/analysis/pages/analysis_menu_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/monthly_section.dart';
import '../widgets/seven_days_section.dart';
import '../../../shared/widgets/tab_chip.dart';

class AnalysisMenuPage extends StatefulWidget {
  const AnalysisMenuPage({super.key});

  @override
  State<AnalysisMenuPage> createState() => _AnalysisMenuPageState();
}

class _AnalysisMenuPageState extends State<AnalysisMenuPage> {
  int _tab = 0; // 0 = 7 hari, 1 = bulanan
  DateTime _month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleMonth = DateFormat('MMMM yyyy', 'id_ID').format(_month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        backgroundColor: const Color(0xFF1E7A3F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Tab 7 hari vs Bulanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TabChip(
                    active: _tab == 0,
                    label: '7 hari terakhir',
                    onTap: () => setState(() => _tab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TabChip(
                    active: _tab == 1,
                    label: 'Laporan Bulanan',
                    onTap: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Konten
          Expanded(
            child: _tab == 0
                ? const SevenDaysSection()
                : MonthlySection(
                    month: _month,
                    title: titleMonth,
                    onPrev: _prevMonth,
                    onNext: _nextMonth,
                  ),
          ),
        ],
      ),
    );
  }
}
