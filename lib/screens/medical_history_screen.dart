import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  bool _loading = true;
  bool _saving = false;

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
      final data = doc.data() ?? {};
      _allergies.text = data['allergies'] as String? ?? '';
      _conditions.text = data['conditions'] as String? ?? '';
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final name = await AuthService().currentPatientName();
      await AuthService().updateProfile(
        name: name,
        allergies: _allergies.text.trim(),
        conditions: _conditions.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health notes saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _allergies.dispose();
    _conditions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Health notes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Text(
                  'These notes stay on your account so the hospital team can see what matters.',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 20),
                VitalisCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _allergies,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Allergies',
                          hintText: 'e.g. Penicillin, peanuts',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _conditions,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Conditions / notes',
                          hintText: 'e.g. Asthma, previous surgery',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                VitalisButton(label: 'Save notes', isLoading: _saving, onPressed: _save),
              ],
            ),
    );
  }
}
