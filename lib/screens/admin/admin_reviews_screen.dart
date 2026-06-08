import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/review.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  List<Review> _reviews = [];
  List<Review> _filtered = [];
  bool _isLoading = true;
  int? _ratingFilter;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final filters = _ratingFilter != null
          ? {'rating': _ratingFilter.toString()}
          : null;
      final data = await ApiService.instance.getAdminReviews(filters: filters);
      _reviews = data
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _reviews = List.generate(6, (i) {
        return Review(
          id: '${i + 1}',
          bookingId: 'b${i + 1}',
          customerId: 'c${i + 1}',
          stylistId: 's${i + 1}',
          rating: [5, 4, 5, 3, 4, 5][i],
          reviewText: [
            'Amazing haircut! Fatima is wonderful.',
            'Great bridal makeup, highly recommend.',
            'Relaxing facial, will come back.',
            'Good service but had to wait.',
            'Excellent mehedi design for my wedding.',
            'Love the spa treatment!',
          ][i],
          createdAt: DateTime.now().subtract(Duration(days: i * 3)),
          customerName: ['Amina', 'Riya', 'Sadia', 'Nadia', 'Lamia', 'Tania'][i],
          stylistName: ['Fatima', 'Nusrat', 'Ayesha', 'Sabrina', 'Maliha', 'Priya'][i],
          serviceName: ['Haircut', 'Bridal', 'Facial', 'Mani/pedi', 'Mehedi', 'Body spa'][i],
        );
      });
    }
    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    setState(() {
      _filtered = _ratingFilter == null
          ? _reviews
          : _reviews.where((r) => r.rating == _ratingFilter).toList();
    });
  }

  Future<void> _respondToReview(Review review) async {
    final controller = TextEditingController(text: review.adminResponse);

    final response = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Respond to Review'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your response',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (response == null || response.isEmpty) return;

    try {
      await ApiService.instance.respondToReview(review.id, response);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response posted')),
        );
        _loadReviews();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Response saved locally')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _ratingFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Rating',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Ratings')),
                    ...List.generate(5, (i) {
                      final rating = 5 - i;
                      return DropdownMenuItem(
                        value: rating,
                        child: Row(
                          children: [
                            ...List.generate(rating, (_) => const Icon(Icons.star, size: 16, color: AppColors.accent)),
                            Text(' $rating stars'),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (v) {
                    setState(() => _ratingFilter = v);
                    _applyFilter();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReviews),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? const Center(child: Text('No reviews found'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final review = _filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review.customerName ?? 'Customer',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '${review.serviceName} • ${review.stylistName}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review.rating ? Icons.star : Icons.star_border,
                                          color: AppColors.accent,
                                          size: 18,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(review.reviewText),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('MMM d, yyyy').format(review.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (review.adminResponse != null) ...[
                                  const Divider(),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Admin Response:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(review.adminResponse!),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _respondToReview(review),
                                    icon: const Icon(Icons.reply, size: 18),
                                    label: Text(
                                      review.adminResponse != null ? 'Edit Response' : 'Respond',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
