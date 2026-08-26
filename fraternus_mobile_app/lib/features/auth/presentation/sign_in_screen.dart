import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../providers/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // On success, the router's redirect (re-evaluated via
      // GoRouterRefreshStream watching authStateChanges) takes over
      // navigation to /today — nothing to do here.
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Could not sign in. Check your email and password and try again.',
        );
      }
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
          // The only route that ever pushes here is the welcome screen's
          // "Sign In" button (see app/router/app_router.dart), so a plain
          // pop always lands back there — no wizard-style "which auth
          // route am I really under" complication like SignUpAccountScreen
          // has to account for.
          ScreenHeader(title: 'Sign In', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Heading('Welcome Back'),
                const SizedBox(height: 32),
                const FieldLabel(label: 'Email'),
                FormTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const FieldLabel(label: 'Password'),
                FormTextField(
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: FraternusTypography.small(
                      color: FraternusColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Button(
                  label: _isSubmitting ? 'Signing In…' : 'Sign In',
                  fullWidth: true,
                  disabled: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Button(
                  label: "Forgot Password",
                  fullWidth: true,
                  variant: .ghost,
                  onPressed: () => context.push(RoutePaths.forgotPassword),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
