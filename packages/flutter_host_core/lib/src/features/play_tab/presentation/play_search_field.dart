import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';

/// Shared search field used across the Play tab's Matches/Teams/Tournaments
/// sub-tabs. Flat panel-style chip with an outer stroke; no inner focus
/// border. Optional trailing button (e.g. filter) renders as a matching
/// square next to the field.
class PlaySearchField extends StatelessWidget {
  const PlaySearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.trailing,
  });

  final TextEditingController controller;
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.stroke, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: context.fgSub, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: context.fgSub,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  if (value.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.close_rounded,
                            color: context.fgSub, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Square trailing action button styled to sit next to [PlaySearchField].
/// Used by the Matches tab's filter affordance.
class PlaySearchTrailingButton extends StatelessWidget {
  const PlaySearchTrailingButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: active ? context.accentBg : context.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? context.accent : context.stroke,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon,
                size: 20, color: active ? context.accent : context.fgSub),
            if (active)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
