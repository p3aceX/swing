import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import 'coach_provider.dart';

class InviteCoachSheet extends ConsumerStatefulWidget {
  const InviteCoachSheet({super.key});

  @override
  ConsumerState<InviteCoachSheet> createState() => _InviteCoachSheetState();
}

class _InviteCoachSheetState extends ConsumerState<InviteCoachSheet> {
  final _phoneCtrl = TextEditingController();
  bool _isHeadCoach = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      showSnack(context, 'Enter a valid phone number');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(coachesProvider.notifier).invite({
        'phone': phone,
        'isHeadCoach': _isHeadCoach,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to invite coach');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Invite Coach', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Coach Phone Number',
              prefixIcon: Icon(Icons.phone_iphone_outlined),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Head Coach'),
            value: _isHeadCoach,
            onChanged: (v) => setState(() => _isHeadCoach = v),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _invite,
            child: _isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Invite Coach'),
          ),
        ],
      ),
    );
  }
}
