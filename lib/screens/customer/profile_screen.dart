import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/stylist.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/storage_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stylist_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _favorites = [];
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _favorites = storage.getFavoriteStylists();
      _darkMode = storage.getDarkMode();
    });
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated locally')),
      );
    }
  }

  Future<void> _toggleFavorite(Stylist stylist) async {
    final storage = await StorageService.getInstance();
    await storage.toggleFavoriteStylist(stylist.id);
    setState(() => _favorites = storage.getFavoriteStylists());
  }

  Future<void> _toggleDarkMode(bool value) async {
    final storage = await StorageService.getInstance();
    await storage.setDarkMode(value);
    setState(() => _darkMode = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restart app to apply theme change'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthService>().logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final booking = context.watch<BookingService>();
    final user = auth.currentUser;

    final favoriteStylists = booking.stylists
        .where((s) => _favorites.contains(s.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Guest',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (user != null && !user.emailVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(Icons.warning_amber, size: 16),
                  label: const Text('Email not verified'),
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                ),
              ),
            const SizedBox(height: 24),
            _settingsTile(Icons.phone, 'Phone', user?.phone ?? 'Not set'),
            _settingsTile(Icons.location_on, 'Location', AppConstants.salonLocation),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark theme'),
              value: _darkMode,
              activeColor: AppColors.primary,
              onChanged: _toggleDarkMode,
            ),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favorite Stylists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('${_favorites.length} saved'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (favoriteStylists.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tap the heart on a stylist during booking to save favorites',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteStylists.length,
                  itemBuilder: (context, index) {
                    final stylist = favoriteStylists[index];
                    return StylistCard(
                      stylist: stylist,
                      showFavorite: true,
                      isFavorite: true,
                      onFavoriteToggle: () => _toggleFavorite(stylist),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'All Stylists',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: booking.stylists.length,
                itemBuilder: (context, index) {
                  final stylist = booking.stylists[index];
                  return StylistCard(
                    stylist: stylist,
                    showFavorite: true,
                    isFavorite: _favorites.contains(stylist.id),
                    onFavoriteToggle: () => _toggleFavorite(stylist),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Sign Out',
              variant: ButtonVariant.danger,
              icon: Icons.logout,
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}
