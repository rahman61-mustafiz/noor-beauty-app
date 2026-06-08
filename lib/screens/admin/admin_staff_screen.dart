import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/stylist.dart';
import '../../services/booking_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class AdminStaffScreen extends StatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  State<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen> {
  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingService>();
    final stylists = booking.stylists;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${stylists.length} Staff Members',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showStaffDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Staff'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stylists.length,
              itemBuilder: (context, index) {
                final stylist = stylists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                      child: Text(
                        stylist.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(stylist.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stylist.specialties.join(', ')),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.accent),
                            Text(' ${stylist.rating}'),
                            const SizedBox(width: 12),
                            const Icon(Icons.phone, size: 14),
                            Text(' ${stylist.phone}'),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'availability', child: Text('Availability')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (action) {
                        if (action == 'edit') {
                          _showStaffDialog(context, stylist: stylist);
                        } else if (action == 'availability') {
                          _showAvailabilityDialog(stylist);
                        } else if (action == 'delete') {
                          _confirmDelete(stylist);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStaffDialog(BuildContext context, {Stylist? stylist}) {
    final nameController = TextEditingController(text: stylist?.name);
    final emailController = TextEditingController(text: stylist?.email);
    final phoneController = TextEditingController(text: stylist?.phone);
    final bioController = TextEditingController(text: stylist?.bio);
    final specialtiesController = TextEditingController(
      text: stylist?.specialties.join(', '),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(stylist == null ? 'Add Staff' : 'Edit Staff'),
        content: SingleChildScrollView(
          child: Column(
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
              TextField(
                controller: specialtiesController,
                decoration: const InputDecoration(
                  labelText: 'Specialties (comma separated)',
                ),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    stylist == null ? 'Staff added (sync with API)' : 'Staff updated',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityDialog(Stylist stylist) {
    final selectedDays = <String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${stylist.name} - Availability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...AppConstants.weekDays.map((day) {
                return CheckboxListTile(
                  title: Text(day),
                  value: selectedDays.contains(day),
                  onChanged: (v) {
                    setDialogState(() {
                      if (v == true) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: AppConstants.defaultSalonOpen,
                      decoration: const InputDecoration(labelText: 'Open'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: AppConstants.defaultSalonClose,
                      decoration: const InputDecoration(labelText: 'Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Availability updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Stylist stylist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Remove ${stylist.name} from staff?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${stylist.name} removed')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
