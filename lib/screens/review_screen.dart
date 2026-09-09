import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';

class ReviewScreen extends StatefulWidget {
  final Appointment appointment;

  const ReviewScreen({super.key, required this.appointment});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _comment = TextEditingController();
  VisitReview? _existing;
  int _rating = 5;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final existing =
        await ReviewService.instance.getForAppointment(widget.appointment.id);
    if (!mounted) return;
    setState(() {
      _existing = existing;
      if (existing != null) {
        _rating = existing.rating;
        _comment.text = existing.comment;
      }
      _loading = false;
    });
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await ReviewService.instance.submit(
        appointment: widget.appointment,
        rating: _rating,
        comment: _comment.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you. The hospital can see your review.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locked = _existing != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Visit feedback')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                VitalisCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appointment.doctorName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.appointment.date} · ${widget.appointment.time}',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locked
                            ? 'Your rating'
                            : 'How was the service with this doctor?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return IconButton(
                            onPressed: locked
                                ? null
                                : () => setState(() => _rating = star),
                            icon: Icon(
                              star <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFD97706),
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _comment,
                        enabled: !locked,
                        maxLines: 4,
                        maxLength: 400,
                        decoration: InputDecoration(
                          labelText: locked
                              ? 'Your comment'
                              : 'Anything we should know? (optional)',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_existing?.hasReply == true) ...[
                  const SizedBox(height: 16),
                  VitalisCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hospital reply',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _existing!.reply,
                          style: TextStyle(
                            color: cs.onSurface,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!locked) ...[
                  const SizedBox(height: 20),
                  VitalisButton(
                    label: 'Send review',
                    isLoading: _saving,
                    onPressed: _saving ? null : _submit,
                  ),
                ],
              ],
            ),
    );
  }
}
