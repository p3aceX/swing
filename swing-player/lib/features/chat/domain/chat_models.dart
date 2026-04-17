class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    String s(String k) => (j[k] ?? '').toString().trim();
    final sender = j['sender'] is Map<String, dynamic>
        ? j['sender'] as Map<String, dynamic>
        : j['senderProfile'] is Map<String, dynamic>
            ? j['senderProfile'] as Map<String, dynamic>
            : <String, dynamic>{};
    final senderName =
        (sender['name'] ?? sender['displayName'] ?? j['senderName'] ?? '')
            .toString()
            .trim();
    final senderAvatar =
        (sender['avatarUrl'] ?? j['senderAvatarUrl'])?.toString().trim();
    return ChatMessage(
      id: s('id'),
      conversationId: s('conversationId'),
      senderId: (j['senderId'] ?? sender['id'] ?? '').toString().trim(),
      senderName: senderName.isEmpty ? 'Player' : senderName,
      senderAvatar: (senderAvatar?.isEmpty ?? true) ? null : senderAvatar,
      text: (() {
        for (final k in ['body', 'text', 'content', 'message']) {
          final v = (j[k] as String? ?? '').trim();
          if (v.isNotEmpty) return v;
        }
        return '';
      })(),
      createdAt: _parseDateTimeLocal(j['createdAt']),
    );
  }
}

class ConversationParticipant {
  const ConversationParticipant({
    required this.playerId,
    required this.name,
    this.avatarUrl,
  });

  final String playerId;
  final String name;
  final String? avatarUrl;

  factory ConversationParticipant.fromJson(Map<String, dynamic> j) {
    final profile = j['profile'] is Map<String, dynamic>
        ? j['profile'] as Map<String, dynamic>
        : j;
    String s(String k) => (profile[k] ?? j[k] ?? '').toString().trim();
    final avatar = s('avatarUrl');
    // Try all possible name fields: name, fullName, displayName
    final name = [s('name'), s('fullName'), s('displayName')]
        .firstWhere((v) => v.isNotEmpty, orElse: () => 'Player');
    return ConversationParticipant(
      playerId: s('playerId').isEmpty ? s('id') : s('playerId'),
      name: name,
      avatarUrl: avatar.isEmpty ? null : avatar,
    );
  }
}

class Conversation {
  const Conversation({
    required this.id,
    required this.isTeamChat,
    required this.participants,
    required this.updatedAt,
    this.teamId,
    this.teamName,
    this.conversationName,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String id;
  final bool isTeamChat;
  final String? teamId;
  final String? teamName;
  final String? conversationName; // server-set DM name
  final List<ConversationParticipant> participants;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  /// Display name: team name for team chats, other participant's name for DMs.
  String displayName(String myPlayerId) {
    if (isTeamChat) return teamName ?? 'Team Chat';
    // Try to find the other participant by excluding current user
    if (myPlayerId.isNotEmpty) {
      final other =
          participants.where((p) => p.playerId != myPlayerId).firstOrNull;
      if (other != null) return other.name;
    }
    // Fallback: server-assigned conversation name, or first participant
    if (conversationName != null && conversationName!.isNotEmpty) {
      return conversationName!;
    }
    return participants.firstOrNull?.name ?? 'Chat';
  }

  String? displayAvatar(String myPlayerId) {
    if (isTeamChat) return null;
    if (myPlayerId.isNotEmpty) {
      final other =
          participants.where((p) => p.playerId != myPlayerId).firstOrNull;
      if (other != null) return other.avatarUrl;
    }
    return participants.firstOrNull?.avatarUrl;
  }

  factory Conversation.fromJson(Map<String, dynamic> j) {
    String s(String k) => (j[k] ?? '').toString().trim();

    // Parse participants from array OR from counterparty (DM shape)
    final rawParts = j['participants'];
    var participants = rawParts is List
        ? rawParts
            .whereType<Map<String, dynamic>>()
            .map(ConversationParticipant.fromJson)
            .toList()
        : <ConversationParticipant>[];

    // API returns `counterparty` for DIRECT conversations instead of participants
    if (participants.isEmpty && j['counterparty'] is Map<String, dynamic>) {
      participants = [
        ConversationParticipant.fromJson(
            j['counterparty'] as Map<String, dynamic>)
      ];
    }

    ChatMessage? lastMessage;
    final lm = j['lastMessage'];
    if (lm is Map<String, dynamic>) {
      try {
        lastMessage = ChatMessage.fromJson({...lm, 'conversationId': s('id')});
      } catch (_) {}
    }
    // Also handle lastMessagePreview as plain text fallback
    final previewText = (j['lastMessagePreview'] as String? ?? '').trim();

    final isTeam =
        j['type'] == 'TEAM' || j['isTeamChat'] == true || j['teamId'] != null;
    // Use 'title' field as conversation display name (API sets this for DMs)
    final title = (j['title'] as String? ?? '').trim();

    return Conversation(
      id: s('id'),
      isTeamChat: isTeam,
      teamId: j['teamId']?.toString().trim(),
      teamName: (j['teamName'])?.toString().trim(),
      conversationName: title.isNotEmpty
          ? title
          : (isTeam ? null : (j['name'] as String?)?.trim()),
      participants: participants,
      lastMessage: lastMessage ??
          (previewText.isNotEmpty
              ? ChatMessage(
                  id: '',
                  conversationId: s('id'),
                  senderId: (j['lastMessageSenderId'] as String? ?? ''),
                  senderName: '',
                  text: previewText,
                  createdAt: _parseDateTimeLocal(j['lastMessageAt']),
                )
              : null),
      unreadCount: (j['unreadCount'] as num? ?? 0).toInt(),
      updatedAt: _parseDateTimeLocal(
        j['updatedAt'] ?? j['lastMessageAt'] ?? j['createdAt'],
      ),
    );
  }
}

DateTime _parseDateTimeLocal(dynamic raw) {
  final text = (raw ?? '').toString().trim();
  if (text.isEmpty) return DateTime.now();
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return DateTime.now();
  return parsed.toLocal();
}
