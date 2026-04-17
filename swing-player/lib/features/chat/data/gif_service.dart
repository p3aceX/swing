import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GifItem {
  const GifItem({required this.id, required this.url, required this.previewUrl});
  final String id;
  final String url;       // full GIF
  final String previewUrl; // small preview for grid
}

class GifService {
  GifService._() : _dio = Dio(BaseOptions(baseUrl: 'https://api.klipy.com/v2'));

  static final GifService instance = GifService._();

  final Dio _dio;

  String get _key =>
      dotenv.env['KLIPY_API_KEY'] ?? dotenv.env['TENOR_API_KEY'] ?? 'LIVDSRZULELA';

  Future<List<GifItem>> trending({int limit = 24}) async {
    try {
      final res = await _dio.get('/featured', queryParameters: {
        'key': _key,
        'limit': limit,
        'media_filter': 'tinygif,gif',
        'contentfilter': 'medium',
      });
      return _parse(res.data);
    } catch (e) {
      if (kDebugMode) debugPrint('[GIF] trending error: $e');
      return [];
    }
  }

  Future<List<GifItem>> search(String query, {int limit = 24}) async {
    if (query.trim().isEmpty) return trending(limit: limit);
    try {
      final res = await _dio.get('/search', queryParameters: {
        'key': _key,
        'q': query.trim(),
        'limit': limit,
        'media_filter': 'tinygif,gif',
        'contentfilter': 'medium',
      });
      return _parse(res.data);
    } catch (e) {
      if (kDebugMode) debugPrint('[GIF] search error: $e');
      return [];
    }
  }

  List<GifItem> _parse(dynamic body) {
    final results = body is Map ? (body['results'] as List? ?? []) : [];
    return results.whereType<Map<String, dynamic>>().map((r) {
      final formats = r['media_formats'] as Map<String, dynamic>? ?? {};

      String pickUrl(List<String> keys) {
        for (final key in keys) {
          final node = formats[key];
          if (node is! Map<String, dynamic>) continue;
          final url = (node['url'] ?? '').toString().trim();
          if (url.isNotEmpty) return url;
        }
        return '';
      }

      final url = pickUrl(const ['gif', 'mediumgif', 'tinygif', 'nanogif']);
      final preview = pickUrl(const ['tinygif', 'nanogif', 'gif', 'mediumgif']);
      return GifItem(
        id: (r['id'] ?? '').toString(),
        url: url,
        previewUrl: preview.isNotEmpty ? preview : url,
      );
    }).where((g) => g.url.isNotEmpty).toList();
  }
}
