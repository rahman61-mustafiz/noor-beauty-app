import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

class AdminMfaScreen extends StatefulWidget {
  const AdminMfaScreen({super.key});

  @override
  State<AdminMfaScreen> createState() => _AdminMfaScreenState();
}

class _AdminMfaScreenState extends State<AdminMfaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _showQr = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final success = await auth.verifyMfa(code: _codeController.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid verification code'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final mfaSecret = auth.pendingMfaSecret;
    final email = auth.currentAdmin?.email ?? 'admin@noorbeauty.com';

    String? qrData;
    if (mfaSecret != null) {
      qrData = auth.generateMfaQrUri(secret: mfaSecret, email: email);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter Verification Code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Open Google Authenticator or Authy and enter the 6-digit code',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 12,
                      ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: Validators.validateMfaCode,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Verify & Continue',
                  isLoading: auth.isLoading,
                  onPressed: _verify,
                ),
                if (qrData != null) ...[
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => setState(() => _showQr = !_showQr),
                    icon: Icon(_showQr ? Icons.qr_code : Icons.qr_code_scanner),
                    label: Text(_showQr ? 'Hide QR Code' : 'Show Setup QR Code'),
                  ),
                  if (_showQr) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Secret: $mfaSecret',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scan with Google Authenticator or Authy',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    auth.adminLogout();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel & Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
