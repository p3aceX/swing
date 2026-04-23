import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_contracts.dart';
import '../providers/host_dio_provider.dart';
import 'biz_models.dart';

class HostBizRepository {
  HostBizRepository(this._dio);

  final Dio _dio;

  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    return const {};
  }

  Future<BizLoginResponse> bizLogin({
    required String idToken,
    String? name,
    String? language,
  }) async {
    final response = await _dio.post(
      HostContracts.bizLogin,
      data: {
        'idToken': idToken,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (language != null && language.isNotEmpty) 'language': language,
      },
    );
    return BizLoginResponse.fromJson(_unwrap(response.data));
  }

  Future<BizMeResponse> getMe() async {
    final response = await _dio.get(HostContracts.bizMe);
    return BizMeResponse.fromJson(_unwrap(response.data));
  }

  Future<BusinessAccount> upsertBusinessDetails(
      BusinessDetailsInput input) async {
    final response = await _dio.put(
      HostContracts.bizBusinessDetails,
      data: input.toJson(),
    );
    return BusinessAccount.fromJson(_unwrap(response.data));
  }

  Future<Map<String, dynamic>> createAcademy(AcademyProfileInput input) async {
    final response =
        await _dio.post(HostContracts.bizAcademy, data: input.toJson());
    return _unwrap(response.data);
  }

  Future<Map<String, dynamic>> createOrUpdateCoach(
      CoachProfileInput input) async {
    final response =
        await _dio.post(HostContracts.bizCoach, data: input.toJson());
    return _unwrap(response.data);
  }

  Future<Map<String, dynamic>> createArena(ArenaProfileInput input) async {
    final response =
        await _dio.post(HostContracts.bizArena, data: input.toJson());
    return _unwrap(response.data);
  }

  Future<List<Map<String, dynamic>>> listStores() async {
    final response = await _dio.get(HostContracts.bizStores);
    final data = response.data;
    final payload =
        data is Map<String, dynamic> ? (data['data'] ?? data) : const [];
    if (payload is! List) return const [];
    return payload
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}

final hostBizRepositoryProvider = Provider<HostBizRepository>(
  (ref) => HostBizRepository(ref.watch(hostDioProvider)),
);
