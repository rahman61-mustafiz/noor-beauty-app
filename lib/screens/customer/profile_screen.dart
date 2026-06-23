import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  String? _email;
  String? _birthday;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final storage = await StorageService.getInstance();
    final prefs   = await SharedPreferences.getInstance();
    setState(() {
      _darkMode         = storage.getDarkMode();
      _email            = prefs.getString('profile_email') ?? '';
      _birthday         = prefs.getString('profile_birthday') ?? '';
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _saveEmail(String v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_email', v);
    setState(() => _email = v);
  }

  Future<void> _saveBirthday(String v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_birthday', v);
    setState(() => _birthday = v);
  }

  Future<void> _toggleDarkMode(bool v) async {
    final storage = await StorageService.getInstance();
    await storage.setDarkMode(v);
    setState(() => _darkMode = v);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restart app to apply theme change')),
      );
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Sign Out')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthService>().logout();
      Navigator.pushReplacementNamed(context, '/phone-login');
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data — bookings, history, and preferences.\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final auth = context.read<AuthService>();
    final deleted = await auth.deleteAccount();
    if (!mounted) return;

    if (deleted) {
      Navigator.pushReplacementNamed(context, '/phone-login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Could not delete account'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Profile picture ──────────────────────────────────────────────────────

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Remove photo',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeProfileImage();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', picked.path);
      if (mounted) setState(() => _profileImagePath = picked.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load image. Please try again.')),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    if (mounted) setState(() => _profileImagePath = null);
  }

  // ── Email edit dialog ────────────────────────────────────────────────────

  void _showEmailEdit() {
    final ctrl = TextEditingController(text: _email);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Email Address'),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email (optional)',
            hintText: 'example@email.com',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary),
            onPressed: () async {
              await _saveEmail(ctrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Birthday date picker ─────────────────────────────────────────────────

  Future<void> _pickBirthday() async {
    DateTime initial = DateTime(1995, 1, 1);
    if (_birthday != null && _birthday!.isNotEmpty) {
      try { initial = DateTime.parse(_birthday!); } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, onPrimary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      await _saveBirthday(
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  String _formatBirthday(String? raw) {
    if (raw == null || raw.isEmpty) return 'Not set';
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return 'Not set';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: _profileImagePath != null
                        ? ClipOval(
                            child: Image.file(
                              File(_profileImagePath!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                            ),
                          )
                        : Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.name ?? 'Guest',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user?.phone ?? 'No phone',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 28),

            // ── Account info ───────────────────────────────────────────────
            _sectionHeader('Account Info'),
            _tileCard(Icons.phone_outlined, 'Phone',
                user?.phone ?? 'Not set', null),
            _tileCard(
              Icons.email_outlined, 'Email',
              (_email?.isNotEmpty == true) ? _email! : 'Tap to add (optional)',
              _showEmailEdit,
              trailing: const Text('Optional',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
            _tileCard(
              Icons.cake_outlined, 'Birthday',
              _formatBirthday(_birthday),
              _pickBirthday,
              trailing: const Text('Optional',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),

            // ── Settings ───────────────────────────────────────────────────
            _sectionHeader('Settings'),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                value: _darkMode,
                activeColor: AppColors.primary,
                onChanged: _toggleDarkMode,
              ),
            ),
            const SizedBox(height: 24),

            // ── Sign out ───────────────────────────────────────────────────
            CustomButton(
              label: 'Sign Out',
              variant: ButtonVariant.danger,
              icon: Icons.logout,
              onPressed: _logout,
            ),
            const SizedBox(height: 16),

            // ── Account deletion (App Store / Play Store requirement) ─────
            _sectionHeader('Account'),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.delete_forever_outlined,
                    color: AppColors.error),
                title: const Text('Delete my account',
                    style: TextStyle(color: AppColors.error)),
                subtitle: const Text(
                    'Permanently delete your account and all personal data',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: _deleteAccount,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
        ),
      );

  Widget _tileCard(IconData icon, String title, String subtitle,
      VoidCallback? onTap,
      {Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
