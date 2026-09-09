import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../services/doctor_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/network_avatar.dart';
import '../../widgets/vitalis_button.dart';
import '../../widgets/vitalis_card.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    DoctorService.instance.stripStockPhotos();
  }

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      await DoctorService.instance.stripStockPhotos();
      final added = await DoctorService.instance.seedCatalog();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added == 0
              ? 'Doctors already exist. Fake stock photos were cleared.'
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
    final about = TextEditingController(text: data['about'] ?? '');
    var available = data['availableToday'] == true;
    var imageUrl = '${data['image'] ?? ''}';
    Uint8List? pickedBytes;

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
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: saving
                              ? null
                              : () async {
                                  final source = await showModalBottomSheet<String>(
                                    context: ctx,
                                    showDragHandle: true,
                                    builder: (sheet) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.photo_library_rounded),
                                              title: const Text(
                                                  'Choose from gallery'),
                                              onTap: () =>
                                                  Navigator.pop(sheet, 'gallery'),
                                            ),
                                            if (!kIsWeb)
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.photo_camera_rounded),
                                                title: const Text('Take a photo'),
                                                onTap: () =>
                                                    Navigator.pop(sheet, 'camera'),
                                              ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                  if (source == null) return;
                                  try {
                                    final bytes = await ImageUploadService.instance
                                        .pickPhoto(camera: source == 'camera');
                                    if (bytes == null) return;
                                    setModal(() => pickedBytes = bytes);
                                  } catch (e) {
                                    if (!ctx.mounted) return;
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(content: Text('$e')),
                                    );
                                  }
                                },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              if (pickedBytes != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.memory(
                                    pickedBytes!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                NetworkAvatar(url: imageUrl, size: 80, radius: 40),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(ctx).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Tap the photo to upload a doctor picture',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                          controller: name,
                          decoration: const InputDecoration(labelText: 'Name')),
                      const SizedBox(height: 8),
                      TextField(
                          controller: specialty,
                          decoration:
                              const InputDecoration(labelText: 'Specialty')),
                      const SizedBox(height: 8),
                      TextField(
                          controller: location,
                          decoration:
                              const InputDecoration(labelText: 'Location')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: experience,
                        decoration:
                            const InputDecoration(labelText: 'Experience'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: fee,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fee (Rs)'),
                      ),
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
                                  final id = await DoctorService.instance.upsert(
                                    doc?.id,
                                    {
                                      'name': name.text.trim(),
                                      'specialty': specialty.text.trim(),
                                      'location': location.text.trim(),
                                      'experience': experience.text.trim(),
                                      'rating': data['rating'] ?? 4.5,
                                      'reviews': data['reviews'] ?? 0,
                                      'patients': data['patients'] ?? '0',
                                      'fee': num.tryParse(fee.text.trim()) ?? 0,
                                      'image': imageUrl,
                                      'availableToday': available,
                                      'about': about.text.trim(),
                                    },
                                  );
                                  if (pickedBytes != null) {
                                    imageUrl = await ImageUploadService.instance
                                        .uploadDoctorPhoto(id, pickedBytes!);
                                    await DoctorService.instance.upsert(id, {
                                      'name': name.text.trim(),
                                      'specialty': specialty.text.trim(),
                                      'location': location.text.trim(),
                                      'experience': experience.text.trim(),
                                      'rating': data['rating'] ?? 4.5,
                                      'reviews': data['reviews'] ?? 0,
                                      'patients': data['patients'] ?? '0',
                                      'fee':
                                          num.tryParse(fee.text.trim()) ?? 0,
                                      'image': imageUrl,
                                      'availableToday': available,
                                      'about': about.text.trim(),
                                    });
                                  }
                                  if (ctx.mounted) Navigator.pop(ctx);
                                } catch (e) {
                                  if (!ctx.mounted) return;
                                  setModal(() => saving = false);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Could not save doctor: $e')),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                ),
                IconButton(
                  onPressed: _seeding ? null : _seed,
                  tooltip: 'Seed sample roster if empty',
                  icon: _seeding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: cs.onSurface)),
                          const SizedBox(height: 8),
                          const Text(
                              'Tap the sparkle icon to load a starter roster, or add one.'),
                          const SizedBox(height: 16),
                          VitalisButton(
                              label: 'Load starter doctors', onPressed: _seed),
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
                          NetworkAvatar(
                            url: '${data['image'] ?? ''}',
                            size: 52,
                            radius: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data['name']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface)),
                                Text(
                                    '${data['specialty']} · ${data['location']}',
                                    style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '${Formatters.fee(data['fee'])} · ${data['availableToday'] == true ? 'Available' : 'Busy'}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface),
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
                            icon: Icon(Icons.delete_outline_rounded,
                                color: cs.error),
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
