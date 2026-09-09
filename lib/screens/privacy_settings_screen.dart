import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/reminder_service.dart';
import '../widgets/vitalis_card.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _enabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      _enabled = doc.data()?['notificationsEnabled'] != false;
    } catch (_) {
      _enabled = true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(bool value) async {
    final previous = _enabled;
    setState(() => _enabled = value);
    try {
      await AuthService().updateProfile(notificationsEnabled: value);
      if (value) {
        await ReminderService.instance.sync();
      } else {
        await ReminderService.instance.cancelAllLocal();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _enabled = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update reminders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Text(
                  'Visit notes and payment status are visible to hospital admin. Other patients cannot open your file.',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 16),
                VitalisCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Visit reminders'),
                    subtitle: const Text(
                      'Alert the day before and on the day of your appointment. You can reschedule or cancel from Settings.',
                    ),
                    value: _enabled,
                    onChanged: _save,
                  ),
                ),
              ],
            ),
    );
  }
}
