import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Progress bar (step 1 or 2 of onboarding) ─────────────────────────────────
class OnboardingProgressBar extends StatelessWidget {
  final int step; // 1 or 2
  const OnboardingProgressBar({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF071B3D) : const Color(0xFFE0DED6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class OnboardingSectionLabel extends StatelessWidget {
  final String label;
  final bool required;
  const OnboardingSectionLabel({super.key, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF071B3D)),
        ),
        if (required) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0057C8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Required',
              style: TextStyle(fontSize: 11, color: Color(0xFF0057C8), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Reusable form field ────────────────────────────────────────────────────────
class OnboardingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool uppercase;

  const OnboardingField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [
          ...?inputFormatters,
          if (uppercase) _UpperCaseFormatter(),
        ],
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF071B3D),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0DED6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0DED6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF071B3D), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) =>
      next.copyWith(text: next.text.toUpperCase());
}
