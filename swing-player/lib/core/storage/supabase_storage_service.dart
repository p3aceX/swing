import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseStorageService {
  SupabaseStorageService({Dio? dio}) : _dio = dio ?? Dio();

  static const _bucket = 'swing-media';
  final Dio _dio;

  static String? userProfileImageUrl(String userId) {
    return _publicUserMediaUrl(userId, 'avatar');
  }

  static String? userCoverImageUrl(String userId) {
    return _publicUserMediaUrl(userId, 'cover');
  }

  Future<String> uploadTeamLogo(XFile file) async {
    final config = _loadConfig();
    final bytes = await _validateImage(file);
    final extension = _fileExtension(file.name);
    final path =
        'teams/new-team-${DateTime.now().millisecondsSinceEpoch}/logo.$extension';
    return _uploadFile(
      supabaseUrl: config.$1,
      anonKey: config.$2,
      path: path,
      bytes: bytes,
      extension: extension,
    );
  }

  Future<String> uploadTeamLogoBytes(
      List<int> bytes, String extension) async {
    final config = _loadConfig();
    if (bytes.length > 5 * 1024 * 1024) {
      throw StateError('Image must be 5 MB or smaller.');
    }
    final path =
        'teams/new-team-${DateTime.now().millisecondsSinceEpoch}/logo.$extension';
    return _uploadFile(
      supabaseUrl: config.$1,
      anonKey: config.$2,
      path: path,
      bytes: bytes,
      extension: extension,
    );
  }

  Future<String> uploadTeamLogoForTeam(String teamId, XFile file) async {
    final config = _loadConfig();
    final bytes = await _validateImage(file);
    final extension = _fileExtension(file.name);
    final path = 'teams/$teamId/logo.$extension';
    return _uploadFile(
      supabaseUrl: config.$1,
      anonKey: config.$2,
      path: path,
      bytes: bytes,
      extension: extension,
    );
  }

  Future<String> uploadUserProfileImage({
    required String userId,
    required XFile file,
  }) async {
    final config = _loadConfig();
    final bytes = await _validateImage(file);
    final extension = _fileExtension(file.name);
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final path = 'users/profile-images/$safeUserId/avatar';

    return _uploadFile(
      supabaseUrl: config.$1,
      anonKey: config.$2,
      path: path,
      bytes: bytes,
      extension: extension,
    );
  }

  Future<String> uploadUserCoverImage({
    required String userId,
    required XFile file,
  }) async {
    final config = _loadConfig();
    final bytes = await _validateImage(file);
    final extension = _fileExtension(file.name);
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final path = 'users/profile-images/$safeUserId/cover';

    return _uploadFile(
      supabaseUrl: config.$1,
      anonKey: config.$2,
      path: path,
      bytes: bytes,
      extension: extension,
    );
  }

  static String? _publicUserMediaUrl(String userId, String objectName) {
    final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    if (supabaseUrl.isEmpty || userId.trim().isEmpty) {
      return null;
    }
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    if (safeUserId.isEmpty) return null;
    return '$supabaseUrl/storage/v1/object/public/$_bucket/users/profile-images/$safeUserId/$objectName';
  }

  (String, String) _loadConfig() {
    final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    if (supabaseUrl.isEmpty || anonKey.isEmpty) {
      throw StateError('Image uploads are not configured yet.');
    }
    return (supabaseUrl, anonKey);
  }

  Future<List<int>> _validateImage(XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      throw StateError('Image must be 5 MB or smaller.');
    }
    return bytes;
  }

  Future<String> _uploadFile({
    required String supabaseUrl,
    required String anonKey,
    required String path,
    required List<int> bytes,
    required String extension,
  }) async {
    final uploadUrl = '$supabaseUrl/storage/v1/object/$_bucket/$path';

    await _dio.post<void>(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {
          'Authorization': 'Bearer $anonKey',
          'apikey': anonKey,
          'x-upsert': 'true',
          'Content-Type': _contentTypeFor(extension),
        },
      ),
    );

    return '$supabaseUrl/storage/v1/object/public/$_bucket/$path';
  }

  String _fileExtension(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot == -1 || dot == filename.length - 1) return 'jpg';
    return filename.substring(dot + 1).toLowerCase();
  }

  String _contentTypeFor(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }
}
