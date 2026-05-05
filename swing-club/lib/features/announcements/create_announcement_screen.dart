import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'announcement_provider.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;

  const CreateAnnouncementScreen({super.key, this.existing});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends ConsumerState<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _targetGroup = kTargetGroups.first;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e['title'] as String? ?? '';
      _bodyCtrl.text = e['body'] as String? ?? '';
      final tg = e['targetGroup'] as String?;
      if (tg != null && kTargetGroups.contains(tg)) _targetGroup = tg;
      _isPinned = e['isPinned'] as bool? ?? false;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final payload = {
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'targetGroup': _targetGroup,
        'isPinned': _isPinned,
      };
      final e = widget.existing;
      if (e != null) {
        await ref.read(announcementsProvider.notifier).edit(e['id'] as String, payload);
      } else {
        await ref.read(announcementsProvider.notifier).create(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save announcement');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Announcement' : 'New Announcement'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _send,
            child: _isLoading
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEdit ? 'Update' : 'Send'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(labelText: 'Message *'),
              maxLines: 6,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _targetGroup,
              decoration: const InputDecoration(labelText: 'Target Group'),
              items: kTargetGroups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _targetGroup = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pin Announcement'),
              value: _isPinned,
              onChanged: (v) => setState(() => _isPinned = v),
            ),
          ],
        ),
      ),
    );
  }
}
