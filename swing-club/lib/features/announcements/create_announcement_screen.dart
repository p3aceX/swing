import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'announcement_provider.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

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
  final Set<String> _sentVia = {};
  bool _isLoading = false;

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
      await ref.read(announcementsProvider.notifier).create({
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'targetGroup': _targetGroup,
        'isPinned': _isPinned,
        'sentVia': _sentVia.toList(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to send announcement');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _send,
            child: _isLoading
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send'),
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
              value: _targetGroup,
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
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Send Via', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            ...kSentViaOptions.map((opt) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt),
                  value: _sentVia.contains(opt),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _sentVia.add(opt);
                    } else {
                      _sentVia.remove(opt);
                    }
                  }),
                )),
          ],
        ),
      ),
    );
  }
}
