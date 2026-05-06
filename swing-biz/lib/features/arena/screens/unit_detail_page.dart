import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/image_compressor.dart';
import '../services/arena_profile_providers.dart';
import '../../bookings/presentation/bookings_page.dart';
import 'arena_profile_page.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _bg = Color(0xFFF3F4F6);
const _surface = Color(0xFFFFFFFF);
const _line = Color(0xFFE1E5EA);
const _text = Color(0xFF0D1117);
const _muted = Color(0xFF6E7685);
const _accent = Color(0xFF059669);
const _deep = Color(0xFF064E3B);
const _red = Color(0xFFDC2626);
const _redBg = Color(0xFFFEF2F2);
const _redBorder = Color(0xFFFCA5A5);

// ─── Page ─────────────────────────────────────────────────────────────────────

class UnitDetailPage extends ConsumerStatefulWidget {
  const UnitDetailPage({
    super.key,
    required this.arenaId,
    required this.unitId,
  });

  final String arenaId;
  final String unitId;

  @override
  ConsumerState<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends ConsumerState<UnitDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  List<ArenaTimeBlock>? _blocks;
  bool _loadingBlocks = false;

  List<ArenaReservation>? _bookings;
  bool _loadingBookings = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _fetchBlocks();
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _fetchBlocks() async {
    setState(() => _loadingBlocks = true);
    try {
      final blocks = await ref
          .read(hostArenaBookingRepositoryProvider)
          .listUnitTimeBlocks(widget.arenaId, unitId: widget.unitId);
      if (mounted) setState(() => _blocks = blocks);
    } catch (e) {
      debugPrint('[unit detail] failed to load blocks: $e');
      if (mounted) {
        setState(() => _blocks = const []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load blocks: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingBlocks = false);
    }
  }

  Future<void> _fetchBookings() async {
    setState(() => _loadingBookings = true);
    try {
      final bookings = await ref
          .read(hostArenaBookingRepositoryProvider)
          .listArenaBookings(widget.arenaId, unitId: widget.unitId);
      if (mounted) setState(() => _bookings = bookings);
    } catch (_) {
      if (mounted) setState(() => _bookings = const []);
    } finally {
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  void _openEditor(ArenaListing arena, ArenaUnitOption unit) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _bg,
      builder: (ctx) => UnitEditorSheet(
        arenaId: arena.id,
        unit: unit,
      ),
    );
    if (changed == true && mounted) {
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider);
      ref.invalidate(ownedArenasProvider);
    }
  }

  Future<void> _deleteBlock(String blockId) async {
    try {
      await ref
          .read(hostArenaBookingRepositoryProvider)
          .deleteTimeBlock(blockId);
      await _fetchBlocks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _openAddBlockSheet(
      String arenaId, String openTime, String closeTime) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _bg,
      builder: (_) => _AddBlockSheet(
        arenaId: arenaId,
        unitId: widget.unitId,
        openTime: openTime,
        closeTime: closeTime,
      ),
    );
    if (!mounted) return;
    await _fetchBlocks();
    if (!mounted) return;
    if (result == 'conflict') {
      _tabs.animateTo(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('That time is already blocked. Showing existing blocks.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final arenaAsync = ref.watch(arenaDetailByIdProvider(widget.arenaId));
    return arenaAsync.when(
      loading: () => const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _bg),
        body: Center(
            child: Text(e.toString(), style: const TextStyle(color: _muted))),
      ),
      data: (arena) {
        final unit =
            arena.units.where((u) => u.id == widget.unitId).firstOrNull;
        if (unit == null) {
          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(backgroundColor: _bg),
            body: const Center(
                child: Text('Unit not found', style: TextStyle(color: _muted))),
          );
        }
        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _deep,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  unit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  _unitSubtitle(unit),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _openEditor(arena, unit),
                icon: const Icon(Icons.edit_rounded, size: 20),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: _surface,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: _UnitTabBar(controller: _tabs),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _ScheduleTab(
                      arena: arena,
                      unit: unit,
                      blocks: _blocks,
                      loadingBlocks: _loadingBlocks,
                      onDeleteBlock: _deleteBlock,
                    ),
                    _BookingsTab(
                      bookings: _bookings,
                      loading: _loadingBookings,
                      arena: arena,
                      unit: unit,
                      onRefresh: _fetchBookings,
                    ),
                    _BlocksTab(
                      unit: unit,
                      blocks: _blocks,
                      loading: _loadingBlocks,
                      onDelete: _deleteBlock,
                      onAdd: () => _openAddBlockSheet(
                        arena.id,
                        unit.openTime ?? arena.openTime,
                        unit.closeTime ?? arena.closeTime,
                      ),
                    ),
                    _InfoTab(
                      arena: arena,
                      unit: unit,
                      blocks: _blocks,
                      bookings: _bookings,
                      loadingBlocks: _loadingBlocks,
                      loadingBookings: _loadingBookings,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnitTabBar extends StatelessWidget {
  const _UnitTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: _deep,
          borderRadius: BorderRadius.circular(9),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: _muted,
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        tabs: const [
          Tab(text: 'Schedule'),
          Tab(text: 'Bookings'),
          Tab(text: 'Blocks'),
          Tab(text: 'Info'),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    this.highlight = false,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning
        ? _red
        : highlight
            ? _accent
            : _muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: warning
            ? _redBg
            : highlight
                ? _accent.withValues(alpha: 0.08)
                : _bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: warning
              ? _redBorder
              : highlight
                  ? _accent.withValues(alpha: 0.25)
                  : _line,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Schedule tab — calendar day view ────────────────────────────────────────

class _ScheduleTab extends StatefulWidget {
  const _ScheduleTab({
    required this.arena,
    required this.unit,
    required this.blocks,
    required this.loadingBlocks,
    required this.onDeleteBlock,
  });

  final ArenaListing arena;
  final ArenaUnitOption unit;
  final List<ArenaTimeBlock>? blocks;
  final bool loadingBlocks;
  final ValueChanged<String> onDeleteBlock;

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  late DateTime _selectedDate;
  late final ScrollController _dayScrollCtrl;

  static const _kDayCount = 14;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dayScrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _dayScrollCtrl.dispose();
    super.dispose();
  }

  // ISO weekday 1=Mon … 7=Sun, same as DateTime.weekday.
  bool _blockApplies(ArenaTimeBlock block, DateTime date) {
    if (block.isRecurring) return block.weekdays.contains(date.weekday);
    if (block.date == null) return false;
    // Backend returns @db.Date as ISO string e.g. "2025-04-26T00:00:00.000Z"
    // or just "2025-04-26" — compare by prefix.
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return block.date!.startsWith(dateStr);
  }

  ArenaTimeBlock? _blockForSlot(
    String slotStart,
    String slotEnd,
    List<ArenaTimeBlock> blocks, {
    DateTime? date,
  }) {
    final s = _timeToMins(slotStart);
    final e = _timeToMins(slotEnd);
    final targetDate = date ?? _selectedDate;
    for (final b in blocks) {
      if (!_blockApplies(b, targetDate)) continue;
      final bs = _timeToMins(b.startTime);
      final be = _timeToMins(b.endTime);
      if (bs < e && be > s) return b;
    }
    return null;
  }

  ArenaTimeBlock? _holidayForDate(
    DateTime date,
    List<ArenaTimeBlock> blocks,
  ) {
    for (final block in blocks) {
      if (block.isHoliday && _blockApplies(block, date)) return block;
    }
    return null;
  }

  int _blockedSlotCountForDate(
    DateTime date,
    List<(String, String)> slots,
    List<ArenaTimeBlock> blocks,
  ) {
    if (_holidayForDate(date, blocks) != null) return slots.length;
    return slots.where((slot) {
      final (start, end) = slot;
      return _blockForSlot(start, end, blocks, date: date) != null;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final openTime = widget.unit.openTime ?? widget.arena.openTime;
    final closeTime = widget.unit.closeTime ?? widget.arena.closeTime;
    final opDays = widget.unit.operatingDays.isNotEmpty
        ? widget.unit.operatingDays
        : widget.arena.operatingDays;
    // Grounds are single-capacity: step by maxSlotMins so slots are non-overlapping
    final slotStep = widget.unit.isGround
        ? widget.unit.maxSlotMins
        : widget.unit.minSlotMins;
    debugPrint('🔵 [slots] unitType=${widget.unit.unitType} isGround=${widget.unit.isGround} minSlotMins=${widget.unit.minSlotMins} maxSlotMins=${widget.unit.maxSlotMins} slotStep=$slotStep openTime=$openTime closeTime=$closeTime');
    final slots = _computeSlots(openTime, closeTime, slotStep);
    debugPrint('🔵 [slots] generated ${slots.length} slots: ${slots.map((s) => '${s.$1}-${s.$2}').join(', ')}');
    final blocks = widget.blocks ?? const [];
    final isOperatingDay =
        opDays.isEmpty || opDays.contains(_selectedDate.weekday);
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(_selectedDate, now);
    final nowMins = now.hour * 60 + now.minute;
    final selectedHoliday = _holidayForDate(_selectedDate, blocks);
    final blockedSlots = _blockedSlotCountForDate(_selectedDate, slots, blocks);
    final openSlots = isOperatingDay ? (slots.length - blockedSlots) : 0;
    final isHoliday = selectedHoliday != null;

    return Column(
      children: [
        Container(
          color: _surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: _text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isToday
                              ? 'Today · ${DateFormat('EEE, d MMM').format(_selectedDate)}'
                              : isHoliday
                                  ? 'Holiday · ${DateFormat('EEE, d MMM').format(_selectedDate)}'
                                  : DateFormat('EEEE, d MMM')
                                      .format(_selectedDate),
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CalendarCount(label: 'Open', value: '$openSlots'),
                  const SizedBox(width: 8),
                  _CalendarCount(
                    label: 'Blocked',
                    value: '$blockedSlots',
                    warning: blockedSlots > 0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 74,
                child: ListView.builder(
                  controller: _dayScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  itemCount: _kDayCount,
                  itemBuilder: (context, i) {
                    final day = DateTime.now().add(Duration(days: i));
                    final selected = DateUtils.isSameDay(day, _selectedDate);
                    final isOp = opDays.isEmpty || opDays.contains(day.weekday);
                    final dayIsToday = DateUtils.isSameDay(day, DateTime.now());
                    final dayBlockedSlots =
                        _blockedSlotCountForDate(day, slots, blocks);
                    return _CalendarDayTile(
                      day: day,
                      selected: selected,
                      isOperating: isOp,
                      isToday: dayIsToday,
                      hasBlock: dayBlockedSlots > 0,
                      onTap: () => setState(() => _selectedDate = day),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    icon: Icons.access_time_rounded,
                    label: '$openTime - $closeTime',
                  ),
                  _SummaryChip(
                    icon: Icons.grid_view_rounded,
                    label: '${slots.length} slots',
                  ),
                  if (!isOperatingDay)
                    const _SummaryChip(
                      icon: Icons.event_busy_rounded,
                      label: 'Closed',
                      warning: true,
                    ),
                  if (isHoliday)
                    _SummaryChip(
                      icon: Icons.wb_sunny_rounded,
                      label: selectedHoliday.reason ?? 'Holiday',
                      warning: true,
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _line),
        Expanded(
          child: !isOperatingDay || isHoliday
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHoliday
                            ? Icons.wb_sunny_rounded
                            : Icons.event_busy_rounded,
                        color: isHoliday ? const Color(0xFFF97316) : _muted,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHoliday
                            ? (selectedHoliday.reason ?? 'Holiday')
                            : 'Closed on ${DateFormat('EEEE').format(_selectedDate)}',
                        style: TextStyle(
                          color: isHoliday ? const Color(0xFFC2410C) : _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (isHoliday) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Holiday overrides all time blocks for this day',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                const Color(0xFFF97316).withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : widget.loadingBlocks
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : slots.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded,
                                  color: _muted, size: 36),
                              SizedBox(height: 10),
                              Text(
                                'No slots — set open/close time\nin unit settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: _muted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final (start, end) = slots[index];
                            final block = _blockForSlot(start, end, blocks);
                            final slotEndMins = _timeToMins(end);
                            final isPast = isToday && slotEndMins <= nowMins;
                            final isCurrent = isToday &&
                                _timeToMins(start) <= nowMins &&
                                nowMins < slotEndMins;
                            return _SlotRow(
                              start: start,
                              end: end,
                              block: block,
                              isPast: isPast,
                              isCurrent: isCurrent,
                              onDeleteBlock: block != null
                                  ? () => widget.onDeleteBlock(block.id)
                                  : null,
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({
    required this.day,
    required this.selected,
    required this.isOperating,
    required this.isToday,
    required this.hasBlock,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isOperating;
  final bool isToday;
  final bool hasBlock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? _deep
        : hasBlock
            ? _redBorder
            : isToday
                ? _accent.withValues(alpha: 0.35)
                : _line;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 58,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? _deep
              : hasBlock
                  ? _redBg
                  : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _deep.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(day).substring(0, 3).toUpperCase(),
              style: TextStyle(
                color: selected
                    ? Colors.white70
                    : isOperating
                        ? _muted
                        : _line,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${day.day}',
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : isOperating
                        ? _text
                        : _muted,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (!isOperating) ...[
              const SizedBox(height: 3),
              Text(
                'Closed',
                style: TextStyle(
                  color: selected ? Colors.white54 : _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalendarCount extends StatelessWidget {
  const _CalendarCount({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? _red : _accent;
    return Container(
      width: 66,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot row ─────────────────────────────────────────────────────────────────

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.start,
    required this.end,
    required this.block,
    required this.isPast,
    required this.isCurrent,
    required this.onDeleteBlock,
  });

  final String start;
  final String end;
  final ArenaTimeBlock? block;
  final bool isPast;
  final bool isCurrent;
  final VoidCallback? onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    final isBlocked = block != null;

    Color bgColor;
    Color borderColor;
    Color timeColor;

    if (isBlocked) {
      bgColor = _redBg;
      borderColor = _redBorder;
      timeColor = _red;
    } else if (isCurrent) {
      bgColor = _accent.withValues(alpha: 0.06);
      borderColor = _accent.withValues(alpha: 0.4);
      timeColor = _accent;
    } else if (isPast) {
      bgColor = _bg;
      borderColor = _line;
      timeColor = _muted;
    } else {
      bgColor = _surface;
      borderColor = _line;
      timeColor = _text;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isBlocked && onDeleteBlock != null
              ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Remove block?'),
                      content: Text(
                        'Unblock $start – $end'
                        '${block!.reason != null ? ' (${block!.reason})' : ''}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) onDeleteBlock!();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isBlocked
                        ? _red
                        : isCurrent
                            ? _accent
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),

                // Time
                SizedBox(
                  width: 90,
                  child: Text(
                    '$start – $end',
                    style: TextStyle(
                      color: timeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),

                // Badge / reason
                Expanded(
                  child: isBlocked
                      ? Text(
                          block!.reason ?? 'Blocked',
                          style: const TextStyle(
                            color: _red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : isCurrent
                          ? const Text(
                              'Now',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),

                // Status pill
                _StatusPill(
                  isBlocked: isBlocked,
                  isPast: isPast,
                  isCurrent: isCurrent,
                ),

                if (isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(Icons.close_rounded,
                        color: _red.withValues(alpha: 0.6), size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.isBlocked,
    required this.isPast,
    required this.isCurrent,
  });

  final bool isBlocked;
  final bool isPast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    final Color bg;

    if (isBlocked) {
      label = 'Blocked';
      color = _red;
      bg = _redBorder.withValues(alpha: 0.25);
    } else if (isCurrent) {
      label = 'Live';
      color = _accent;
      bg = _accent.withValues(alpha: 0.1);
    } else if (isPast) {
      label = 'Past';
      color = _muted;
      bg = _line;
    } else {
      label = 'Open';
      color = _accent;
      bg = _accent.withValues(alpha: 0.08);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Bookings tab ─────────────────────────────────────────────────────────────

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({
    required this.bookings,
    required this.loading,
    required this.arena,
    required this.unit,
    required this.onRefresh,
  });

  final List<ArenaReservation>? bookings;
  final bool loading;
  final ArenaListing arena;
  final ArenaUnitOption unit;
  final VoidCallback onRefresh;

  void _openDetail(BuildContext context, ArenaReservation booking) {
    context
        .push(AppRoutes.bookingDetailPath(booking.id))
        .then((_) => onRefresh());
  }

  void _openAddBooking(BuildContext context) {
    final today = DateTime.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddBookingSheet(
        arena: arena,
        date: today,
        lockedUnitId: unit.id,
      ),
    ).then((_) => onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (bookings == null || bookings!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, color: _muted, size: 40),
            const SizedBox(height: 12),
            const Text('No bookings yet',
                style: TextStyle(
                    color: _muted, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Player and walk-in bookings appear here',
                style: TextStyle(color: _muted, fontSize: 13)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _openAddBooking(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _deep,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Add walk-in booking',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<ArenaReservation>>{};
    for (final b in bookings!) {
      final key = b.bookingDate != null
          ? DateFormat('yyyy-MM-dd').format(b.bookingDate!)
          : 'Unknown';
      grouped.putIfAbsent(key, () => []).add(b);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: sortedKeys.length,
            itemBuilder: (context, i) {
              final dateKey = sortedKeys[i];
              final dayBookings = grouped[dateKey]!;
              DateTime? dt;
              try {
                dt = DateTime.parse(dateKey);
              } catch (_) {}
              final dayLabel = dt != null
                  ? (DateUtils.isSameDay(dt, DateTime.now())
                      ? 'Today · ${DateFormat('d MMM').format(dt)}'
                      : DateFormat('EEE, d MMM yyyy').format(dt))
                  : dateKey;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i > 0) const SizedBox(height: 16),
                  _SectionLabel(dayLabel),
                  const SizedBox(height: 6),
                  ...dayBookings.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BookingCard(
                          booking: b,
                          arenas: const [],
                          onTap: () => _openDetail(context, b),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
        // Add booking FAB
        Positioned(
          bottom: 20,
          right: 16,
          child: GestureDetector(
            onTap: () => _openAddBooking(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _deep,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Add booking',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Blocks tab ───────────────────────────────────────────────────────────────

class _BlocksTab extends StatelessWidget {
  const _BlocksTab({
    required this.unit,
    required this.blocks,
    required this.loading,
    required this.onDelete,
    required this.onAdd,
  });

  final ArenaUnitOption unit;
  final List<ArenaTimeBlock>? blocks;
  final bool loading;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;

  static const _dayNames = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  String _weekdayLabels(List<int> days) =>
      days.map((d) => _dayNames[d]).join(', ');

  @override
  Widget build(BuildContext context) {
    final recurring = blocks?.where((b) => b.isRecurring).toList() ?? [];
    final oneOff = blocks?.where((b) => !b.isRecurring).toList() ?? [];
    final holidayDates = oneOff
        .where((b) => b.isHoliday && b.date != null)
        .map((b) => b.date!.substring(0, 10))
        .toSet();
    final oneOffHolidays = oneOff.where((b) => b.isHoliday).toList();
    final oneOffBlocks = oneOff.where((b) => !b.isHoliday).toList();

    return Column(
      children: [
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : blocks == null || blocks!.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.block_rounded, color: _muted, size: 40),
                          SizedBox(height: 12),
                          Text('No blocks yet',
                              style: TextStyle(
                                  color: _muted,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text(
                              'Block time slots or add holidays\nfor this unit',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _muted, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      children: [
                        if (recurring.isNotEmpty) ...[
                          const _SectionLabel('RECURRING'),
                          ...recurring.map((b) => _BlockRow(
                                block: b,
                                subtitle: _weekdayLabels(b.weekdays),
                                onDelete: onDelete,
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (oneOffHolidays.isNotEmpty) ...[
                          const _SectionLabel('HOLIDAYS'),
                          ...oneOffHolidays.map((b) {
                            String sub = b.date ?? '';
                            try {
                              if (sub.isNotEmpty) {
                                sub = DateFormat('EEE, d MMM yyyy')
                                    .format(DateTime.parse(sub));
                              }
                            } catch (_) {}
                            return _BlockRow(
                              block: b,
                              subtitle: sub,
                              onDelete: onDelete,
                            );
                          }),
                        ],
                        if (oneOffBlocks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const _SectionLabel('TIME BLOCKS'),
                          ...oneOffBlocks.map((b) {
                            String sub = b.date ?? '';
                            try {
                              if (sub.isNotEmpty) {
                                sub = DateFormat('EEE, d MMM yyyy')
                                    .format(DateTime.parse(sub));
                              }
                            } catch (_) {}
                            final coveredByHoliday = b.date != null &&
                                holidayDates.contains(b.date!.substring(0, 10));
                            return _BlockRow(
                              block: b,
                              subtitle: sub,
                              onDelete: onDelete,
                              overridden: coveredByHoliday,
                            );
                          }),
                        ],
                      ],
                    ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(top: BorderSide(color: _line)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add block / holiday'),
              style: FilledButton.styleFrom(
                backgroundColor: _deep,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.block,
    required this.subtitle,
    required this.onDelete,
    this.overridden = false,
  });

  final ArenaTimeBlock block;
  final String subtitle;
  final ValueChanged<String> onDelete;
  final bool overridden;

  @override
  Widget build(BuildContext context) {
    final isHoliday = block.isHoliday;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: overridden
            ? _bg
            : isHoliday
                ? const Color(0xFFFFF7ED)
                : _redBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overridden
              ? _line
              : isHoliday
                  ? const Color(0xFFFED7AA)
                  : _redBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isHoliday
                ? const Color(0xFFF97316).withValues(alpha: 0.12)
                : overridden
                    ? _line.withValues(alpha: 0.55)
                    : _red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isHoliday ? Icons.wb_sunny_rounded : Icons.block_rounded,
            size: 20,
            color: isHoliday
                ? const Color(0xFFF97316)
                : overridden
                    ? _muted
                    : _red,
          ),
        ),
        title: Text(
          isHoliday
              ? (block.reason ?? 'Holiday')
              : '${block.startTime} – ${block.endTime}',
          style: TextStyle(
            color: isHoliday
                ? const Color(0xFFC2410C)
                : overridden
                    ? _muted
                    : _red,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          isHoliday
              ? subtitle
              : '${subtitle.isEmpty ? '' : '$subtitle · '}${overridden ? 'Overridden by holiday' : block.reason ?? 'Blocked'}',
          style: TextStyle(
            color: isHoliday
                ? const Color(0xFFF97316)
                : overridden
                    ? _muted
                    : _red.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          color: _muted,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(isHoliday ? 'Remove holiday?' : 'Remove block?'),
                content: Text(isHoliday
                    ? 'Remove "${block.reason ?? 'Holiday'}"?'
                    : 'Unblock ${block.startTime} – ${block.endTime}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(backgroundColor: _red),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
            if (confirmed == true) onDelete(block.id);
          },
        ),
      ),
    );
  }
}

// ─── Info tab ─────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.arena,
    required this.unit,
    required this.blocks,
    required this.bookings,
    required this.loadingBlocks,
    required this.loadingBookings,
  });

  final ArenaListing arena;
  final ArenaUnitOption unit;
  final List<ArenaTimeBlock>? blocks;
  final List<ArenaReservation>? bookings;
  final bool loadingBlocks;
  final bool loadingBookings;

  @override
  Widget build(BuildContext context) {
    final hours =
        '${unit.openTime ?? arena.openTime} – ${unit.closeTime ?? arena.closeTime}';
    final operatingDays = unit.operatingDays.isNotEmpty
        ? unit.operatingDays
        : arena.operatingDays;
    final activeDays =
        operatingDays.isEmpty ? 'All week' : _weekdayLabels(operatingDays);

    final isGround = unit.unitType == 'FULL_GROUND' || unit.unitType == 'HALF_GROUND';
    final priceChipLabel = isGround
        ? (unit.price4HrPaise != null ? '${_money(unit.price4HrPaise!)}/4hr' : '${_money(unit.pricePerHourPaise * 4)}/4hr')
        : '${_money(unit.pricePerHourPaise)}/hr';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        const _SectionLabel('SUMMARY'),
        _InfoPanel(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  icon: Icons.currency_rupee_rounded,
                  label: priceChipLabel,
                  highlight: true,
                ),
                _SummaryChip(icon: Icons.access_time_rounded, label: hours),
                _SummaryChip(
                  icon: Icons.calendar_today_rounded,
                  label: activeDays,
                ),
                _SummaryChip(
                  icon: Icons.book_online_rounded,
                  label: loadingBookings
                      ? 'Bookings ...'
                      : '${bookings?.length ?? 0} bookings',
                ),
                _SummaryChip(
                  icon: Icons.block_rounded,
                  label: loadingBlocks
                      ? 'Blocks ...'
                      : '${blocks?.length ?? 0} blocks',
                  warning: blocks?.isNotEmpty ?? false,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Details
        const _SectionLabel('UNIT DETAILS'),
        _InfoPanel(children: [
          _InfoRow('Type', _labelForType(unit.unitType)),
          if (unit.netType != null && unit.netType!.isNotEmpty)
            _InfoRow('Surface', unit.netType!),
          _InfoRow('Hours', hours),
          _InfoRow('Operating days', activeDays),
          _InfoRow('Min slot', _formatDuration(unit.minSlotMins)),
          _InfoRow('Floodlights', unit.hasFloodlights ? 'Yes' : 'No'),
        ]),
        // Pricing
        const SizedBox(height: 20),
        const _SectionLabel('BASE RATES'),
        _InfoPanel(children: [
          if (!isGround)
            _InfoRow('Per hour', _money(unit.pricePerHourPaise)),
          if (unit.price4HrPaise != null)
            _InfoRow('4 hr block', _money(unit.price4HrPaise!))
          else if (isGround)
            _InfoRow('4 hr block', _money(unit.pricePerHourPaise * 4)),
          if (unit.price8HrPaise != null)
            _InfoRow('8 hr block', _money(unit.price8HrPaise!)),
          if (unit.priceFullDayPaise != null)
            _InfoRow('Full day', _money(unit.priceFullDayPaise!)),
        ]),
        if (unit.weekendMultiplier != 1) ...[
          const SizedBox(height: 20),
          const _SectionLabel('WEEKEND PRICING'),
          _InfoPanel(children: [
            _InfoRow('Multiplier', '${unit.weekendMultiplier}×'),
            if (!isGround)
              _InfoRow(
                  'Weekend /hr',
                  _money(
                      (unit.pricePerHourPaise * unit.weekendMultiplier).round())),
            if (unit.price4HrPaise != null)
              _InfoRow(
                  'Weekend 4 hr',
                  _money(
                      (unit.price4HrPaise! * unit.weekendMultiplier).round())),
          ]),
        ],
        // Add-ons
        if (unit.addons.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionLabel('ADD-ONS'),
          _InfoPanel(
            children: unit.addons
                .map((a) => _InfoRow(a.name, _money(a.pricePaise)))
                .toList(),
          ),
        ],
        // Photos
        if (unit.photoUrls.length > 1) ...[
          const SizedBox(height: 20),
          const _SectionLabel('PHOTOS'),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: unit.photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  unit.photoUrls[index],
                  width: 140,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 140,
                    height: 100,
                    color: _line,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Add block sheet ──────────────────────────────────────────────────────────

class _AddBlockSheet extends ConsumerStatefulWidget {
  const _AddBlockSheet({
    required this.arenaId,
    required this.unitId,
    required this.openTime,
    required this.closeTime,
  });

  final String arenaId;
  final String unitId;
  final String openTime;
  final String closeTime;

  @override
  ConsumerState<_AddBlockSheet> createState() => _AddBlockSheetState();
}

class _AddBlockSheetState extends ConsumerState<_AddBlockSheet> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  final _reasonCtrl = TextEditingController();

  // When: one-off vs recurring
  bool _isRecurring = false;
  DateTime? _selectedDate;
  List<int> _weekdays = const [];

  // Scope: full-day (holiday) vs partial time block
  bool _isHoliday = false;

  bool _saving = false;

  static const _days = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(text: widget.openTime);
    _endCtrl = TextEditingController(text: widget.closeTime);
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    debugPrint(
        '🔵 [Save] start — isHoliday=$_isHoliday isRecurring=$_isRecurring');
    debugPrint('🔵 [Save] start=${_startCtrl.text} end=${_endCtrl.text}');
    debugPrint('🔵 [Save] weekdays=$_weekdays date=$_selectedDate');

    if (!_isHoliday &&
        (_startCtrl.text.trim().isEmpty || _endCtrl.text.trim().isEmpty)) {
      debugPrint('🔴 [Save] BLOCKED: empty time fields');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select start and end time')));
      return;
    }
    if (_isRecurring && _weekdays.isEmpty) {
      debugPrint('🔴 [Save] BLOCKED: no weekdays selected');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one day')));
      return;
    }
    if (!_isRecurring && _selectedDate == null) {
      debugPrint('🔴 [Save] BLOCKED: no date selected');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick a date first')));
      return;
    }

    setState(() => _saving = true);
    try {
      final reasonText = _reasonCtrl.text.trim();
      final input = <String, dynamic>{
        'unitId': widget.unitId,
        'startTime': _isHoliday ? '00:00' : _startCtrl.text.trim(),
        'endTime': _isHoliday ? '23:59' : _endCtrl.text.trim(),
        'isHoliday': _isHoliday,
        if (_isRecurring)
          'weekdays': _weekdays
        else
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        if (reasonText.isNotEmpty)
          'reason': reasonText
        else if (_isHoliday)
          'reason': 'Holiday',
      };
      debugPrint('🔵 [Save] POSTing to /arenas/${widget.arenaId}/blocks');
      debugPrint('🔵 [Save] payload=$input');
      final block = await ref
          .read(hostArenaBookingRepositoryProvider)
          .createTimeBlock(widget.arenaId, input);
      debugPrint('✅ [Save] success id=${block.id}');
      if (!mounted) return;
      Navigator.pop(context, 'saved');
    } catch (e) {
      String serverMsg;
      if (e is DioException) {
        debugPrint('🔴 [Save] DioException status=${e.response?.statusCode}');
        debugPrint('🔴 [Save] response body=${e.response?.data}');
        final error = (e.response?.data as Map?)?['error'] as Map?;
        final code = error?['code']?.toString();
        serverMsg = error?['message']?.toString() ?? e.message ?? '$e';
        if (e.response?.statusCode == 409 && code == 'BLOCK_CONFLICT') {
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context, 'conflict');
          });
          return;
        }
      } else {
        debugPrint('🔴 [Save] non-Dio error: $e');
        serverMsg = '$e';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(serverMsg), duration: const Duration(seconds: 8)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, controller) => Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isHoliday ? 'Add Holiday' : 'Block Time',
                      style: const TextStyle(
                          color: _text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _line),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  // ── WHEN: one-off vs recurring ───────────────────────
                  const _SectionLabel('WHEN'),
                  Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _line),
                    ),
                    child: Row(
                      children: [
                        _BlockTypeTab(
                          label: 'One-off',
                          icon: Icons.calendar_today_rounded,
                          selected: !_isRecurring,
                          onTap: () => setState(() => _isRecurring = false),
                        ),
                        _BlockTypeTab(
                          label: 'Recurring',
                          icon: Icons.repeat_rounded,
                          selected: _isRecurring,
                          onTap: () => setState(() => _isRecurring = true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isRecurring)
                    _DatePickerButton(
                      date: _selectedDate,
                      onTap: _pickDate,
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _days.map((d) {
                        final sel = _weekdays.contains(d.$1);
                        return FilterChip(
                          selected: sel,
                          onSelected: (_) {
                            setState(() {
                              if (sel) {
                                _weekdays =
                                    _weekdays.where((x) => x != d.$1).toList();
                              } else {
                                _weekdays = [..._weekdays, d.$1]..sort();
                              }
                            });
                          },
                          label: Text(d.$2),
                          backgroundColor: _surface,
                          selectedColor: _deep,
                          checkmarkColor: _accent,
                          labelStyle: TextStyle(
                            color: sel ? Colors.white : _text,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(color: sel ? _deep : _line),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  // ── SCOPE: full-day toggle ───────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isHoliday ? const Color(0xFFFFF7ED) : _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _isHoliday ? const Color(0xFFFED7AA) : _line),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_rounded,
                          size: 18,
                          color: _isHoliday ? const Color(0xFFF97316) : _muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Full day / Holiday',
                                  style: TextStyle(
                                      color: _isHoliday
                                          ? const Color(0xFFC2410C)
                                          : _text,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              Text(
                                'Closes the unit for the entire day',
                                style: TextStyle(
                                    color: _isHoliday
                                        ? const Color(0xFFF97316)
                                        : _muted,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isHoliday,
                          onChanged: (v) => setState(() => _isHoliday = v),
                          activeTrackColor: const Color(0xFFF97316),
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  // ── TIME pickers (only for time blocks) ─────────────
                  if (!_isHoliday) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel('HOURS'),
                    Row(
                      children: [
                        Expanded(
                          child: _TimePickerField(
                            label: 'Start',
                            controller: _startCtrl,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TimePickerField(
                            label: 'End',
                            controller: _endCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unit operates ${widget.openTime} – ${widget.closeTime}',
                      style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // ── REASON ──────────────────────────────────────────
                  _SheetField(
                    label: _isHoliday
                        ? 'Holiday name (optional, defaults to "Holiday")'
                        : 'Reason (optional)',
                    controller: _reasonCtrl,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: _bg,
                  border: Border(top: BorderSide(color: _line)),
                ),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _isHoliday ? const Color(0xFFF97316) : _deep,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isHoliday ? 'Add Holiday' : 'Save Block'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Block type tab ───────────────────────────────────────────────────────────

class _BlockTypeTab extends StatelessWidget {
  const _BlockTypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _deep : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : _muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date picker button ───────────────────────────────────────────────────────

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final dayName = hasDate ? DateFormat('EEE').format(date!) : null;
    final dayNum = hasDate ? DateFormat('d').format(date!) : null;
    final monthYear = hasDate ? DateFormat('MMM yyyy').format(date!) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasDate ? _deep : _line),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasDate ? _deep : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasDate
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayNum!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1)),
                        Text(dayName!,
                            style: const TextStyle(
                                color: Color(0xFFBBF7D0),
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ],
                    )
                  : const Icon(Icons.calendar_month_rounded,
                      color: _muted, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasDate
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthYear!,
                            style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        Text(
                          DateFormat('EEEE, d MMMM').format(date!),
                          style: const TextStyle(
                              color: _text,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  : const Text('Tap to select date',
                      style: TextStyle(
                          color: _muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
            ),
            Icon(
              hasDate
                  ? Icons.edit_calendar_rounded
                  : Icons.chevron_right_rounded,
              color: hasDate ? _deep : _muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Time picker field ────────────────────────────────────────────────────────

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  Future<void> _pick(BuildContext context) async {
    final parts = controller.text.trim().split(':');
    final initHour =
        (parts.length == 2 ? (int.tryParse(parts[0]) ?? 9) : 9).clamp(0, 23);
    final initMin =
        (parts.length == 2 ? (int.tryParse(parts[1]) ?? 0) : 0).clamp(0, 59);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TimeWheelSheet(
        initialHour: initHour,
        initialMinute: initMin,
        onPicked: (h, m) {
          controller.text =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, val, _) {
        final hasValue = val.text.isNotEmpty;
        return GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: hasValue ? _deep : _line),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 16, color: hasValue ? _deep : _muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: hasValue ? _muted : _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Text(
                  hasValue ? val.text : '--:--',
                  style: TextStyle(
                    color: hasValue ? _text : _muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.expand_more_rounded,
                    size: 18, color: hasValue ? _deep : _muted),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Time wheel bottom sheet ──────────────────────────────────────────────────

class _TimeWheelSheet extends StatefulWidget {
  const _TimeWheelSheet({
    required this.initialHour,
    required this.initialMinute,
    required this.onPicked,
  });

  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute) onPicked;

  @override
  State<_TimeWheelSheet> createState() => _TimeWheelSheetState();
}

class _TimeWheelSheetState extends State<_TimeWheelSheet> {
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  // 5-minute increments
  static final _mins = List.generate(12, (i) => i * 5);

  int _nearestMinute(int raw) =>
      _mins.reduce((a, b) => (a - raw).abs() <= (b - raw).abs() ? a : b);

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = _nearestMinute(widget.initialMinute);
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl = FixedExtentScrollController(initialItem: _mins.indexOf(_minute));
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Select time',
                      style: TextStyle(
                          color: _text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
                TextButton(
                  onPressed: () {
                    widget.onPicked(_hour, _minute);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Done',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection band
                Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  children: [
                    // Hours 00–23
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourCtrl,
                        itemExtent: 52,
                        perspective: 0.002,
                        diameterRatio: 2.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) => setState(() => _hour = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (_, i) {
                            final sel = _hour == i;
                            return Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: sel ? _text : _muted,
                                  fontSize: sel ? 28 : 22,
                                  fontWeight:
                                      sel ? FontWeight.w900 : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Separator
                    const Text(':',
                        style: TextStyle(
                            color: _text,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    // Minutes in 5-min steps
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _minCtrl,
                        itemExtent: 52,
                        perspective: 0.002,
                        diameterRatio: 2.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _minute = _mins[i]),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _mins.length,
                          builder: (_, i) {
                            final sel = _minute == _mins[i];
                            return Center(
                              child: Text(
                                _mins[i].toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: sel ? _text : _muted,
                                  fontSize: sel ? 28 : 22,
                                  fontWeight:
                                      sel ? FontWeight.w900 : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SafeArea(
            top: false,
            child: SizedBox(height: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _muted,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: const TextStyle(
                    color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          border: _inputBorder(_line),
          enabledBorder: _inputBorder(_line),
          focusedBorder: _inputBorder(_accent),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );

String _money(int paise) {
  final rupees = paise / 100;
  if (rupees == rupees.roundToDouble()) return 'Rs ${rupees.round()}';
  return 'Rs ${rupees.toStringAsFixed(2)}';
}

String _labelForType(String type) => switch (type) {
      'FULL_GROUND' => 'Full ground',
      'HALF_GROUND' => 'Half ground',
      'CRICKET_NET' => 'Net',
      'INDOOR_NET' => 'Indoor net',
      'CENTER_WICKET' => 'Center wicket',
      'TURF' => 'Turf',
      'MULTI_SPORT' => 'Multi sport',
      _ => type,
    };

String _unitSubtitle(ArenaUnitOption unit) => [
      _labelForType(unit.unitType),
      if (unit.netType != null && unit.netType!.isNotEmpty) unit.netType!,
      _formatDuration(unit.minSlotMins),
      if (unit.hasFloodlights) 'Floodlights',
    ].join(' · ');

String _formatDuration(int mins) {
  if (mins < 60) return '${mins}min';
  if (mins % 60 == 0) return '${mins ~/ 60}hr slots';
  return '${mins ~/ 60}hr ${mins % 60}min';
}

String _weekdayLabels(List<int> days) {
  const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days.where((d) => d >= 1 && d <= 7).map((d) => names[d]).join(', ');
}

List<(String, String)> _computeSlots(
    String openTime, String closeTime, int slotMins) {
  debugPrint('🟡 [_computeSlots] openTime=$openTime closeTime=$closeTime slotMins=$slotMins');
  try {
    final start = _timeToMins(openTime);
    final end = _timeToMins(closeTime);
    debugPrint('🟡 [_computeSlots] start=$start end=$end guard: start<0=${start < 0} end<=start=${end <= start} slotMins<=0=${slotMins <= 0}');
    if (start < 0 || end <= start || slotMins <= 0) {
      debugPrint('🔴 [_computeSlots] early return — bad inputs');
      return const [];
    }
    final slots = <(String, String)>[];
    for (var m = start; m + slotMins <= end; m += slotMins) {
      slots.add((_minsToTime(m), _minsToTime(m + slotMins)));
    }
    debugPrint('🟡 [_computeSlots] result: ${slots.map((s) => '${s.$1}→${s.$2}').join(', ')}');
    return slots;
  } catch (_) {
    return const [];
  }
}

int _timeToMins(String t) {
  final parts = t.split(':');
  if (parts.length != 2) return -1;
  final h = int.tryParse(parts[0]) ?? -1;
  final m = int.tryParse(parts[1]) ?? -1;
  if (h < 0 || m < 0) return -1;
  return h * 60 + m;
}

String _minsToTime(int mins) {
  final h = mins ~/ 60;
  final m = mins % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
