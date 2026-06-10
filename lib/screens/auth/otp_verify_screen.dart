import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _ctrl = TextEditingController();
  bool _submitting = false;
  bool _resending  = false;
  int  _secondsLeft = AppConstants.otpResendCooldownSeconds;
  late String _phone;
  bool _phoneLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_phoneLoaded) {
      _phone = ModalRoute.of(context)!.settings.arguments as String;
      _phoneLoaded = true;
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _secondsLeft = AppConstants.otpResendCooldownSeconds);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft--);
      return _secondsLeft > 0;
    });
  }

  Future<void> _verify() async {
    final code = _ctrl.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full OTP code')),
      );
      return;
    }
    setState(() => _submitting = true);
    final auth   = context.read<AuthService>();
    final result = await auth.verifyOtp(_phone, code);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.success) {
      if (result.isNewUser) {
        Navigator.pushReplacementNamed(context, '/name-setup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid code. Please try again.'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    await context.read<AuthService>().requestOtp(_phone);
    if (!mounted) return;
    setState(() => _resending = false);
    _startTimer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('New code sent!')));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = _phoneLoaded && _phone.length > 5
        ? _phone.substring(0, _phone.length - 4) + '****'
        : (_phoneLoaded ? _phone : '');

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Enter the code',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification code to\n' + maskedPhone,
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 12),
                decoration: const InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(
                      letterSpacing: 12, fontSize: 28, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
                onChanged: (v) {
                  if (v.length == 6) _verify();
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _verify,
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
                          'Verify',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Resend code in ' + _secondsLeft.toString() + 's',
                        style: const TextStyle(color: Color(0xFF9E9E9E)),
                      )
                    : TextButton(
                        onPressed: _resending ? null : _resend,
                        child: _resending
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Resend code'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}