import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'src/theme/host_colors.dart';

class SwingSectionLabel extends StatelessWidget {
  const SwingSectionLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class SwingTextField extends StatelessWidget {
  const SwingTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.validator,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class SwingSubmitButton extends StatelessWidget {
  const SwingSubmitButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final callback = onPressed ?? onTap;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : callback,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class SwingSegmentOption<T> {
  const SwingSegmentOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class SwingSegmentRow<T> extends StatelessWidget {
  const SwingSegmentRow({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<SwingSegmentOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = option.value == value;
        return ChoiceChip(
          label: Text(option.label),
          selected: selected,
          onSelected: (_) => onChanged(option.value),
        );
      }).toList(),
    );
  }
}

class SwingDateTimeButton extends StatelessWidget {
  const SwingDateTimeButton({
    super.key,
    required this.label,
    required this.value,
    this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text('$label: $value'),
    );
  }
}
