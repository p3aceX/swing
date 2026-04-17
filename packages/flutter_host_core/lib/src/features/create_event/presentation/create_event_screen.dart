import 'package:flutter/material.dart';

typedef HostEventCreated = void Function(
  BuildContext context,
  Map<String, dynamic> event,
);

class HostCreateEventScreen extends StatefulWidget {
  const HostCreateEventScreen({
    super.key,
    this.title = 'Create Event',
    this.onEventCreated,
  });

  final String title;
  final HostEventCreated? onEventCreated;

  @override
  State<HostCreateEventScreen> createState() => _HostCreateEventScreenState();
}

class _HostCreateEventScreenState extends State<HostCreateEventScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event name'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                widget.onEventCreated?.call(
                  context,
                  {'id': '', 'name': _nameController.text.trim()},
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
