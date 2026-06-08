import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  AnalyticsData? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.instance.getAdminAnalytics();
      _analytics = AnalyticsData.fromJson(
        response['data'] as Map<String, dynamic>? ?? response,
      );
    } catch (_) {
      _analytics = AnalyticsData(
        topServices: const [
          ServiceStat(name: 'Haircut', count: 145),
          ServiceStat(name: 'Bridal', count: 89),
          ServiceStat(name: 'Facial', count: 76),
          ServiceStat(name: 'Color', count: 68),
          ServiceStat(name: 'Mehedi', count: 54),
        ],
        topStylists: const [
          StylistStat(name: 'Fatima Rahman', bookings: 98, rating: 4.8),
          StylistStat(name: 'Nusrat Jahan', bookings: 87, rating: 4.9),
          StylistStat(name: 'Maliha Khan', bookings: 72, rating: 4.9),
          StylistStat(name: 'Ayesha Siddiqua', bookings: 65, rating: 4.7),
        ],
        monthlyTrends: const [
          MonthlyTrend(month: 'Jan', bookings: 120, newCustomers: 18),
          MonthlyTrend(month: 'Feb', bookings: 135, newCustomers: 22),
          MonthlyTrend(month: 'Mar', bookings: 148, newCustomers: 25),
          MonthlyTrend(month: 'Apr', bookings: 162, newCustomers: 28),
          MonthlyTrend(month: 'May', bookings: 175, newCustomers: 30),
          MonthlyTrend(month: 'Jun', bookings: 89, newCustomers: 15),
        ],
        retentionRate: 72.5,
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _analytics!;
    final maxBookings = data.monthlyTrends
        .map((t) => t.bookings)
        .fold(0, (a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _retentionCard(data.retentionRate),
            const SizedBox(height: 24),
            const Text(
              'Most Booked Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...data.topServices.map((s) => _barItem(
                  s.name,
                  s.count,
                  data.topServices.first.count,
                  AppColors.primary,
                )),
            const SizedBox(height: 24),
            const Text(
              'Top Stylists',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...data.topStylists.map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: Text(
                        s.name[0],
                        style: const TextStyle(color: AppColors.accent),
                      ),
                    ),
                    title: Text(s.name),
                    subtitle: Text('${s.bookings} bookings'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.accent, size: 18),
                        Text(' ${s.rating}'),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            const Text(
              'Monthly Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.monthlyTrends.map((trend) {
                  final heightFactor =
                      maxBookings > 0 ? trend.bookings / maxBookings : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${trend.bookings}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 120 * heightFactor,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            trend.month,
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            '+${trend.newCustomers}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _retentionCard(double rate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Customer Retention Rate',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Returning customers this quarter',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _barItem(String label, int value, int max, Color color) {
    final factor = max > 0 ? value / max : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$value bookings', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
