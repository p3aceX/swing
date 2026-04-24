import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const String kBaseUrl =
    'https://swing-backend-1007730655118.asia-south1.run.app';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() =>
      statusCode != null ? '$message (HTTP $statusCode)' : message;
}

class ApiClient {
  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse(
      '$kBaseUrl$path',
    ).replace(queryParameters: query == null || query.isEmpty ? null : query);
    final resp = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));
    return _unwrap(resp);
  }

  Future<dynamic> post(String path, Object? body) async {
    final resp = await http
        .post(
          Uri.parse('$kBaseUrl$path'),
          headers: _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _unwrap(resp);
  }

  Future<dynamic> patch(String path, Object? body) async {
    final resp = await http
        .patch(
          Uri.parse('$kBaseUrl$path'),
          headers: _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _unwrap(resp);
  }

  Future<dynamic> put(String path, Object? body) async {
    final resp = await http
        .put(
          Uri.parse('$kBaseUrl$path'),
          headers: _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _unwrap(resp);
  }

  Future<dynamic> delete(String path) async {
    final resp = await http
        .delete(Uri.parse('$kBaseUrl$path'), headers: _headers())
        .timeout(const Duration(seconds: 15));
    return _unwrap(resp);
  }

  Future<dynamic> uploadFile(
    String path, {
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$kBaseUrl$path'));
    request.headers.addAll(_headers());
    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final resp = await http.Response.fromStream(streamed);
    return _unwrap(resp);
  }

  Map<String, String> _headers({bool json = false}) => {
    HttpHeaders.acceptHeader: 'application/json',
    if (json) HttpHeaders.contentTypeHeader: 'application/json',
    if (_token != null) HttpHeaders.authorizationHeader: 'Bearer $_token',
  };

  dynamic _unwrap(http.Response resp) {
    dynamic body;
    if (resp.body.isNotEmpty) {
      try {
        body = jsonDecode(resp.body);
      } catch (_) {}
    }
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (body is Map && body['success'] == true && body.containsKey('data')) {
        return body['data'];
      }
      if (body is Map && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }
    final msg = (body is Map && body['error'] is Map)
        ? (body['error']['message']?.toString() ?? 'Request failed')
        : 'Request failed (HTTP ${resp.statusCode})';
    throw ApiException(msg, statusCode: resp.statusCode);
  }
}

final apiClientProvider = Provider<ApiClient>((_) => ApiClient());
