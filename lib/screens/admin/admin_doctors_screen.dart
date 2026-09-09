import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../services/doctor_service.dart';
import '../../widgets/vitalis_button.dart';
import '../../widgets/vitalis_card.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  bool _seeding = false;

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      final added = await DoctorService.instance.seedCatalog();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added == 0
              ? 'Doctors already exist. Nothing added.'
              : 'Added $added doctors to the roster.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Future<void> _edit([DocumentSnapshot<Map<String, dynamic>>? doc]) async {
    final data = doc?.data() ?? {};
    final name = TextEditingController(text: data['name'] ?? '');
    final specialty = TextEditingController(text: data['specialty'] ?? '');
    final location = TextEditingController(text: data['location'] ?? '');
    final experience = TextEditingController(text: data['experience'] ?? '5 Years');
    final fee = TextEditingController(text: '${data['fee'] ?? 1500}');
    final image = TextEditingController(text: data['image'] ?? '');
    final about = TextEditingController(text: data['about'] ?? '');
    var available = data['availableToday'] == true;

    try {
      await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        var saving = false;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModal) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc == null ? 'Add doctor' : 'Edit doctor',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: specialty, decoration: const InputDecoration(labelText: 'Specialty')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: location, decoration: const InputDecoration(labelText: 'Location')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: experience,
                        decoration: const InputDecoration(labelText: 'Experience')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: fee,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fee (Rs)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                        controller: image,
                        decoration: const InputDecoration(labelText: 'Photo URL (https)')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: about,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'About'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available today'),
                      value: available,
                      onChanged: (v) => setModal(() => available = v),
                    ),
                    VitalisButton(
                      label: 'Save',
                      isLoading: saving,
                      onPressed: saving
                          ? null
                          : () async {
                              setModal(() => saving = true);
                              try {
                                await DoctorService.instance.upsert(doc?.id, {
                                  'name': name.text.trim(),
                                  'specialty': specialty.text.trim(),
                                  'location': location.text.trim(),
                                  'experience': experience.text.trim(),
                                  'rating': data['rating'] ?? 4.5,
                                  'reviews': data['reviews'] ?? 0,
                                  'patients': data['patients'] ?? '0',
                                  'fee': num.tryParse(fee.text.trim()) ?? 0,
                                  'image': image.text.trim(),
                                  'availableToday': available,
                                  'about': about.text.trim(),
                                });
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                if (!ctx.mounted) return;
                                setModal(() => saving = false);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Could not save doctor: $e')),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    } finally {
      name.dispose();
      specialty.dispose();
      location.dispose();
      experience.dispose();
      fee.dispose();
      image.dispose();
      about.dispose();
    }
  }

  Future<void> _delete(String id) async {
    try {
      await DoctorService.instance.delete(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete doctor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text('Doctors',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800, color: cs.onSurface)),
                ),
                IconButton(
                  onPressed: _seeding ? null : _seed,
                  tooltip: 'Seed sample roster if empty',
                  icon: _seeding
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_rounded),
                ),
                IconButton(
                  onPressed: () => _edit(),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: DoctorService.instance.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load doctors.',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No doctors yet',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18, color: cs.onSurface)),
                          const SizedBox(height: 8),
                          const Text('Tap the sparkle icon to load a starter roster, or add one.'),
                          const SizedBox(height: 16),
                          VitalisButton(label: 'Load starter doctors', onPressed: _seed),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    return VitalisCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data['name']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800, color: cs.onSurface)),
                                Text('${data['specialty']} · ${data['location']}',
                                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '${Formatters.fee(data['fee'])} · ${data['availableToday'] == true ? 'Available' : 'Busy'}',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _edit(doc),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () => _delete(doc.id),
                            icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
