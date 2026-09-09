import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../widgets/vitalis_button.dart';
import '../../widgets/vitalis_card.dart';

class AdminReviewsScreen extends StatelessWidget {
  const AdminReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: StreamBuilder<List<VisitReview>>(
        stream: ReviewService.instance.watchAllForAdmin(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final waiting = items.where((r) => !r.hasReply).length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient feedback',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        waiting == 0
                            ? 'Reviews from completed visits. Reply when a patient needs a follow-up.'
                            : '$waiting review${waiting == 1 ? '' : 's'} waiting for a hospital reply.',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              if (snapshot.hasError)
                const SliverFillRemaining(
                  child: Center(child: Text('Could not load reviews.')),
                )
              else if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No reviews yet. Patients are asked after their visit time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _ReviewTile(review: items[index]);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final VisitReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _reply(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.patientName,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                review.hasReply ? 'REPLIED' : 'NEW',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: review.hasReply
                      ? const Color(0xFF059669)
                      : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.doctorName,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: const Color(0xFFD97706),
              ),
            ),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(color: cs.onSurface, height: 1.4),
            ),
          ],
          if (review.hasReply) ...[
            const SizedBox(height: 10),
            Text(
              'Reply: ${review.reply}',
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            Formatters.relativeTime(review.createdAt),
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _reply(BuildContext context) async {
    final controller = TextEditingController(text: review.reply);
    var saving = false;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (ctx, setModal) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reply to ${review.patientName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment.isEmpty
                          ? '${review.rating}/5 for ${review.doctorName}'
                          : review.comment,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      maxLength: 400,
                      decoration: const InputDecoration(
                        labelText: 'Hospital reply',
                        hintText:
                            'Thank them, or say you will look into the issue.',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    VitalisButton(
                      label: review.hasReply ? 'Update reply' : 'Send reply',
                      isLoading: saving,
                      onPressed: saving
                          ? null
                          : () async {
                              setModal(() => saving = true);
                              try {
                                await ReviewService.instance.reply(
                                  review: review,
                                  message: controller.text,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                if (!ctx.mounted) return;
                                setModal(() => saving = false);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('$e')),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }
}
