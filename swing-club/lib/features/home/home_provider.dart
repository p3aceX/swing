import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';

class BatchRevenueStat {
  final String name;
  final int maxStudents;
  final int enrolled;
  final int feeAmountPaise;
  final int expectedPaise;          // feeAmountPaise * maxStudents
  final int occupancyRevenuePaise;  // feeAmountPaise * enrolled
  final int collectedPaise;         // actual collected this month
  const BatchRevenueStat({
    required this.name,
    required this.maxStudents,
    required this.enrolled,
    required this.feeAmountPaise,
    required this.expectedPaise,
    required this.occupancyRevenuePaise,
    required this.collectedPaise,
  });
}

class HomeData {
  final Map<String, dynamic> academy;
  final List<Map<String, dynamic>> todaySessions;
  final int pendingFeesCount;
  final bool hasNoAcademy;

  // KPIs
  final int monthlyRevenuePaise;
  final int activeStudents;
  final double feeCollectionRate;   // 0.0–1.0
  final double avgBatchOccupancy;   // 0.0–1.0
  final int newStudentsThisMonth;
  final List<BatchRevenueStat> batchRevenueStats;

  // P&L
  final int totalExpectedMonthlyPaise;  // sum of all enrollment monthly fees
  final int totalCollectedEverPaise;    // sum of all feePaid across enrollments

  const HomeData({
    required this.academy,
    required this.todaySessions,
    required this.pendingFeesCount,
    this.hasNoAcademy = false,
    this.monthlyRevenuePaise = 0,
    this.activeStudents = 0,
    this.feeCollectionRate = 0,
    this.avgBatchOccupancy = 0,
    this.newStudentsThisMonth = 0,
    this.batchRevenueStats = const [],
    this.totalExpectedMonthlyPaise = 0,
    this.totalCollectedEverPaise = 0,
  });

  static const empty = HomeData(academy: {}, todaySessions: [], pendingFeesCount: 0, hasNoAcademy: true);
}

class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() async {
    AcademyState academyState;
    try {
      academyState = await ref.watch(academyProvider.future);
    } catch (_) {
      return HomeData.empty;
    }

    final api = ref.read(apiClientProvider);
    final id = academyState.academyId;

    final now   = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end   = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    List<Map<String, dynamic>> sessions = [];
    int pendingCount = 0;
    Map<String, dynamic> academyData = academyState.data;

    int monthlyRevenuePaise = 0;
    int activeStudents = 0;
    double feeCollectionRate = 0;
    double avgBatchOccupancy = 0;
    int newStudentsThisMonth = 0;
    List<BatchRevenueStat> batchRevenueStats = [];
    int totalExpectedMonthlyPaise = 0;
    int totalCollectedEverPaise = 0;

    try {
      final results = await Future.wait([
        api.get('/academy/my'),
        api.get('/academy/$id/sessions', params: {'from': start, 'to': end}),
        api.get('/academy/$id/fee-payments', params: {'limit': '200'}),
        api.get('/academy/$id/batches'),
        api.get('/academy/$id/students', params: {'limit': '200'}),
      ]);

      // ── Academy ──────────────────────────────────────────────────────────
      final raw = results[0].data['data'];
      if (raw != null) academyData = Map<String, dynamic>.from(raw as Map);

      // ── Sessions ─────────────────────────────────────────────────────────
      final sessionsRaw = results[1].data['data'];
      sessions = sessionsRaw is List
          ? sessionsRaw.cast<Map<String, dynamic>>()
          : (sessionsRaw?['items'] as List? ?? []).cast<Map<String, dynamic>>();

      // ── Fee payments → revenue, collection rate, active students ─────────
      final feeRaw = results[2].data['data'];
      final feeList = HomeNotifier._parseFeeList(feeRaw);
      if (feeRaw is Map) {
        final meta = feeRaw['meta'] as Map?;
        if (meta != null) pendingCount = (meta['total'] as num? ?? 0).toInt();
      }

      int paidCount = 0;
      int overdueCount = 0;
      for (final enrollment in feeList) {
        final status = enrollment['status'] as String? ?? '';
        if (status == 'PAID') paidCount++;
        if (status == 'OVERDUE') overdueCount++;

        final history = (enrollment['history'] as List? ?? []).cast<Map>();
        for (final payment in history) {
          final dateStr = payment['date'] as String? ?? '';
          if (dateStr.isEmpty) continue;
          try {
            final d = DateTime.parse(dateStr);
            if (d.year == now.year && d.month == now.month) {
              monthlyRevenuePaise += (payment['amount'] as num? ?? 0).toInt();
            }
          } catch (_) {}
        }
      }

      final totalFromFees = feeList.length;
      feeCollectionRate = totalFromFees > 0 ? paidCount / totalFromFees : 0;
      activeStudents = (academyData['totalStudents'] as num? ?? totalFromFees).toInt() - overdueCount;
      if (activeStudents < 0) activeStudents = 0;
      pendingCount = overdueCount + (totalFromFees - paidCount - overdueCount); // UNPAID + OVERDUE

      for (final e in feeList) {
        totalExpectedMonthlyPaise += (e['amount'] as num? ?? 0).toInt();
        totalCollectedEverPaise  += (e['feePaid'] as num? ?? 0).toInt();
      }

      // ── Batches → occupancy ───────────────────────────────────────────────
      final batchesRaw = results[3].data['data'];
      final batchList = batchesRaw is List
          ? batchesRaw.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      double totalOcc = 0;
      int activeBatches = 0;
      for (final batch in batchList) {
        final countMap = (batch['_count'] as Map?) ?? {};
        final enrolled = (countMap['enrollments'] as num? ?? 0).toInt();
        final maxS = (batch['maxStudents'] as num? ?? 20).toInt();
        if (maxS > 0) {
          totalOcc += enrolled / maxS;
          activeBatches++;
        }
      }
      avgBatchOccupancy = activeBatches > 0 ? totalOcc / activeBatches : 0;

      // ── Students → new joins this month ───────────────────────────────────
      final studentsRaw = results[4].data['data'];
      List<Map<String, dynamic>> studentsList = [];
      if (studentsRaw is List) {
        studentsList = studentsRaw.cast();
      } else if (studentsRaw is Map) {
        final inner = studentsRaw['data'] ?? studentsRaw['items'];
        if (inner is List) studentsList = inner.cast();
      }
      for (final student in studentsList) {
        final enrolledAt = student['enrolledAt'] as String? ?? '';
        if (enrolledAt.isEmpty) continue;
        try {
          final d = DateTime.parse(enrolledAt);
          if (d.year == now.year && d.month == now.month) newStudentsThisMonth++;
        } catch (_) {}
      }
      // ── Batch revenue stats from batches API ────────────────────────────
      // Build collected-this-month map keyed by batch name
      final Map<String, int> batchCollectedMap = {};
      for (final enrollment in feeList) {
        final batchName = enrollment['batchName'] as String? ?? '';
        if (batchName.isEmpty) continue;
        int thisMonth = 0;
        for (final p in (enrollment['history'] as List? ?? []).cast<Map>()) {
          final dateStr = p['date'] as String? ?? '';
          if (dateStr.isEmpty) continue;
          try {
            final d = DateTime.parse(dateStr);
            if (d.year == now.year && d.month == now.month) {
              thisMonth += (p['amount'] as num? ?? 0).toInt();
            }
          } catch (_) {}
        }
        batchCollectedMap[batchName] = (batchCollectedMap[batchName] ?? 0) + thisMonth;
      }
      // Build per-batch stats from batches list
      for (final batch in batchList) {
        final name      = batch['name'] as String? ?? 'Unknown';
        final maxS      = (batch['maxStudents'] as num? ?? 20).toInt();
        final enrolled  = ((batch['_count'] as Map?)?['enrollments'] as num? ?? 0).toInt();
        final fees      = (batch['feeStructures'] as List? ?? []).cast<Map>();
        final feeAmt    = fees.isNotEmpty ? (fees.first['amountPaise'] as num? ?? 0).toInt() : 0;
        if (feeAmt == 0 && maxS == 0) continue;
        batchRevenueStats.add(BatchRevenueStat(
          name: name,
          maxStudents: maxS,
          enrolled: enrolled,
          feeAmountPaise: feeAmt,
          expectedPaise: feeAmt * maxS,
          occupancyRevenuePaise: feeAmt * enrolled,
          collectedPaise: batchCollectedMap[name] ?? 0,
        ));
      }
    } catch (_) {
      // Partial failure — show academy info with empty KPIs
    }

    return HomeData(
      academy: academyData,
      todaySessions: sessions,
      pendingFeesCount: pendingCount,
      monthlyRevenuePaise: monthlyRevenuePaise,
      activeStudents: activeStudents,
      feeCollectionRate: feeCollectionRate,
      avgBatchOccupancy: avgBatchOccupancy,
      newStudentsThisMonth: newStudentsThisMonth,
      batchRevenueStats: batchRevenueStats,
      totalExpectedMonthlyPaise: totalExpectedMonthlyPaise,
      totalCollectedEverPaise: totalCollectedEverPaise,
    );
  }

  // Re-usable helper to parse fee list from raw response
  static List<Map<String, dynamic>> _parseFeeList(dynamic raw) {
    if (raw is List) return raw.cast();
    if (raw is Map) {
      final inner = raw['data'] ?? raw['items'];
      if (inner is List) return inner.cast();
    }
    return [];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeData>(HomeNotifier.new);
