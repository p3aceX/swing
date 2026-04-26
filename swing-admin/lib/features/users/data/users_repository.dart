import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/admin_user.dart';

class CreateUserPayload {
  const CreateUserPayload({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.password,
  });
  final String name;
  final String email;
  final String phone;
  final UserType role;
  final String? password;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
        'roles': [role.apiRole],
        if (password != null && password!.isNotEmpty) 'password': password,
      };
}

class UsersRepository {
  UsersRepository(this._api);
  final ApiClient _api;

  Future<UsersPage> list({
    String? role,
    String? search,
    bool? blocked,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (role != null && role.isNotEmpty) 'role': role,
      if (search != null && search.isNotEmpty) 'search': search,
      if (blocked != null) 'blocked': blocked.toString(),
    };
    final resp = await _api.get('/admin/users', query: query);
    return _parsePage(resp, page, limit);
  }

  Future<int> count({String? role}) async {
    final query = <String, String>{
      'page': '1',
      'limit': '1',
      if (role != null && role.isNotEmpty) 'role': role,
    };
    final resp = await _api.get('/admin/users', query: query);
    return _parsePage(resp, 1, 1).total;
  }

  Future<AdminUser> create(CreateUserPayload payload) async {
    final resp = await _api.post('/admin/users', payload.toJson());
    final data = resp is Map<String, dynamic>
        ? resp
        : (resp is Map ? Map<String, dynamic>.from(resp) : <String, dynamic>{});
    if (data.isEmpty) {
      throw ApiException('Unexpected response from /admin/users');
    }
    return AdminUser.fromJson(data);
  }

  Future<AdminUser> detail(String id) async {
    final resp = await _api.get('/admin/users/$id');
    final data = resp is Map<String, dynamic>
        ? resp
        : (resp is Map ? Map<String, dynamic>.from(resp) : <String, dynamic>{});
    if (data.isEmpty) {
      throw ApiException('Unexpected response from /admin/users/$id');
    }
    return AdminUser.fromJson(data);
  }

  Future<void> setBlocked(String id, bool blocked) async {
    await _api.post('/admin/users/$id/${blocked ? 'block' : 'unblock'}', null);
  }

  Future<AdminUser> update(String id, Map<String, dynamic> body) async {
    final resp = await _api.patch('/admin/users/$id', body);
    final data = resp is Map<String, dynamic>
        ? resp
        : (resp is Map ? Map<String, dynamic>.from(resp) : <String, dynamic>{});
    if (data.isEmpty) {
      throw ApiException('Unexpected response from /admin/users/$id');
    }
    return AdminUser.fromJson(data);
  }

  Future<List<AdminUser>> listAll({String? role, int limit = 100}) async {
    final first = await list(role: role, page: 1, limit: limit);
    final users = <AdminUser>[...first.users];
    final totalPages = first.totalPages;
    if (totalPages <= 1) return users;

    for (var page = 2; page <= totalPages; page++) {
      final next = await list(role: role, page: page, limit: limit);
      users.addAll(next.users);
    }
    return users;
  }

  UsersPage _parsePage(dynamic resp, int fallbackPage, int fallbackLimit) {
    List<dynamic> raw = const [];
    int total = 0;
    int page = fallbackPage;
    int limit = fallbackLimit;

    if (resp is List) {
      raw = resp;
      total = resp.length;
    } else if (resp is Map) {
      final users =
          resp['users'] ?? resp['items'] ?? resp['data'] ?? resp['results'];
      if (users is List) raw = users;
      final t = resp['total'] ?? resp['count'];
      if (t is int) total = t;
      if (t is String) total = int.tryParse(t) ?? raw.length;
      if (total == 0) total = raw.length;
      final p = resp['page'];
      if (p is int) page = p;
      if (p is String) page = int.tryParse(p) ?? page;
      final l = resp['limit'] ?? resp['pageSize'];
      if (l is int) limit = l;
      if (l is String) limit = int.tryParse(l) ?? limit;
    }

    return UsersPage(
      users: raw
          .whereType<Map>()
          .map((m) => AdminUser.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      total: total,
      page: page,
      limit: limit,
    );
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(apiClientProvider));
});

class UsersQuery {
  const UsersQuery({
    this.role,
    this.search,
    this.page = 1,
    this.limit = 20,
  });
  final String? role;
  final String? search;
  final int page;
  final int limit;

  UsersQuery copyWith({
    String? role,
    String? search,
    int? page,
    int? limit,
    bool clearRole = false,
    bool clearSearch = false,
  }) =>
      UsersQuery(
        role: clearRole ? null : (role ?? this.role),
        search: clearSearch ? null : (search ?? this.search),
        page: page ?? this.page,
        limit: limit ?? this.limit,
      );

  @override
  bool operator ==(Object other) =>
      other is UsersQuery &&
      other.role == role &&
      other.search == search &&
      other.page == page &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(role, search, page, limit);
}

final usersQueryProvider =
    StateProvider<UsersQuery>((_) => const UsersQuery());

final usersListProvider = FutureProvider<UsersPage>((ref) {
  final q = ref.watch(usersQueryProvider);
  return ref.watch(usersRepositoryProvider).list(
        role: q.role,
        search: q.search,
        page: q.page,
        limit: q.limit,
      );
});

class UserStats {
  const UserStats({
    required this.total,
    required this.players,
    required this.biz,
    required this.admins,
  });
  final int total;
  final int players;
  final int biz;
  final int admins;
}

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repo = ref.watch(usersRepositoryProvider);
  final results = await Future.wait([
    repo.count(),
    repo.count(role: UserType.player.apiRole),
    repo.count(role: UserType.businessOwner.apiRole),
    repo.count(role: UserType.admin.apiRole),
  ]);
  return UserStats(
    total: results[0],
    players: results[1],
    biz: results[2],
    admins: results[3],
  );
});

final onboardingTrendUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  return ref.watch(usersRepositoryProvider).listAll(limit: 100);
});

final userDetailProvider =
    FutureProvider.family<AdminUser, String>((ref, userId) async {
  return ref.watch(usersRepositoryProvider).detail(userId);
});
