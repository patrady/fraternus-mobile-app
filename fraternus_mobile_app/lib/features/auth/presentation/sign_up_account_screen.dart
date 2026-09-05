import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart' show InputBorder, InputDecoration, TextField;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../../guide/presentation/widgets/fraternus_date_picker.dart';
import '../../profile/presentation/widgets/birthday_field.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/auth_providers.dart';
import '../validation.dart';

/// One child collected on the Kids step, held in memory until the final
/// submit (see `_finish`) — nothing is written to the backend per-child
/// until the whole wizard completes, same as the rest of this screen's
/// fields.
class _ChildDraft {
  const _ChildDraft({
    required this.firstName,
    required this.lastName,
    required this.birthday,
    this.email,
    this.chapterKey,
  });

  final String firstName;
  final String lastName;
  final DateTime birthday;
  final String? email;
  final String? chapterKey;

  String get fullName => '$firstName $lastName';
}

/// The account-creation wizard reached from SignUpRoleScreen's "Parent or
/// Volunteer" choice. Merges what were previously two separate screens
/// (Captain and Guardian signup) into one flow: app_concept.md's Captain
/// and Guardian signup fields are identical except for whether a Captain
/// Member gets created for the signer themselves, which this flow now asks
/// as its own step ("Will you be attending weekly frat nights?") rather
/// than branching at role-selection time.
///
/// Uses Supabase's passwordless-OTP pattern rather than `signUp(email,
/// password)`, to match the mockup's email-then-code-then-password
/// ordering: [AuthRepository.sendEmailOtp] creates the auth user and
/// emails a code, [AuthRepository.verifyEmailOtp] confirms it and
/// establishes a session, then [AuthRepository.setPassword] sets the
/// password on that now-authenticated session. Because a session exists
/// partway through this flow (right after step 2 of 7) — before the
/// wizard has actually finished — the router's redirect explicitly
/// exempts this wizard from its "signed in -> kick to /today" rule while
/// [signUpWizardActiveProvider] is true (see that provider's doc comment
/// and app/router/app_router.dart), so this screen isn't yanked away from
/// underneath the user. That flag is flipped off again wherever this
/// screen is actually left — `_goBack`'s step-0 case and the finished
/// step's "Let's Get Started" button below.
///
/// First/last name, chapter/birthday, and any kids are all held in local
/// state and only written to the backend once, from the Finished step's
/// "Let's Get Started" button (`_finishWizard`) — profile completion isn't
/// itself step-by-step the way the auth steps are, and deferring every
/// write this far means backing up anywhere in the wizard (including
/// Finished->Kids) never mutates a record the user hasn't actually
/// committed to yet.
class SignUpAccountScreen extends ConsumerStatefulWidget {
  const SignUpAccountScreen({super.key});

  @override
  ConsumerState<SignUpAccountScreen> createState() => _SignUpAccountScreenState();
}

/// Static per-step config — one entry per wizard step, in step order, so
/// `_WizardStepConfig.forStep`'s back-button rule reads as a single
/// explicit table instead of a `_step != 2 && _step != 3`-style
/// conditional scattered through the state class. Each step subclasses
/// this to also own how its own body widget (`buildStep`) and footer
/// action(s) (`buildFooter`) get built, which is what lets
/// `_SignUpAccountScreenState._buildStep`/`_buildFooter` each collapse
/// into a single table lookup instead of their own separate switches
/// that would otherwise have to be kept in sync with this one by hand.
abstract class _WizardStepConfig {
  const _WizardStepConfig({required this.step, required this.canGoBack});

  /// Matches _SignUpAccountScreenState._step's own 0-based indexing —
  /// kept as an explicit field (not inferred from list position) so each
  /// entry below is self-describing on its own.
  final int step;

  /// The only back transitions this wizard supports: Email->(previous
  /// screen), Code->Email, Attendance->Name, Kids->Attendance, and
  /// Finished->Kids. Password and Name have no way back — once the code
  /// is verified and a password is set, that auth work is already done
  /// server-side, so unwinding past it wouldn't have anything meaningful
  /// to undo; the user just presses through this pair again if they need
  /// to correct something earlier.
  final bool canGoBack;

  /// Builds this step's body widget from the wizard's live state. [state]
  /// is the screen's own State object — safe to reach into its private
  /// fields/callbacks directly since every subclass below lives in this
  /// same file (Dart privacy is library-scoped, not class-scoped).
  Widget buildStep(_SignUpAccountScreenState state);

  /// Builds this step's pinned-to-the-bottom action(s) — the primary
  /// Continue button, and (Kids only) the secondary "I Don't Have Any
  /// Kids" button alongside it.
  Widget buildFooter(_SignUpAccountScreenState state);

  static const _all = <_WizardStepConfig>[
    _EmailStepConfig(),
    _CodeStepConfig(),
    _PasswordStepConfig(),
    _NameStepConfig(),
    _AttendanceStepConfig(),
    _KidsStepConfig(),
    _FinishedStepConfig(),
  ];

  static _WizardStepConfig forStep(int step) => _all[step];
}

class _EmailStepConfig extends _WizardStepConfig {
  const _EmailStepConfig() : super(step: 0, canGoBack: true);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _EmailStep(controller: state._emailController, errorMessage: state._errorMessage);
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Button(
      label: 'Continue',
      fullWidth: true,
      disabled: state._isSubmitting,
      onPressed: state._sendCode,
    );
  }
}

class _CodeStepConfig extends _WizardStepConfig {
  const _CodeStepConfig() : super(step: 1, canGoBack: true);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _CodeStep(
      email: state._emailController.text.trim(),
      controller: state._codeController,
      errorMessage: state._errorMessage,
      onResend: state._resendCode,
      resendCooldownSeconds: state._resendCooldownSeconds,
    );
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Button(
      label: 'Continue',
      fullWidth: true,
      disabled: state._isSubmitting,
      onPressed: state._verifyCode,
    );
  }
}

class _PasswordStepConfig extends _WizardStepConfig {
  const _PasswordStepConfig() : super(step: 2, canGoBack: false);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _PasswordStep(controller: state._passwordController, errorMessage: state._errorMessage);
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Button(
      label: 'Continue',
      fullWidth: true,
      disabled: state._isSubmitting,
      onPressed: state._submitPassword,
    );
  }
}

class _NameStepConfig extends _WizardStepConfig {
  const _NameStepConfig() : super(step: 3, canGoBack: false);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _NameStep(
      firstNameController: state._firstNameController,
      lastNameController: state._lastNameController,
      firstNameError: state._firstNameError,
      lastNameError: state._lastNameError,
    );
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Button(label: 'Continue', fullWidth: true, onPressed: state._submitName);
  }
}

class _AttendanceStepConfig extends _WizardStepConfig {
  const _AttendanceStepConfig() : super(step: 4, canGoBack: true);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _AttendanceStep(
      attends: state._attends,
      chapterKey: state._chapterKey,
      birthday: state._birthday,
      errorMessage: state._errorMessage,
      onAttendsChanged: state._setAttends,
      onChapterChanged: state._setChapterKey,
      onBirthdayChanged: state._setBirthday,
    );
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Button(label: 'Continue', fullWidth: true, onPressed: state._submitAttendance);
  }
}

class _KidsStepConfig extends _WizardStepConfig {
  const _KidsStepConfig() : super(step: 5, canGoBack: true);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _KidsStep(
      kids: state._kids,
      addingChild: state._addingChild,
      defaultChapterKey: state._chapterKey,
      errorMessage: state._errorMessage,
      onStartAdd: state._startAddingChild,
      onCancelAdd: state._cancelAddingChild,
      onAddChild: state._addChild,
      onRemoveChild: state._removeChild,
    );
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(label: 'Continue', fullWidth: true, disabled: state._isSubmitting, onPressed: state._finish),
        const SizedBox(height: 12),
        Button(
          label: "I Don't Have Any Kids",
          variant: ButtonVariant.ghost,
          fullWidth: true,
          disabled: state._isSubmitting,
          onPressed: state._finish,
        ),
      ],
    );
  }
}

class _FinishedStepConfig extends _WizardStepConfig {
  const _FinishedStepConfig() : super(step: 6, canGoBack: true);

  @override
  Widget buildStep(_SignUpAccountScreenState state) {
    return _FinishedStep(
      fullName: '${state._firstNameController.text.trim()} ${state._lastNameController.text.trim()}',
      email: state._emailController.text.trim(),
      attends: state._attends,
      chapterKey: state._chapterKey,
      kids: state._kids,
      errorMessage: state._errorMessage,
    );
  }

  @override
  Widget buildFooter(_SignUpAccountScreenState state) {
    return Button(
      label: "Let's Get Started",
      fullWidth: true,
      disabled: state._isSubmitting,
      onPressed: state._finishWizard,
    );
  }
}

class _SignUpAccountScreenState extends ConsumerState<SignUpAccountScreen> {
  // `List.length` isn't a const expression, so this can't be `const` like
  // the table it derives from — still a single source of truth, just not
  // a compile-time constant.
  static final _totalSteps = _WizardStepConfig._all.length;

  int _step = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _firstNameError;
  String? _lastNameError;

  bool _attends = true;
  String? _chapterKey;
  DateTime? _birthday;

  final List<_ChildDraft> _kids = [];
  bool _addingChild = false;

  static const _resendCooldownDuration = Duration(seconds: 10);
  int _resendCooldownSeconds = 0;
  Timer? _resendCooldownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  bool get _canGoBack => _WizardStepConfig.forStep(_step).canGoBack;

  void _goBack() {
    if (_step == 0) {
      // Back to the pushed role screen underneath — turn off the
      // wizard-active exemption first (see signUpWizardActiveProvider's
      // doc comment) so the router's normal "signed in -> kick to /today"
      // redirect resumes covering this screen again.
      ref.read(signUpWizardActiveProvider.notifier).set(false);
      context.pop();
      return;
    }
    setState(() {
      _step -= 1;
      _errorMessage = null;
    });
  }

  Future<void> _sendCode() async {
    if (!isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = 'Enter a valid email address');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendEmailOtp(_emailController.text.trim());
      if (mounted) setState(() => _step = 1);
    } catch (e, stackTrace) {
      developer.log('sendEmailOtp failed', name: 'SignUpAccountScreen', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _errorMessage = 'Could not send a code. Try again in a moment.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resendCode() async {
    // Guards against spamming the send-email-otp endpoint (and, per
    // supabase/config.toml's auth.rate_limit, against the account
    // eventually getting rate-limited outright) — belt-and-suspenders
    // alongside the button itself being disabled for the same window.
    if (_resendCooldownSeconds > 0) return;
    _startResendCooldown();
    try {
      await ref.read(authRepositoryProvider).sendEmailOtp(_emailController.text.trim());
    } catch (e, stackTrace) {
      // Resend failures surface the next time the user submits the code —
      // no separate error UI for a background resend tap — but still worth
      // logging so a silent resend failure isn't invisible.
      developer.log('resendCode failed', name: 'SignUpAccountScreen', error: e, stackTrace: stackTrace);
    }
  }

  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() => _resendCooldownSeconds = _resendCooldownDuration.inSeconds);
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldownSeconds -= 1;
        if (_resendCooldownSeconds <= 0) {
          _resendCooldownSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    if (!isValidOtpCode(_codeController.text)) {
      setState(() => _errorMessage = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyEmailOtp(email: _emailController.text.trim(), token: _codeController.text.trim());
      if (mounted) setState(() => _step = 2);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'That code is incorrect or expired.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitPassword() async {
    if (!isValidPassword(_passwordController.text)) {
      setState(() => _errorMessage = 'Your password must be at least 12 characters long.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).setPassword(_passwordController.text);
      if (mounted) setState(() => _step = 3);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Could not set your password. Try again in a moment.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _submitName() {
    final firstNameValid = isValidName(_firstNameController.text);
    final lastNameValid = isValidName(_lastNameController.text);
    if (!firstNameValid || !lastNameValid) {
      setState(() {
        _firstNameError = firstNameValid ? null : 'Must be at least 2 characters';
        _lastNameError = lastNameValid ? null : 'Must be at least 2 characters';
      });
      return;
    }
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _step = 4;
    });
  }

  void _submitAttendance() {
    if (_attends && (_chapterKey == null || _birthday == null)) {
      setState(() => _errorMessage = 'Select a chapter and birthday');
      return;
    }
    setState(() {
      _errorMessage = null;
      _step = 5;
    });
  }

  // Purely a local step transition — every field collected up to this point
  // (name, attendance/chapter/birthday, kids) stays in memory only. Nothing
  // is written to the backend until _finishWizard's "Let's Get Started" is
  // actually pressed, so backing out of the wizard at any point along the
  // way (including Finished->Kids) never leaves behind a record for
  // something the user then changed their mind about.
  void _finish() {
    setState(() {
      _errorMessage = null;
      _step = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      // Pinned below the scrollable body (see ScreenShell's `footer` slot,
      // already used by SignUpRoleScreen/SignUpWelcomeScreen) — this is
      // what keeps the primary action at the bottom of the screen instead
      // of trailing the scrolling content wherever it happens to end.
      footer: _buildFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Create Account', onBack: _canGoBack ? _goBack : null),
          StepProgress(step: _step + 1, total: _totalSteps),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() => _WizardStepConfig.forStep(_step).buildStep(this);

  Widget _buildFooter() => _WizardStepConfig.forStep(_step).buildFooter(this);

  /// The Finished step's "Let's Get Started" action — the only point in
  /// this whole wizard that actually writes the collected profile/chapter/
  /// kids data to the backend (see `_finish`'s doc comment for why that's
  /// deliberately deferred this far). On success, turns off the
  /// wizard-active exemption (see signUpWizardActiveProvider's doc
  /// comment) now that the wizard is genuinely done, then leaves for the
  /// authenticated app.
  Future<void> _finishWizard() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // Not currentUserProvider.notifier.save() — that provider is
      // autoDispose, and nothing on this screen ever ref.watch()es it to
      // keep it alive. By the time updateProfile's await resolves here,
      // Riverpod's already torn it down (no active listener), so save()'s
      // own ref.invalidateSelf() throws "Cannot use the Ref ... after it
      // has been disposed." Going straight through the repository (same
      // as completeCaptainSignup/createChildMember below) sidesteps that
      // entirely — there's no cache to invalidate anyway, since nothing
      // was watching currentUserProvider during signup in the first
      // place; Today/Profile will fetch fresh once actually navigated to.
      final profileRepository = ref.read(profileRepositoryProvider);
      final currentUser = await profileRepository.fetchCurrentUser();
      await profileRepository.updateProfile(currentUser.copyWith(firstName: firstName, lastName: lastName));

      if (_attends) {
        await profileRepository.completeCaptainSignup(
          chapterKey: _chapterKey!,
          firstName: firstName,
          lastName: lastName,
          birthday: _birthday!,
        );
      }
      for (final kid in _kids) {
        await profileRepository.createChildMember(
          firstName: kid.firstName,
          lastName: kid.lastName,
          chapterKey: kid.chapterKey ?? _chapterKey ?? '',
          birthday: kid.birthday,
          email: kid.email,
        );
      }
      ref.invalidate(householdMembersProvider);
      ref.invalidate(householdAssociationsProvider);

      ref.read(signUpWizardActiveProvider.notifier).set(false);
      if (mounted) context.go(RoutePaths.today);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not finish setting up your account. Try again in a moment.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _setAttends(bool value) => setState(() => _attends = value);
  void _setChapterKey(String? value) => setState(() => _chapterKey = value);
  void _setBirthday(DateTime? value) => setState(() => _birthday = value);

  void _startAddingChild() => setState(() => _addingChild = true);
  void _cancelAddingChild() => setState(() => _addingChild = false);

  void _addChild(_ChildDraft child) => setState(() {
    _kids.add(child);
    _addingChild = false;
  });

  void _removeChild(int index) => setState(() => _kids.removeAt(index));
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(message!, style: FraternusTypography.small(color: FraternusColors.error)),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({required this.controller, required this.errorMessage});

  final TextEditingController controller;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Heading("WHAT'S YOUR EMAIL?", level: HeadingLevel.h3),
        const SizedBox(height: 16),
        const FieldLabel(label: 'Email'),
        FormTextField(controller: controller, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 8),
        const BodyText("We'll send you a code to verify it's really you.", size: BodyTextSize.small),
        _ErrorText(errorMessage),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.email,
    required this.controller,
    required this.errorMessage,
    required this.onResend,
    required this.resendCooldownSeconds,
  });

  final String email;
  final TextEditingController controller;
  final String? errorMessage;
  final VoidCallback onResend;

  /// Seconds left before Resend Code can be pressed again — 0 means ready.
  final int resendCooldownSeconds;

  @override
  Widget build(BuildContext context) {
    final onCooldown = resendCooldownSeconds > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Heading('CHECK YOUR EMAIL', level: HeadingLevel.h3),
        const SizedBox(height: 8),
        BodyText('Enter the 6-digit code we sent to $email.', size: BodyTextSize.small),
        const SizedBox(height: 16),
        const FieldLabel(label: 'Verification Code'),
        _CodeInput(controller: controller),
        const SizedBox(height: 8),
        Button(
          label: onCooldown ? 'Resend Code (${resendCooldownSeconds}s)' : 'Resend Code',
          variant: ButtonVariant.underlined,
          size: ButtonSize.small,
          disabled: onCooldown,
          onPressed: onResend,
        ),
        _ErrorText(errorMessage),
      ],
    );
  }
}

/// Six single-digit boxes standing in for one text field — `widget.controller`
/// (the wizard's shared `_codeController`) stays the single source of truth
/// that `_verifyCode` reads from; this widget's only job is keeping it in
/// sync with whatever's currently split across the boxes below.
class _CodeInput extends StatefulWidget {
  const _CodeInput({required this.controller});

  final TextEditingController controller;

  @override
  State<_CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<_CodeInput> {
  static const _length = 6;

  final _digitControllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _applyDigits(widget.controller.text);
  }

  @override
  void dispose() {
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _applyDigits(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < _length; i++) {
      _digitControllers[i].text = i < digits.length ? digits[i] : '';
    }
  }

  void _syncCode() {
    widget.controller.text = _digitControllers.map((controller) => controller.text).join();
  }

  // TextField has no separate paste callback — a paste (or autofill) just
  // delivers every digit to whichever box currently has focus in one
  // onChanged call, so any value longer than a single digit here is
  // treated as the whole code rather than just that box's own input.
  void _onChanged(int index, String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 1) {
      _applyDigits(digits);
      _syncCode();
      final filledCount = digits.length > _length ? _length : digits.length;
      _focusNodes[filledCount >= _length ? _length - 1 : filledCount].requestFocus();
      return;
    }

    _syncCode();
    if (digits.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(child: _digitBox(i)),
        ],
      ],
    );
  }

  Widget _digitBox(int index) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.sm),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _digitControllers[index],
        focusNode: _focusNodes[index],
        autofocus: index == 0,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: _length,
        style: FraternusTypography.body().copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onChanged(index, value),
      ),
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({required this.controller, required this.errorMessage});

  final TextEditingController controller;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Heading('CREATE A PASSWORD', level: HeadingLevel.h3),
        const SizedBox(height: 16),
        const FieldLabel(label: 'Password'),
        FormTextField(controller: controller, obscureText: true),
        const SizedBox(height: 8),
        const BodyText('Must be at least 12 characters.', size: BodyTextSize.small),
        _ErrorText(errorMessage),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.firstNameController,
    required this.lastNameController,
    required this.firstNameError,
    required this.lastNameError,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final String? firstNameError;
  final String? lastNameError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Heading("WHAT'S YOUR NAME?", level: HeadingLevel.h3),
        const SizedBox(height: 16),
        const FieldLabel(label: 'First Name'),
        FormTextField(controller: firstNameController),
        _ErrorText(firstNameError),
        const SizedBox(height: 16),
        const FieldLabel(label: 'Last Name'),
        FormTextField(controller: lastNameController),
        _ErrorText(lastNameError),
      ],
    );
  }
}

class _AttendanceStep extends ConsumerWidget {
  const _AttendanceStep({
    required this.attends,
    required this.chapterKey,
    required this.birthday,
    required this.errorMessage,
    required this.onAttendsChanged,
    required this.onChapterChanged,
    required this.onBirthdayChanged,
  });

  final bool attends;
  final String? chapterKey;
  final DateTime? birthday;
  final String? errorMessage;
  final ValueChanged<bool> onAttendsChanged;
  final ValueChanged<String?> onChapterChanged;
  final ValueChanged<DateTime?> onBirthdayChanged;

  Future<void> _pickBirthday(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showFraternusDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(now.year - 35, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) onBirthdayChanged(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Heading('WILL YOU BE ATTENDING WEEKLY FRAT NIGHTS?', level: HeadingLevel.h3),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: FraternusColors.white,
            border: Border.all(color: FraternusColors.borderSubtle),
            borderRadius: BorderRadius.circular(FraternusRadii.lg),
          ),
          child: Column(
            children: [
              _RadioRow(label: 'Yes', selected: attends, onTap: () => onAttendsChanged(true)),
              const HairlineDivider(),
              _RadioRow(label: 'No', selected: !attends, onTap: () => onAttendsChanged(false)),
            ],
          ),
        ),
        if (attends) ...[
          const SizedBox(height: 16),
          const FieldLabel(label: 'Chapter'),
          SelectField(
            value: chapterKey,
            options: {for (final chapter in chapters) chapter.key: chapter.displayName},
            placeholder: 'Select a chapter',
            onChanged: onChapterChanged,
          ),
          const SizedBox(height: 16),
          const FieldLabel(label: 'Birthday'),
          BirthdayField(date: birthday, onTap: () => _pickBirthday(context)),
        ],
        _ErrorText(errorMessage),
      ],
    );
  }
}

/// Plain Yes/No radio row — this screen is the only place in the app that
/// needs a bordered-list radio group (RsvpToggle is a pill toggle,
/// FraternusSwitch is a boolean switch; neither matches this shape), so
/// it's kept private here rather than promoted to the design system for a
/// single caller.
class _RadioRow extends StatelessWidget {
  const _RadioRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.85 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? FraternusColors.accentPrimary : FraternusColors.borderSubtle,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: FraternusColors.accentPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(label, style: FraternusTypography.body().copyWith(fontSize: 15)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KidsStep extends ConsumerWidget {
  const _KidsStep({
    required this.kids,
    required this.addingChild,
    required this.defaultChapterKey,
    required this.errorMessage,
    required this.onStartAdd,
    required this.onCancelAdd,
    required this.onAddChild,
    required this.onRemoveChild,
  });

  final List<_ChildDraft> kids;
  final bool addingChild;
  final String? defaultChapterKey;
  final String? errorMessage;
  final VoidCallback onStartAdd;
  final VoidCallback onCancelAdd;
  final ValueChanged<_ChildDraft> onAddChild;
  final ValueChanged<int> onRemoveChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Heading('ADD YOUR KIDS', level: HeadingLevel.h3),
        const SizedBox(height: 8),
        const BodyText(
          'Add each of your sons that are in Fraternus. You can always add more later.',
          size: BodyTextSize.small,
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < kids.length; i++)
          InfoCard(
            initials: kids[i].fullName.isEmpty
                ? null
                : kids[i].fullName.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase(),
            title: kids[i].fullName,
            subtitle: 'Born ${kids[i].birthday.month}/${kids[i].birthday.day}/${kids[i].birthday.year}',
            onRemove: () => onRemoveChild(i),
          ),
        if (addingChild)
          _InlineChildForm(
            chapters: chapters,
            defaultChapterKey: defaultChapterKey,
            onCancel: onCancelAdd,
            onAdd: onAddChild,
          )
        else
          _AddChildButton(onTap: onStartAdd),
        _ErrorText(errorMessage),
      ],
    );
  }
}

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onTap,
      semanticLabel: 'Add Child',
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.85 : 1,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: FraternusColors.white,
              border: Border.all(color: FraternusColors.borderSubtle),
              borderRadius: BorderRadius.circular(FraternusRadii.lg),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FraternusIcon(name: 'plus', size: 16),
                const SizedBox(width: 8),
                Text('ADD CHILD', style: FraternusTypography.button(fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InlineChildForm extends StatefulWidget {
  const _InlineChildForm({
    required this.chapters,
    required this.defaultChapterKey,
    required this.onCancel,
    required this.onAdd,
  });

  final List<Chapter> chapters;
  final String? defaultChapterKey;
  final VoidCallback onCancel;
  final ValueChanged<_ChildDraft> onAdd;

  @override
  State<_InlineChildForm> createState() => _InlineChildFormState();
}

class _InlineChildFormState extends State<_InlineChildForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _birthday;
  late String? _chapterKey = widget.defaultChapterKey;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showFraternusDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  bool get _canAdd =>
      isValidName(_firstNameController.text) && isValidName(_lastNameController.text) && _birthday != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel(label: 'First Name'),
          FormTextField(controller: _firstNameController, placeholder: 'First name'),
          const SizedBox(height: 16),
          const FieldLabel(label: 'Last Name'),
          FormTextField(controller: _lastNameController, placeholder: 'Last name'),
          const SizedBox(height: 16),
          const FieldLabel(label: 'Birthday'),
          BirthdayField(date: _birthday, onTap: _pickBirthday),
          const SizedBox(height: 16),
          const FieldLabel(label: 'Email (Optional)'),
          FormTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            placeholder: 'Email',
          ),
          const SizedBox(height: 16),
          const FieldLabel(label: 'Chapter'),
          SelectField(
            value: _chapterKey,
            options: {for (final chapter in widget.chapters) chapter.key: chapter.displayName},
            placeholder: 'Select a chapter',
            onChanged: (value) => setState(() => _chapterKey = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Button(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: widget.onCancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Button(
                  label: 'Add',
                  fullWidth: true,
                  disabled: !_canAdd,
                  onPressed: () => widget.onAdd(
                    _ChildDraft(
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      birthday: _birthday!,
                      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                      chapterKey: _chapterKey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinishedStep extends ConsumerWidget {
  const _FinishedStep({
    required this.fullName,
    required this.email,
    required this.attends,
    required this.chapterKey,
    required this.kids,
    required this.errorMessage,
  });

  final String fullName;
  final String email;
  final bool attends;
  final String? chapterKey;
  final List<_ChildDraft> kids;
  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];
    String? chapterName;
    for (final chapter in chapters) {
      if (chapter.key == chapterKey) {
        chapterName = chapter.displayName;
        break;
      }
    }
    final isCaptain = attends && chapterName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const IconBadgeCircle(icon: 'sparkles', size: IconBadgeCircleSize.large),
        const SizedBox(height: 16),
        const Heading("YOU'RE ALL SET", level: HeadingLevel.h3),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('YOU', style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: FraternusColors.white,
            border: Border.all(color: FraternusColors.borderSubtle),
            borderRadius: BorderRadius.circular(FraternusRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: FraternusTypography.body(
                  color: FraternusColors.ink,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(email, style: FraternusTypography.small(color: FraternusColors.textOnLightMuted)),
              if (isCaptain) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Tag(label: 'Captain', color: TagColor.secondary),
                    const SizedBox(width: 8),
                    Text(chapterName, style: FraternusTypography.small()),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Omitted entirely (rather than shown empty) when the Guardian
        // added no kids — a dangling divider over an empty list would
        // read as broken, not as "you have none".
        if (kids.isNotEmpty) ...[
          const SizedBox(height: 20),
          const HairlineDivider(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'YOUR KIDS',
              style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
            ),
          ),
          const SizedBox(height: 8),
          for (final kid in kids)
            InfoCard(
              initials: kid.fullName.isEmpty
                  ? null
                  : kid.fullName.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase(),
              title: kid.fullName,
              subtitle: 'Born ${kid.birthday.month}/${kid.birthday.day}/${kid.birthday.year}',
            ),
        ],
        _ErrorText(errorMessage),
      ],
    );
  }
}
