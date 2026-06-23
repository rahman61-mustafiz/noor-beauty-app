import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _resending = false;
  int _secondsLeft = AppConstants.otpResendCooldownSeconds;
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
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final result = await auth.verifyOtp(_phone, _ctrl.text.trim());
    if (!mounted) return;

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
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final auth = context.read<AuthService>();
    final ok = await auth.requestOtp(_phone);
    if (!mounted) return;
    setState(() => _resending = false);

    if (ok) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New code sent!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Could not resend code'),
          backgroundColor: AppColors.error,
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
    final auth = context.watch<AuthService>();
    final maskedPhone = _phoneLoaded && _phone.length > 5
        ? '${_phone.substring(0, _phone.length - 4)}****'
        : (_phoneLoaded ? _phone : '');

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Enter the code',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a verification code to\n$maskedPhone',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code manually from your SMS.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 12,
                      ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                  validator: Validators.validateOtp,
                  onChanged: (v) {
                    if (v.length == 6) _verify();
                  },
                ),
                const SizedBox(height: 28),
                CustomButton(
                  label: 'Verify',
                  isLoading: auth.isLoading,
                  onPressed: _verify,
                ),
                const SizedBox(height: 20),
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          'Resend code in ${_secondsLeft}s',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : TextButton(
                          onPressed: _resending ? null : _resend,
                          child: _resending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Resend code'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
