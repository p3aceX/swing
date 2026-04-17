import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/gif_service.dart';

class GifPickerSheet extends StatefulWidget {
  const GifPickerSheet({super.key, required this.onSelected});

  final ValueChanged<GifItem> onSelected;

  @override
  State<GifPickerSheet> createState() => _GifPickerSheetState();
}

class _GifPickerSheetState extends State<GifPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<GifItem> _items = [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    setState(() => _loading = true);
    final items = await GifService.instance.trending();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _loading = true);
      final items = q.trim().isEmpty
          ? await GifService.instance.trending()
          : await GifService.instance.search(q);
      if (mounted) setState(() { _items = items; _loading = false; });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text('GIF',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded, color: context.fgSub, size: 22),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.stroke),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: TextStyle(color: context.fg, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search GIFs...',
                  hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: context.accent))
                : _items.isEmpty
                    ? Center(
                        child: Text('No GIFs found',
                            style: TextStyle(color: context.fgSub)),
                      )
                    : GridView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final gif = _items[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelected(gif);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                gif.previewUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : Container(color: context.cardBg),
                                errorBuilder: (_, __, ___) =>
                                    Container(color: context.cardBg),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
