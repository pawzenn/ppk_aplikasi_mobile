// lib/shared/widgets/tab_chip.dart
import 'package:flutter/material.dart';

class TabChip extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const TabChip({
    super.key,
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E7A3F) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF616161),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
