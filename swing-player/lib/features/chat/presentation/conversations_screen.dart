import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/controller/profile_controller.dart';
import '../data/chat_repository.dart';
import '../domain/chat_models.dart';

const _gifPrefix = '[[GIF]]';

bool _looksLikeGifUrl(String text) {
  final raw = text.trim();
  if (raw.isEmpty) return false;
  final uri = Uri.tryParse(raw);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();
  if (path.endsWith('.gif') || path.contains('.gif/')) return true;
  return host.contains('tenor.com') || host.contains('giphy.com');
}

bool _isGifPayload(String text) =>
    text.startsWith(_gifPrefix) || _looksLikeGifUrl(text);

String _conversationPreviewText(String? text) {
  final trimmed = (text ?? '').trim();
  if (trimmed.isEmpty) return 'No messages yet';
  if (_isGifPayload(trimmed)) return 'GIF';
  return trimmed;
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _chatRepoProvider = Provider<ChatRepository>((_) => ChatRepository());

final conversationsProvider =
    StateNotifierProvider.autoDispose<_ConversationsNotifier, _ConvState>(
  (ref) => _ConversationsNotifier(ref.watch(_chatRepoProvider)),
);

class _ConvState {
  const _ConvState({
    this.items = const [],
    this.isLoading = false,
    this.deletingIds = const <String>{},
    this.error,
  });
  final List<Conversation> items;
  final bool isLoading;
  final Set<String> deletingIds;
  final String? error;

  _ConvState copyWith(
          {List<Conversation>? items,
          bool? isLoading,
          Set<String>? deletingIds,
          String? error,
          bool clearError = false}) =>
      _ConvState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        deletingIds: deletingIds ?? this.deletingIds,
        error: clearError ? null : (error ?? this.error),
      );
}

class _ConversationsNotifier extends StateNotifier<_ConvState> {
  _ConversationsNotifier(this._repo) : super(const _ConvState()) {
    load();
  }
  final ChatRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repo.fetchConversations();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> deleteConversation(Conversation conversation) async {
    final id = conversation.id.trim();
    if (id.isEmpty || state.deletingIds.contains(id)) return false;

    final deleting = {...state.deletingIds, id};
    state = state.copyWith(deletingIds: deleting);

    final ok = await _repo.deleteConversation(conversation);
    final nextDeleting = {...state.deletingIds}..remove(id);
    if (ok) {
      final next = state.items.where((c) => c.id != id).toList();
      state = state.copyWith(
        items: next,
        deletingIds: nextDeleting,
        clearError: true,
      );
    } else {
      state = state.copyWith(deletingIds: nextDeleting);
    }
    return ok;
  }
}

final chatUnreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  try {
    return await ref.watch(_chatRepoProvider).fetchUnreadCount();
  } catch (_) {
    return 0;
  }
});

// ── Screen ────────────────────────────────────────────────────────────────────

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final value = _searchCtrl.text;
      if (value != _query) {
        setState(() => _query = value);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Conversation> _filteredItems(
      List<Conversation> items, String myPlayerId) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((conv) {
      final name = conv.displayName(myPlayerId).toLowerCase();
      final preview =
          _conversationPreviewText(conv.lastMessage?.text).toLowerCase();
      final participantMatch = conv.participants.any(
        (p) => p.name.toLowerCase().contains(query),
      );
      return name.contains(query) ||
          preview.contains(query) ||
          participantMatch;
    }).toList();
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(
          'Delete chat?',
          style: TextStyle(color: context.fg, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove your conversation with $title.',
          style: TextStyle(color: context.fgSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: context.fgSub)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return shouldDelete ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);
    final notifier = ref.read(conversationsProvider.notifier);
    final myPlayerId = ref.watch(currentPlayerIdProvider) ?? '';
    final items = _filteredItems(state.items, myPlayerId);
    if (kDebugMode) debugPrint('[ConversationsScreen] myPlayerId=$myPlayerId');

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
        title: Text(
          'Messages',
          style: TextStyle(
              color: context.fg, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.stroke),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchCtrl,
            query: _query,
          ),
          if (_query.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${items.length} result${items.length == 1 ? "" : "s"}',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading && state.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null && state.items.isEmpty) {
                return _ErrorState(onRetry: notifier.load);
              }
              if (state.items.isEmpty) {
                return const _EmptyState();
              }
              if (items.isEmpty) {
                return _EmptySearchState(query: _query);
              }
              return RefreshIndicator(
                onRefresh: notifier.load,
                color: context.accent,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final conv = items[i];
                    final isDeleting = state.deletingIds.contains(conv.id);

                    return Dismissible(
                      key: ValueKey('conv_${conv.id}'),
                      direction: isDeleting
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                      background: const _DeleteSwipeBackground(),
                      confirmDismiss: (direction) async {
                        if (direction != DismissDirection.endToStart) {
                          return false;
                        }
                        final title = conv.displayName(myPlayerId);
                        final confirmed = await _confirmDelete(context, title);
                        if (!confirmed || !mounted) return false;

                        final ok = await notifier.deleteConversation(conv);
                        if (!mounted) return false;
                        if (ok) {
                          ref.invalidate(chatUnreadCountProvider);
                        }
                        final messenger = ScaffoldMessenger.of(this.context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok ? 'Chat deleted' : 'Could not delete chat',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor:
                                ok ? this.context.accent : this.context.danger,
                          ),
                        );
                        return ok;
                      },
                      child: _ConversationTile(
                        conversation: conv,
                        myPlayerId: myPlayerId,
                        isDeleting: isDeleting,
                        onTap: isDeleting
                            ? null
                            : () =>
                                context.push('/chat/${conv.id}', extra: conv),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.query,
  });

  final TextEditingController controller;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(color: context.fg, fontSize: 14.5),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search chats',
            hintStyle: TextStyle(color: context.fgSub.withValues(alpha: 0.8)),
            prefixIcon:
                Icon(Icons.search_rounded, color: context.fgSub, size: 20),
            suffixIcon: query.trim().isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded, color: context.fgSub),
                    onPressed: controller.clear,
                  ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.myPlayerId,
    required this.isDeleting,
    required this.onTap,
  });

  final Conversation conversation;
  final String myPlayerId;
  final bool isDeleting;
  final VoidCallback? onTap;

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final name = conversation.displayName(myPlayerId);
    final avatarUrl = conversation.displayAvatar(myPlayerId);
    final lastMsg = conversation.lastMessage;
    final preview = _conversationPreviewText(lastMsg?.text);
    final isGifPreview = preview == 'GIF';
    final initials = name.isNotEmpty
        ? name
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread
              ? context.accent.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(bottom: BorderSide(color: context.stroke, width: 0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                          child: conversation.isTeamChat
                              ? Icon(Icons.groups_rounded,
                                  color: context.accent, size: 24)
                              : Text(
                                  initials,
                                  style: TextStyle(
                                    color: context.accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        )
                      : null,
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: context.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 15,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMsg != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _timeLabel(lastMsg.createdAt),
                          style: TextStyle(
                            color: hasUnread ? context.accent : context.fgSub,
                            fontSize: 11,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (isGifPreview) ...[
                              Icon(
                                Icons.gif_box_rounded,
                                size: 15,
                                color: hasUnread
                                    ? context.accent
                                    : context.fgSub.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                preview,
                                style: TextStyle(
                                  color: hasUnread
                                      ? context.fg.withValues(alpha: 0.75)
                                      : context.fgSub,
                                  fontSize: 13,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDeleting) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.fgSub,
                          ),
                        ),
                      ] else if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount > 99 ? "99+" : conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / Error ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.cardBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 32, color: context.fgSub),
          ),
          const SizedBox(height: 16),
          Text('No conversations yet',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Start chatting from a player profile',
              style: TextStyle(color: context.fgSub, fontSize: 13)),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: context.cardBg,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.search_off_rounded, color: context.fgSub, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            'No chats found',
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different keyword for "$query"',
            style: TextStyle(color: context.fgSub, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: context.fgSub),
          const SizedBox(height: 12),
          Text('Could not load messages',
              style: TextStyle(color: context.fgSub)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _DeleteSwipeBackground extends StatelessWidget {
  const _DeleteSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.danger.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.danger.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_outline_rounded, color: context.danger, size: 20),
          const SizedBox(width: 6),
          Text(
            'Delete',
            style: TextStyle(
              color: context.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Badge (used in home header) ─────────────────────────────────────────

class ChatBadgeButton extends ConsumerWidget {
  const ChatBadgeButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(chatUnreadCountProvider).valueOrNull ?? 0;
    final hasUnread = unread > 0;

    return Tooltip(
      message: 'Messages',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: hasUnread
                ? Color.alphaBlend(
                    context.accent.withValues(alpha: 0.16),
                    context.cardBg,
                  )
                : context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasUnread
                  ? context.accent.withValues(alpha: 0.45)
                  : context.stroke,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: hasUnread ? context.accent : context.fgSub,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                hasUnread ? (unread > 99 ? '99+' : '$unread') : 'Chat',
                style: TextStyle(
                  color: hasUnread ? context.accent : context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
