import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _ctrl    = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your phone number';
    final cleaned = v.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.length < 7) return 'Enter a valid phone number';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final phone = AppConstants.normalizePhone(_ctrl.text.trim());
    final auth  = context.read<AuthService>();
    final ok    = await auth.requestOtp(phone);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.pushNamed(context, '/otp-verify', arguments: phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to send OTP. Try again.'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Beauty & Wellness, Dhaka',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                ),
                const Spacer(flex: 2),
                const Text(
                  'Enter your phone number',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We'll send you a one-time code to verify your number.",
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                  ],
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '01XXXXXXXXX  or  +1...',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: _validate,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BD numbers (01...) are auto-formatted. For other countries include the country code (+44, +1, etc.).',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          )
                        : const Text(
                            'Send Code',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
