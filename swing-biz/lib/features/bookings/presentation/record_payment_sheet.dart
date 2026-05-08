import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────

class _C {
  const _C({
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.bg,
    required this.divider,
  });
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color surface;
  final Color bg;
  final Color divider;

  factory _C.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _C(
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      accent: s.primary,
      onAccent: s.onPrimary,
      surface: s.surfaceContainerHighest,
      bg: s.surface,
      divider: s.outlineVariant,
    );
  }
}

late _C _c;

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Opens [RecordPaymentSheet] as a bottom sheet from any context.
Future<void> showRecordPaymentSheet(
  BuildContext context, {
  required ArenaReservation booking,
  String? defaultPayerName,
  VoidCallback? onRecorded,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RecordPaymentSheet(
      booking: booking,
      defaultPayerName: defaultPayerName,
      onRecorded: onRecorded,
    ),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({
    super.key,
    required this.booking,
    this.defaultPayerName,
    this.onRecorded,
  });

  final ArenaReservation booking;
  final String? defaultPayerName;
  final VoidCallback? onRecorded;

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _payerCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  String _mode = 'CASH';
  bool _loading = false;
  String? _selectedTeamId;

  static const _modes = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER'];

  bool get _isSplit =>
      widget.booking.isSplit && widget.booking.matchInfo != null;

  @override
  void initState() {
    super.initState();
    if (_isSplit) {
      final mi = widget.booking.matchInfo!;
      _selectedTeamId = mi.teamAId;
      _payerCtrl.text = widget.defaultPayerName ??
          mi.teamACaptain?.name?.trim() ??
          '';
      _amountCtrl.text = _formatPaise(_outstandingForTeam(mi.teamAId));
    } else {
      _payerCtrl.text =
          widget.defaultPayerName ?? widget.booking.displayName;
      final balance = widget.booking.balancePaise;
      if (balance > 0) _amountCtrl.text = _formatPaise(balance);
    }
  }

  int get _perTeamSharePaise =>
      (widget.booking.totalAmountPaise / 2).round();

  int _outstandingForTeam(String? teamId) {
    if (teamId == null) return widget.booking.balancePaise;
    final paidByTeam = widget.booking.bookingPayments
        .where((p) => p.payerTeamId == teamId)
        .fold<int>(0, (sum, p) => sum + p.amountPaise);
    final remaining = _perTeamSharePaise - paidByTeam;
    return remaining < 0 ? 0 : remaining;
  }

  String _formatPaise(int paise) => (paise / 100).toStringAsFixed(0);

  void _selectTeam(String? teamId) {
    final mi = widget.booking.matchInfo;
    if (mi == null) return;
    setState(() {
      _selectedTeamId = teamId;
      final captain = teamId == mi.teamAId
          ? mi.teamACaptain
          : (teamId == mi.teamBId ? mi.teamBCaptain : null);
      final captainName = captain?.name?.trim() ?? '';
      if (_payerCtrl.text.trim().isEmpty || _isCaptainName(_payerCtrl.text)) {
        _payerCtrl.text = captainName;
      }
      _amountCtrl.text = _formatPaise(_outstandingForTeam(teamId));
    });
  }

  bool _isCaptainName(String value) {
    final mi = widget.booking.matchInfo;
    if (mi == null) return false;
    final v = value.trim();
    return v == (mi.teamACaptain?.name?.trim() ?? '__none_a__') ||
        v == (mi.teamBCaptain?.name?.trim() ?? '__none_b__');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _payerCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: _c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _c.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Record Payment',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _c.text)),
              const SizedBox(height: 4),
              Text(
                'Total: ₹${(widget.booking.totalAmountPaise / 100).toStringAsFixed(0)} · Balance: ₹${(widget.booking.balancePaise / 100).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12, color: _c.muted),
              ),
              const SizedBox(height: 20),
              if (_isSplit) ...[
                _TeamPicker(
                  matchInfo: widget.booking.matchInfo!,
                  selectedTeamId: _selectedTeamId,
                  onSelect: _selectTeam,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _payerCtrl,
                style: TextStyle(color: _c.text),
                decoration: InputDecoration(
                  labelText: 'Payer Name',
                  labelStyle: TextStyle(color: _c.muted),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: _c.text),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  labelStyle: TextStyle(color: _c.muted),
                  prefixText: '₹ ',
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text('Payment Mode',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _c.muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _modes
                    .map((m) => ChoiceChip(
                          label: Text(m,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      _mode == m ? _c.onAccent : _c.text)),
                          selected: _mode == m,
                          selectedColor: _c.accent,
                          backgroundColor: _c.surface,
                          onSelected: (_) => setState(() => _mode = m),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _refCtrl,
                style: TextStyle(color: _c.text),
                decoration: InputDecoration(
                  labelText: 'Reference (optional)',
                  labelStyle: TextStyle(color: _c.muted),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _c.accent,
                    foregroundColor: _c.onAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Record Payment',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final amountPaise =
          (double.parse(_amountCtrl.text.trim()) * 100).round();
      await ref.read(hostArenaBookingRepositoryProvider).addBookingPayment(
            widget.booking.id,
            amountPaise: amountPaise,
            paymentMode: _mode,
            payerName: _payerCtrl.text.trim(),
            payerTeamId: _isSplit ? _selectedTeamId : null,
            reference: _refCtrl.text.trim().isEmpty
                ? null
                : _refCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
      widget.onRecorded?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Team picker ──────────────────────────────────────────────────────────────

class _TeamPicker extends StatelessWidget {
  const _TeamPicker({
    required this.matchInfo,
    required this.selectedTeamId,
    required this.onSelect,
  });
  final MatchupContext matchInfo;
  final String? selectedTeamId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final teamA = (
      id: matchInfo.teamAId,
      name: matchInfo.teamAName,
      captain: matchInfo.teamACaptain?.name,
    );
    final teamB = matchInfo.hasOpponent
        ? (
            id: matchInfo.teamBId,
            name: matchInfo.teamBName,
            captain: matchInfo.teamBCaptain?.name,
          )
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paying for',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _c.muted)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _TeamPickerOption(
              teamId: teamA.id,
              teamName: teamA.name,
              captainName: teamA.captain,
              selected: selectedTeamId == teamA.id,
              onTap: () => onSelect(teamA.id),
            ),
          ),
          if (teamB != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _TeamPickerOption(
                teamId: teamB.id,
                teamName: teamB.name,
                captainName: teamB.captain,
                selected: selectedTeamId == teamB.id,
                onTap: () => onSelect(teamB.id),
              ),
            ),
          ],
        ]),
      ],
    );
  }
}

class _TeamPickerOption extends StatelessWidget {
  const _TeamPickerOption({
    required this.teamId,
    required this.teamName,
    required this.captainName,
    required this.selected,
    required this.onTap,
  });
  final String? teamId;
  final String teamName;
  final String? captainName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return GestureDetector(
      onTap: teamId == null ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _c.accent : _c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? _c.accent : _c.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? _c.onAccent : _c.text)),
            if ((captainName ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Captain · ${captainName!.trim()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? _c.onAccent.withValues(alpha: 0.85)
                          : _c.muted)),
            ],
          ],
        ),
      ),
    );
  }
}
