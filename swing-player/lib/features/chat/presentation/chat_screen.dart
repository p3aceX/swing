import "package:cached_network_image/cached_network_image.dart";
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/controller/profile_controller.dart';
import '../data/chat_repository.dart';
import '../domain/chat_models.dart';
import 'conversations_screen.dart';
import 'gif_picker_sheet.dart';

// ── GIF detection ─────────────────────────────────────────────────────────────

const _gifPrefix = '[[GIF]]';

bool _looksLikeGifUrl(String value) {
  final raw = value.trim();
  if (raw.isEmpty) return false;
  final uri = Uri.tryParse(raw);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();
  if (path.endsWith('.gif') || path.contains('.gif/')) return true;
  return host.contains('tenor.com') || host.contains('giphy.com');
}

bool _isGif(String text) {
  final trimmed = text.trim();
  if (trimmed.startsWith(_gifPrefix)) return true;
  return _looksLikeGifUrl(trimmed);
}

String _gifUrl(String text) {
  final trimmed = text.trim();
  if (trimmed.startsWith(_gifPrefix)) {
    return trimmed.replaceFirst(_gifPrefix, '');
  }
  return trimmed;
}

String _gifPayload(String url) => '$_gifPrefix${url.trim()}';

// ── State ─────────────────────────────────────────────────────────────────────

class _ChatState {
  const _ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.sendError = false,
    this.error,
  });
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool sendError;
  final String? error;

  _ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? sendError,
    String? error,
  }) =>
      _ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        sendError: sendError ?? false,
        error: error,
      );
}

class _ChatNotifier extends StateNotifier<_ChatState> {
  _ChatNotifier(
    this._repo,
    this._conversationId, {
    this.onReadSynced,
  }) : super(const _ChatState()) {
    load();
    _startPolling();
  }

  final ChatRepository _repo;
  final String _conversationId;
  final VoidCallback? onReadSynced;
  Timer? _pollTimer;

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      _poll();
    });
  }

  Future<void> _poll() async {
    try {
      final previousCount = state.messages.length;
      final messages = await _repo.fetchMessages(_conversationId);
      if (mounted) state = state.copyWith(messages: messages);
      if (messages.length > previousCount) {
        await _syncReadStatus();
      }
    } catch (_) {}
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _repo.fetchMessages(_conversationId);
      if (mounted) {
        state = state.copyWith(isLoading: false, messages: messages);
      }
      onReadSynced?.call();
      await _syncReadStatus();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> _syncReadStatus() async {
    final ok = await _repo.markRead(_conversationId);
    if (ok) onReadSynced?.call();
  }

  Future<bool> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    state = state.copyWith(isSending: true);
    final sent = await _repo.sendMessage(_conversationId, trimmed);
    if (!mounted) return false;
    if (sent != null) {
      state =
          state.copyWith(isSending: false, messages: [...state.messages, sent]);
      onReadSynced?.call();
      return true;
    } else {
      state = state.copyWith(isSending: false, sendError: true);
      return false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  final String conversationId;
  final Conversation? conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final AutoDisposeStateNotifierProvider<_ChatNotifier, _ChatState>
      _provider;
  final _textCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollCtrl = ScrollController();
  bool _hasText = false;
  bool _isSearchOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.conversation != null) {
      ChatRepository().rememberConversation(widget.conversation!);
    }
    _provider = StateNotifierProvider.autoDispose<_ChatNotifier, _ChatState>(
      (ref) => _ChatNotifier(
        ChatRepository(),
        widget.conversationId,
        onReadSynced: () {
          ref.invalidate(chatUnreadCountProvider);
          ref.invalidate(conversationsProvider);
          ref.invalidate(notificationSummaryProvider);
        },
      ),
    );
    _textCtrl.addListener(() {
      final v = _textCtrl.text.isNotEmpty;
      if (v != _hasText) setState(() => _hasText = v);
    });
    _searchCtrl.addListener(() {
      final value = _searchCtrl.text;
      if (value != _searchQuery) {
        setState(() => _searchQuery = value);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _openGifPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GifPickerSheet(
        onSelected: (gif) async {
          final notifier = ref.read(_provider.notifier);
          await notifier.send(_gifPayload(gif.url));
        },
      ),
    );
  }

  String _title(String myPlayerId) {
    final conv = widget.conversation;
    if (conv == null) return 'Chat';
    return conv.displayName(myPlayerId);
  }

  String? _avatarUrl(String myPlayerId) =>
      widget.conversation?.displayAvatar(myPlayerId);

  List<ChatMessage> _filteredMessages(List<ChatMessage> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;
    return source.where((msg) {
      if (_isGif(msg.text)) {
        return 'gif'.contains(query) ||
            _gifUrl(msg.text).toLowerCase().contains(query);
      }
      return msg.text.toLowerCase().contains(query) ||
          msg.senderName.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (!_isSearchOpen) {
        _searchCtrl.clear();
      }
    });
    if (_isSearchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    } else {
      _searchFocus.unfocus();
    }
  }

  @override
  void dispose() {
    ref.invalidate(conversationsProvider);
    ref.invalidate(chatUnreadCountProvider);
    ref.invalidate(notificationSummaryProvider);
    _textCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myPlayerId = ref.watch(currentPlayerIdProvider) ?? '';
    if (kDebugMode) {
      debugPrint('[ChatScreen] myPlayerId=$myPlayerId');
      debugPrint('[ChatScreen] conversation=${widget.conversation?.id} '
          'participants=${widget.conversation?.participants.map((p) => "${p.playerId}:${p.name}").toList()}');
      debugPrint('[ChatScreen] resolvedTitle=${_title(myPlayerId)}');
    }
    final state = ref.watch(_provider);
    final notifier = ref.read(_provider.notifier);

    ref.listen(_provider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
      if (next.sendError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to send message'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ));
      }
    });

    final title = _title(myPlayerId);
    final avatarUrl = _avatarUrl(myPlayerId);
    final initials = title
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final visibleMessages = _filteredMessages(state.messages);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardBg,
                image: avatarUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(avatarUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: avatarUrl == null
                  ? Center(
                      child: Text(
                        initials.isEmpty ? '?' : initials,
                        style: TextStyle(
                            color: context.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: context.fgSub,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearchOpen ? 58 : 1),
          child: Column(
            children: [
              Divider(height: 1, color: context.stroke),
              if (_isSearchOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.stroke),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      style: TextStyle(color: context.fg, fontSize: 14.5),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search in chat',
                        hintStyle: TextStyle(color: context.fgSub),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.fgSub,
                          size: 18,
                        ),
                        suffixIcon: _searchQuery.trim().isEmpty
                            ? null
                            : IconButton(
                                icon: Icon(Icons.close_rounded,
                                    color: context.fgSub),
                                onPressed: _searchCtrl.clear,
                              ),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading && state.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null && state.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 40, color: context.fgSub),
                      const SizedBox(height: 12),
                      Text('Could not load messages',
                          style: TextStyle(color: context.fgSub)),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                );
              }
              if (state.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.waving_hand_rounded,
                          size: 36, color: context.accent),
                      const SizedBox(height: 10),
                      Text('Say hi to $title',
                          style: TextStyle(
                              color: context.fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('No messages yet',
                          style: TextStyle(color: context.fgSub, fontSize: 13)),
                    ],
                  ),
                );
              }
              if (_searchQuery.trim().isNotEmpty && visibleMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 34, color: context.fgSub),
                      const SizedBox(height: 10),
                      Text(
                        'No messages found',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try another keyword',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                itemCount: visibleMessages.length,
                itemBuilder: (_, i) {
                  final msg = visibleMessages[i];
                  final isMine =
                      myPlayerId.isNotEmpty && msg.senderId == myPlayerId;
                  final isTeam = widget.conversation?.isTeamChat ?? false;
                  final showDateSep = i == 0 ||
                      !_sameDay(
                          visibleMessages[i - 1].createdAt, msg.createdAt);
                  final prevMsg = i > 0 ? visibleMessages[i - 1] : null;
                  final nextMsg = i < visibleMessages.length - 1
                      ? visibleMessages[i + 1]
                      : null;
                  final isFirst = prevMsg == null ||
                      prevMsg.senderId != msg.senderId ||
                      showDateSep;
                  final isLast =
                      nextMsg == null || nextMsg.senderId != msg.senderId;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDateSep) _DateSeparator(dt: msg.createdAt),
                      _MessageBubble(
                        message: msg,
                        isMine: isMine,
                        showSenderName: isTeam && !isMine && isFirst,
                        showAvatar: isTeam && !isMine && isLast,
                        isFirst: isFirst,
                        isLast: isLast,
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Input bar
          _InputBar(
            controller: _textCtrl,
            isSending: state.isSending,
            hasText: _hasText,
            onSend: () async {
              final text = _textCtrl.text;
              _textCtrl.clear();
              await notifier.send(text);
            },
            onGif: _openGifPicker,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Date Separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.dt});
  final DateTime dt;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      label = 'Today';
    } else if (now.difference(dt).inDays == 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMM yyyy').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.stroke)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Divider(color: context.stroke)),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showSenderName,
    required this.showAvatar,
    required this.isFirst,
    required this.isLast,
  });

  final ChatMessage message;
  final bool isMine;
  final bool showSenderName;
  final bool showAvatar;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isGif = _isGif(message.text);

    final radius = BorderRadius.only(
      topLeft: Radius.circular(isMine ? 20 : (isFirst ? 20 : 6)),
      topRight: Radius.circular(isMine ? (isFirst ? 20 : 6) : 20),
      bottomLeft: Radius.circular(isMine ? 20 : (isLast ? 20 : 6)),
      bottomRight: Radius.circular(isMine ? (isLast ? 6 : 20) : 20),
    );

    Widget content;
    if (isGif) {
      content = _GifBubble(
          url: _gifUrl(message.text), isMine: isMine, radius: radius);
    } else {
      content = _TextBubble(
        message: message,
        isMine: isMine,
        showSenderName: showSenderName,
        radius: radius,
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 6 : 2, bottom: isLast ? 2 : 1),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine && showAvatar) ...[
            _MiniAvatar(
                name: message.senderName, avatarUrl: message.senderAvatar),
            const SizedBox(width: 6),
          ] else if (!isMine) ...[
            const SizedBox(width: 32),
          ],
          content,
        ],
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({
    required this.message,
    required this.isMine,
    required this.showSenderName,
    required this.radius,
  });

  final ChatMessage message;
  final bool isMine;
  final bool showSenderName;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.createdAt);
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine ? context.accent : context.cardBg,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSenderName)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                message.senderName,
                style: TextStyle(
                    color: context.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          Text(
            message.text,
            style: TextStyle(
                color: isMine ? Colors.white : context.fg,
                fontSize: 14.5,
                height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: isMine
                  ? Colors.white.withValues(alpha: 0.5)
                  : context.fgSub.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GifBubble extends StatelessWidget {
  const _GifBubble(
      {required this.url, required this.isMine, required this.radius});

  final String url;
  final bool isMine;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.62,
          maxHeight: 200,
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  width: 160,
                  height: 120,
                  color: context.cardBg,
                  child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: context.accent)),
                ),
          errorBuilder: (_, __, ___) => Container(
            width: 160,
            height: 100,
            color: context.cardBg,
            child: Icon(Icons.broken_image_rounded,
                color: context.fgSub, size: 32),
          ),
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.name, this.avatarUrl});
  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.cardBg,
        image: avatarUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(avatarUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: avatarUrl == null
          ? Center(
              child: Text(initial,
                  style: TextStyle(
                      color: context.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)))
          : null,
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.hasText,
    required this.onSend,
    required this.onGif,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onGif;

  bool get _canSend => hasText && !isSending;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            context.surf.withValues(alpha: 0.96),
            context.bg,
          ),
          border: Border(
            top: BorderSide(color: context.stroke.withValues(alpha: 0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  context.panel.withValues(alpha: 0.72),
                  context.cardBg,
                ),
                context.cardBg,
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: context.stroke.withValues(alpha: 0.95)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionPill(
                onTap: onGif,
                icon: Icons.gif_box_rounded,
                label: 'GIF',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 40, maxHeight: 120),
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: context.fg, fontSize: 15, height: 1.35),
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(
                        color: context.fgSub.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (_canSend) onSend();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _canSend ? onSend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _canSend
                        ? context.accent
                        : context.accent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _canSend
                          ? context.accent.withValues(alpha: 0.8)
                          : context.accent.withValues(alpha: 0.2),
                    ),
                    boxShadow: _canSend
                        ? [
                            BoxShadow(
                              color: context.accent.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _canSend
                              ? Icons.arrow_upward_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            context.accent.withValues(alpha: 0.14),
            context.panel,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.accent.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.accent, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: context.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
