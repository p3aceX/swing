import 'package:flutter/material.dart';

class ScoringWagonWheel extends StatelessWidget {
  const ScoringWagonWheel({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class OverDotsRow extends StatelessWidget {
  const OverDotsRow({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class BatterRow extends StatelessWidget {
  const BatterRow({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class BowlerRow extends StatelessWidget {
  const BowlerRow({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class RunButton extends StatelessWidget {
  const RunButton({super.key, this.label = ''});
  final String label;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: () {},
        child: Text(label),
      );
}
