import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_user.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'admin_analytics_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_services_screen.dart';
import 'admin_staff_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AdminDashboardData? _dashboard;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadDashboard();
  }

  void _checkSession() {
    final auth = context.read<AuthService>();
    if (!auth.checkAdminSession()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/admin-login');
      });
    }
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.instance.getAdminDashboard();
      setState(() {
        _dashboard = AdminDashboardData.fromJson(
          response['data'] as Map<String, dynamic>? ?? response,
        );
      });
    } catch (_) {
      // Show placeholder data when API unavailable
      setState(() {
        _dashboard = const AdminDashboardData(
          todayBookings: 8,
          upcomingBookings: 24,
          totalCustomers: 156,
          recentBookings: [],
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthService>().adminLogout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Session timeout check on rebuild
    if (!auth.checkAdminSession()) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      _DashboardHome(
        dashboard: _dashboard,
        isLoading: _isLoading,
        onRefresh: _loadDashboard,
      ),
      const AdminBookingsScreen(),
      const AdminStaffScreen(),
      const AdminServicesScreen(),
      const AdminCustomersScreen(),
      const AdminReviewsScreen(),
      const AdminAnalyticsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: _buildDrawer(),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex > 0 ? 1 : 0,
        onDestinationSelected: (i) {
          if (i == 0) {
            setState(() => _selectedIndex = 0);
          } else {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final menuItems = [
      (Icons.dashboard, 'Dashboard', 0),
      (Icons.calendar_month, 'Bookings', 1),
      (Icons.people, 'Staff', 2),
      (Icons.spa, 'Services', 3),
      (Icons.person_search, 'Customers', 4),
      (Icons.star, 'Reviews', 5),
      (Icons.analytics, 'Analytics', 6),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.read<AuthService>().currentAdmin?.email ?? 'Admin',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...menuItems.map((item) {
            return ListTile(
              leading: Icon(item.$1, color: AppColors.primary),
              title: Text(item.$2),
              selected: _selectedIndex == item.$3,
              onTap: () {
                setState(() => _selectedIndex = item.$3);
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.timer_outlined, color: AppColors.warning),
            title: const Text('Session: 30 min timeout'),
            subtitle: const Text('Activity resets timer'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Salon Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Salon Hours'),
              subtitle: Text(
                '${AppConstants.defaultSalonOpen} – ${AppConstants.defaultSalonClose}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notification Preferences'),
              subtitle: const Text('Booking alerts, reminders'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final AdminDashboardData? dashboard;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _DashboardHome({
    required this.dashboard,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = dashboard!;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Today',
                    value: '${data.todayBookings}',
                    subtitle: 'Bookings',
                    icon: Icons.today,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Next 7 Days',
                    value: '${data.upcomingBookings}',
                    subtitle: 'Upcoming',
                    icon: Icons.upcoming,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Total Customers',
              value: '${data.totalCustomers}',
              subtitle: 'Registered',
              icon: Icons.people,
              color: AppColors.accent,
              fullWidth: true,
            ),
            const SizedBox(height: 28),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'New Booking',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.person_add_outlined,
                  label: 'Add Staff',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.spa_outlined,
                  label: 'Services',
                  onTap: () {},
                ),
              ],
            ),
            if (data.recentBookings.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text(
                'Recent Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...data.recentBookings.map((b) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.event, color: AppColors.secondary, size: 20),
                      ),
                      title: Text(b.customerName),
                      subtitle: Text('${b.serviceName} • ${b.stylistName}'),
                      trailing: Chip(
                        label: Text(
                          b.status,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
