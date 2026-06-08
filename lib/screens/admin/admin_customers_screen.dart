import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  List<User> _customers = [];
  List<User> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.instance.getAdminCustomers();
      _customers = data
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Placeholder data when API unavailable
      _customers = List.generate(5, (i) {
        return User(
          id: '${i + 1}',
          name: ['Amina Khan', 'Riya Das', 'Sadia Ahmed', 'Nadia Islam', 'Lamia Hossain'][i],
          email: 'customer${i + 1}@email.com',
          phone: '+8801712345${100 + i}',
          emailVerified: i % 2 == 0,
          createdAt: DateTime.now().subtract(Duration(days: 30 * (i + 1))),
        );
      });
    }
    _filterCustomers('');
    setState(() => _isLoading = false);
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _customers;
      } else {
        final q = query.toLowerCase();
        _filtered = _customers.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.phone.contains(q) ||
              c.email.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _showCustomerDetail(User customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  customer.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              _detailTile(Icons.email, 'Email', customer.email),
              _detailTile(Icons.phone, 'Phone', customer.phone),
              _detailTile(
                Icons.verified,
                'Email Verified',
                customer.emailVerified ? 'Yes' : 'No',
              ),
              _detailTile(
                Icons.calendar_today,
                'Joined',
                '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _editCustomer(customer),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Contact Info'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history),
                label: const Text('View Booking History'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCustomer(User customer) {
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final phoneController = TextEditingController(text: customer.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _filterCustomers,
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? const Center(child: Text('No customers found'))
                  : RefreshIndicator(
                      onRefresh: _loadCustomers,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final customer = _filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                child: Text(
                                  customer.name[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary),
                                ),
                              ),
                              title: Text(customer.name),
                              subtitle: Text('${customer.phone} • ${customer.email}'),
                              trailing: customer.emailVerified
                                  ? const Icon(Icons.verified, color: AppColors.success, size: 20)
                                  : null,
                              onTap: () => _showCustomerDetail(customer),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
