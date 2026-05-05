import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import 'inventory_provider.dart';
import 'add_inventory_sheet.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(inventoryProvider)),
        data: (items) {
          final categories = items
              .map((i) => i['category'] as String?)
              .whereType<String>()
              .toSet()
              .toList();

          final filtered = _categoryFilter == null
              ? items
              : items.where((i) => i['category'] == _categoryFilter).toList();

          return Column(
            children: [
              if (categories.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: _categoryFilter == null,
                          onSelected: (_) => setState(() => _categoryFilter = null),
                        ),
                      ),
                      ...categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: _categoryFilter == cat,
                              onSelected: (_) =>
                                  setState(() => _categoryFilter = cat),
                            ),
                          )),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
              Expanded(
                child: filtered.isEmpty
                    ? emptyBody('No items found')
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(inventoryProvider),
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, i) => _InventoryTile(item: filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => const AddInventorySheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InventoryTile extends ConsumerWidget {
  final Map<String, dynamic> item;

  const _InventoryTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = item['id'] as String;
    final condition = item['condition'] as String? ?? 'GOOD';

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Delete "${item['name'] ?? 'this item'}"?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        ref.read(inventoryProvider.notifier).remove(id);
      },
      child: ListTile(
        title: Text(item['name'] as String? ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
            '${item['category'] ?? ''} · Qty: ${item['quantity'] ?? 0}'
                .replaceAll(RegExp(r'^ · '), '')),
        trailing: statusBadge(condition),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => AddInventorySheet(existing: item),
        ),
      ),
    );
  }
}
