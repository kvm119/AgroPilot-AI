import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/copilot_providers.dart';

class CopilotHistoryDrawer extends ConsumerStatefulWidget {
  const CopilotHistoryDrawer({super.key});

  @override
  ConsumerState<CopilotHistoryDrawer> createState() => _CopilotHistoryDrawerState();
}

class _CopilotHistoryDrawerState extends ConsumerState<CopilotHistoryDrawer> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _renameDialog(BuildContext context, ChatSession session) {
    final titleCtrl = TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                ref.read(chatSessionsProvider.notifier).renameSession(session.id, titleCtrl.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = ref.watch(chatSessionsProvider);
    final activeId = ref.watch(activeSessionIdProvider);

    final searchQuery = _searchController.text.toLowerCase();
    final filtered = sessions.where((s) => s.title.toLowerCase().contains(searchQuery)).toList();

    // Grouping by time
    final now = DateTime.now();
    final today = <ChatSession>[];
    final yesterday = <ChatSession>[];
    final thisWeek = <ChatSession>[];
    final older = <ChatSession>[];

    for (final s in filtered) {
      final diff = now.difference(s.updatedAt);
      if (diff.inDays == 0 && s.updatedAt.day == now.day) {
        today.add(s);
      } else if (diff.inDays <= 1) {
        yesterday.add(s);
      } else if (diff.inDays <= 7) {
        thisWeek.add(s);
      } else {
        older.add(s);
      }
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text('Copilot Conversations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final newId = ref.read(chatSessionsProvider.notifier).createNewSession();
                      ref.read(activeSessionIdProvider.notifier).state = newId;
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  if (today.isNotEmpty) ..._buildGroupHeader('Today', today, activeId, theme),
                  if (yesterday.isNotEmpty) ..._buildGroupHeader('Yesterday', yesterday, activeId, theme),
                  if (thisWeek.isNotEmpty) ..._buildGroupHeader('This Week', thisWeek, activeId, theme),
                  if (older.isNotEmpty) ..._buildGroupHeader('Older', older, activeId, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupHeader(String title, List<ChatSession> items, String activeId, ThemeData theme) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.bold)),
      ),
      ...items.map((session) {
        final isSelected = session.id == activeId;
        return ListTile(
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(
            session.isPinned ? Icons.push_pin : Icons.chat_bubble_outline_rounded,
            size: 20,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
          title: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (val) {
              if (val == 'rename') {
                _renameDialog(context, session);
              } else if (val == 'pin') {
                ref.read(chatSessionsProvider.notifier).togglePinSession(session.id);
              } else if (val == 'delete') {
                ref.read(chatSessionsProvider.notifier).deleteSession(session.id);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'rename', child: Text(session.title)),
              PopupMenuItem(value: 'pin', child: Text(session.isPinned ? 'Unpin' : 'Pin')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
          onTap: () {
            ref.read(activeSessionIdProvider.notifier).state = session.id;
            Navigator.of(context).pop();
          },
        );
      }),
    ];
  }
}
