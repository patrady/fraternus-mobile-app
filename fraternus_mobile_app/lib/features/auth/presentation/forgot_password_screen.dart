import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).resetPasswordForEmail(_emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Something went wrong. Try again in a moment.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Reset Password', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (_sent) ...[
                  const BodyText(
                    "If an account exists for that email, we've sent a link to reset your password.",
                  ),
                ] else ...[
                  const BodyText("Enter your account's email and we'll send you a reset link."),
                  const SizedBox(height: 24),
                  const FieldLabel(label: 'Email'),
                  FormTextField(controller: _emailController, keyboardType: TextInputType.emailAddress),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorMessage!, style: FraternusTypography.small(color: FraternusColors.error)),
                  ],
                  const SizedBox(height: 24),
                  Button(
                    label: _isSubmitting ? 'Sending…' : 'Send Reset Link',
                    fullWidth: true,
                    disabled: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
