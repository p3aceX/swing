import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/chat_models.dart';

class ChatRepository {
  ChatRepository() : _dio = ApiClient.instance.dio;

  final Dio _dio;
  static final Map<String, Conversation> _localConversationCache = {};
  static const _hiddenConversationMetaKey = 'chat_hidden_conversation_meta_v2';

  void _rememberConversation(Conversation conversation) {
    final id = conversation.id.trim();
    if (id.isEmpty) return;
    _localConversationCache[id] = conversation;
  }

  void rememberConversation(Conversation conversation) {
    _rememberConversation(conversation);
  }

  Future<List<Conversation>> fetchConversations() async {
    try {
      final res = await _dio.get(ApiEndpoints.chatConversations);
      final body = res.data;
      if (kDebugMode) debugPrint('[Chat] fetchConversations raw: $body');
      List raw = [];
      if (body is Map) {
        final d = body['data'];
        if (d is List) {
          raw = d;
        } else if (d is Map) {
          final inner = d['data'] ?? d['items'] ?? [];
          if (inner is List) raw = inner;
        }
      } else if (body is List) {
        raw = body;
      }
      if (kDebugMode) {
        debugPrint('[Chat] conversations list count: ${raw.length}');
      }
      final conversations = raw.whereType<Map<String, dynamic>>().map((j) {
        if (kDebugMode) debugPrint('[Chat] conversation json: $j');
        return Conversation.fromJson(j);
      }).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      for (final c in conversations) {
        _rememberConversation(c);
      }
      final merged = <Conversation>[...conversations];
      final seenIds = conversations.map((c) => c.id).toSet();
      for (final cached in _localConversationCache.values) {
        if (seenIds.add(cached.id)) {
          merged.add(cached);
        }
      }
      merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (kDebugMode) {
        for (final c in merged) {
          debugPrint('[Chat] parsed conv id=${c.id} isTeam=${c.isTeamChat} '
              'teamName=${c.teamName} convName=${c.conversationName} '
              'participants=${c.participants.map((p) => "${p.playerId}:${p.name}").toList()}');
        }
      }
      final hiddenMeta = await _getHiddenConversationMeta();
      if (hiddenMeta.isEmpty) return merged;

      var didUnhide = false;
      final visible = <Conversation>[];
      for (final conversation in merged) {
        final deletedAtMillis = hiddenMeta[conversation.id];
        if (deletedAtMillis == null) {
          visible.add(conversation);
          continue;
        }

        final updatedAtMillis = conversation.updatedAt.millisecondsSinceEpoch;
        if (updatedAtMillis > deletedAtMillis) {
          // Conversation had new activity after local delete, so unhide it.
          hiddenMeta.remove(conversation.id);
          didUnhide = true;
          visible.add(conversation);
        }
      }

      if (didUnhide) {
        await _setHiddenConversationMeta(hiddenMeta);
      }
      return visible;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Chat] fetchConversations error: $e');
        if (e is DioException) {
          debugPrint('[Chat] response: ${e.response?.data}');
        }
      }
      return [];
    }
  }

  /// GET or create a DM with [playerId]. Returns the conversation.
  Future<Conversation> getOrCreateDirect(String playerId) async {
    final res = await _dio.post(ApiEndpoints.chatDirect(playerId));
    final body = res.data;
    final raw = body is Map
        ? (body['data'] ?? body['conversation'] ?? body) as Map<String, dynamic>
        : <String, dynamic>{};
    final conversation = Conversation.fromJson(raw);
    _rememberConversation(conversation);
    await _unhideConversationLocally(conversation.id);
    return conversation;
  }

  /// GET or create team chat for [teamId]. Returns the conversation.
  Future<Conversation> getOrCreateTeamChat(String teamId) async {
    final res = await _dio.post(ApiEndpoints.chatTeam(teamId));
    final body = res.data;
    final raw = body is Map
        ? (body['data'] ?? body['conversation'] ?? body) as Map<String, dynamic>
        : <String, dynamic>{};
    final conversation = Conversation.fromJson(raw);
    _rememberConversation(conversation);
    await _unhideConversationLocally(conversation.id);
    return conversation;
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId,
      {int page = 1, int limit = 50}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.chatConversationMessages(conversationId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = res.data;
      if (kDebugMode) debugPrint('[Chat] fetchMessages raw: $body');
      List raw = [];
      if (body is Map) {
        final d = body['data'];
        if (d is List) {
          raw = d;
        } else if (d is Map) {
          final inner = d['data'] ?? d['items'] ?? d['messages'] ?? [];
          if (inner is List) raw = inner;
        }
      } else if (body is List) {
        raw = body;
      }
      if (kDebugMode) debugPrint('[Chat] messages count: ${raw.length}');
      final messages = raw.whereType<Map<String, dynamic>>().map((j) {
        if (kDebugMode) debugPrint('[Chat] message json: $j');
        return ChatMessage.fromJson({...j, 'conversationId': conversationId});
      }).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (kDebugMode) {
        for (final m in messages) {
          debugPrint('[Chat] parsed msg id=${m.id} senderId=${m.senderId} '
              'senderName=${m.senderName} text="${m.text}"');
        }
      }
      return messages;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Chat] fetchMessages error: $e');
        if (e is DioException) {
          debugPrint('[Chat] response: ${e.response?.data}');
        }
      }
      return [];
    }
  }

  Future<ChatMessage?> sendMessage(String conversationId, String text) async {
    try {
      if (kDebugMode) {
        debugPrint(
            '[Chat] sendMessage conversationId=$conversationId body={content: $text}');
      }
      final res = await _dio.post(
        ApiEndpoints.chatConversationMessages(conversationId),
        data: {'body': text},
      );
      if (kDebugMode) debugPrint('[Chat] sendMessage response: ${res.data}');
      final body = res.data;
      final raw = body is Map
          ? (body['data'] ?? body['message'] ?? body) as Map<String, dynamic>
          : <String, dynamic>{};
      await _unhideConversationLocally(conversationId);
      final sent = ChatMessage.fromJson({...raw, 'conversationId': conversationId});
      final convId = conversationId.trim();
      final existing = _localConversationCache[convId];
      _localConversationCache[convId] = Conversation(
        id: convId,
        isTeamChat: existing?.isTeamChat ?? false,
        participants: existing?.participants ?? const [],
        updatedAt: sent.createdAt,
        teamId: existing?.teamId,
        teamName: existing?.teamName,
        conversationName: existing?.conversationName,
        lastMessage: sent,
        unreadCount: existing?.unreadCount ?? 0,
      );
      return sent;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Chat] sendMessage error: $e');
        if (e is DioException) {
          debugPrint('[Chat] response body: ${e.response?.data}');
        }
      }
      return null;
    }
  }

  Future<bool> markRead(String conversationId) async {
    try {
      await _dio.post(ApiEndpoints.chatConversationRead(conversationId));
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Chat] markRead error: $e');
      }
      return false;
    }
  }

  Future<bool> deleteConversation(Conversation conversation) async {
    final conversationId = conversation.id.trim();
    if (conversationId.isEmpty) return false;

    var remoteDeleted = false;
    var remoteAction = 'none';
    try {
      final teamId = conversation.teamId?.trim();
      if (conversation.isTeamChat && teamId != null && teamId.isNotEmpty) {
        remoteDeleted =
            await _requestOk(() => _dio.post(ApiEndpoints.chatTeamLeave(teamId)));
        if (remoteDeleted) remoteAction = 'team_leave';
      } else {
        remoteDeleted = await _requestOk(
          () => _dio.post('${ApiEndpoints.chatConversation(conversationId)}/leave'),
        );
        if (remoteDeleted) {
          remoteAction = 'conversation_leave';
        } else {
          remoteDeleted = await _requestOk(
            () => _dio.post(
                '${ApiEndpoints.chatConversation(conversationId)}/archive'),
          );
          if (remoteDeleted) {
            remoteAction = 'conversation_archive';
          } else {
            remoteDeleted = await _requestOk(
              () => _dio.delete(ApiEndpoints.chatConversation(conversationId)),
            );
            if (remoteDeleted) {
              remoteAction = 'conversation_delete';
            } else {
              remoteDeleted = await _requestOk(
                () => _dio.post(
                    '${ApiEndpoints.chatConversation(conversationId)}/delete'),
              );
              if (remoteDeleted) remoteAction = 'conversation_delete_post';
            }
          }
        }
      }
      _localConversationCache.remove(conversationId);
      await _hideConversationLocally(conversationId);
      if (kDebugMode) {
        debugPrint('[Chat] deleteConversation id=$conversationId '
            'remoteDeleted=$remoteDeleted action=$remoteAction');
      }
      return true;
    } catch (e) {
      if (kDebugMode && !remoteDeleted) {
        debugPrint('[Chat] deleteConversation failed: $e');
      }
      _localConversationCache.remove(conversationId);
      await _hideConversationLocally(conversationId);
      return true;
    }
  }

  Future<bool> _requestOk(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final code = response.statusCode ?? 0;
      return code >= 200 && code < 300;
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (code == 404) {
        return false;
      }
      if (kDebugMode) {
        debugPrint('[Chat] request error code=$code, error=$e');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Chat] request unknown error: $e');
      }
      return false;
    }
  }

  Future<void> _hideConversationLocally(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    final meta = await _getHiddenConversationMeta();
    meta[trimmed] = DateTime.now().millisecondsSinceEpoch;
    await _setHiddenConversationMeta(meta);
  }

  Future<void> _unhideConversationLocally(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    final meta = await _getHiddenConversationMeta();
    if (meta.remove(trimmed) != null) {
      await _setHiddenConversationMeta(meta);
    }
  }

  Future<Map<String, int>> _getHiddenConversationMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_hiddenConversationMetaKey) ?? const [];
    final out = <String, int>{};
    for (final entry in raw) {
      final sep = entry.indexOf('|');
      if (sep <= 0 || sep >= entry.length - 1) continue;
      final id = entry.substring(0, sep).trim();
      final millis = int.tryParse(entry.substring(sep + 1).trim());
      if (id.isEmpty || millis == null) continue;
      out[id] = millis;
    }
    return out;
  }

  Future<void> _setHiddenConversationMeta(Map<String, int> meta) async {
    final prefs = await SharedPreferences.getInstance();
    if (meta.isEmpty) {
      await prefs.remove(_hiddenConversationMetaKey);
      return;
    }
    final encoded = meta.entries
        .map((e) => '${e.key.trim()}|${e.value}')
        .where((e) => !e.startsWith('|'))
        .toList();
    await prefs.setStringList(_hiddenConversationMetaKey, encoded);
  }

  Future<int> fetchUnreadCount() async {
    try {
      final conversations = await fetchConversations();
      return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
    } catch (_) {
      return 0;
    }
  }
}
