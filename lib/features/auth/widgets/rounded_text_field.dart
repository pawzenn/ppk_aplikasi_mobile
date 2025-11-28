// lib/features/auth/widgets/rounded_text_field.dart
import 'package:flutter/material.dart';

/// TextField bulat ber-background hijau (versi utama)
class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData leading;
  final bool obscure;
  final Widget? trailing;
  final Color background;

  const RoundedTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.leading,
    required this.background,
    this.obscure = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(leading, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Versi lain RoundedField (kalau nanti kamu butuh lagi)
class RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData leading;
  final bool obscure;
  final Widget? trailing;

  const RoundedField({
    super.key,
    required this.controller,
    required this.hint,
    required this.leading,
    this.obscure = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E7A3F),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(leading, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
              ),
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
