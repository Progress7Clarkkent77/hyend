import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/userAuth/account_controller.dart';
import 'package:hyend/userAuth/authController.dart';
import 'package:hyend/userAuth/auth_widgets.dart';

//------------------------------------------------------------------------------//
// LOGIN
//------------------------------------------------------------------------------//

class EarnLogin extends StatefulWidget {
  const EarnLogin({super.key});

  @override
  State<EarnLogin> createState() => _EarnLoginState();
}

class _EarnLoginState extends State<EarnLogin> {
  final AccountController accountController = Get.put(AccountController());

  late AuthController authController;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  /// Login's back button (and the system / browser back) always lands on /home.
  void _goHome() => Get.offAllNamed('/home');

  void _submit() {
    if (authController.isLoading.value) return;
    authController.login(emailCtrl.text.trim(), passwordCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: AuthScaffold(
        title: 'Welcome back',
        subtitle: 'Sign in to continue on HyEnd',
        onBack: _goHome,
        cardChildren: [
          /// EMAIL
          AuthField(
            controller: emailCtrl,
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          /// PASSWORD
          Obx(
            () => AuthField(
              controller: passwordCtrl,
              label: 'Password',
              hint: 'Enter 6-digit password',
              icon: Icons.lock_outline_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              obscureText: !authController.isPasswordVisible.value,
              maxLength: 6,
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                icon: Icon(
                  authController.isPasswordVisible.value
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 20,
                  color: AuthPalette.muted,
                ),
                onPressed: authController.togglePasswordVisibility,
              ),
            ),
          ),

          /// FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.toNamed('/forgotpassword'),
              style: TextButton.styleFrom(
                foregroundColor: AuthPalette.muted,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// LOGIN BUTTON
          Obx(
            () => AuthButton(
              label: 'Log in',
              loading: authController.isLoading.value,
              onPressed: _submit,
            ),
          ),
        ],
        below: [
          AuthSwitchRow(
            prompt: "Don't have an account?",
            action: 'Sign up',
            onTap: () => Get.toNamed('/signup'),
          ),
          const AuthFooter(),
        ],
      ),
    );
  }
}

//------------------------------------------------------------------------------//
// SIGN UP
//------------------------------------------------------------------------------//

class EarnSignUp extends StatefulWidget {
  const EarnSignUp({super.key});

  @override
  State<EarnSignUp> createState() => _EarnSignUpState();
}

class _EarnSignUpState extends State<EarnSignUp> {
  late AuthController authController;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  /// Optional — a friend's 6-digit referral code.
  final TextEditingController referCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    referCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (authController.isLoading.value) return;

    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    await authController.signup(
      nameCtrl.text.trim(),
      emailCtrl.text.trim(),
      passwordCtrl.text.trim(),
      referralCode: referCodeCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join HyEnd and get started',
      onBack: () => authGoBack(context, fallback: '/login'),
      cardChildren: [
        /// NAME
        AuthField(
          controller: nameCtrl,
          label: 'Name',
          hint: 'Enter your name',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 14),

        /// EMAIL
        AuthField(
          controller: emailCtrl,
          label: 'Email',
          hint: 'Enter your email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 14),

        /// PASSWORD
        Obx(
          () => AuthField(
            controller: passwordCtrl,
            label: 'Password',
            hint: 'Enter 6-digit password',
            icon: Icons.lock_outline_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            obscureText: !authController.isPasswordVisible.value,
            maxLength: 6,
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              icon: Icon(
                authController.isPasswordVisible.value
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 20,
                color: AuthPalette.muted,
              ),
              onPressed: authController.togglePasswordVisibility,
            ),
          ),
        ),

        const SizedBox(height: 14),

        /// SIGN UP BUTTON
        Obx(
          () => AuthButton(
            label: 'Create account',
            loading: authController.isLoading.value,
            onPressed: _submit,
          ),
        ),
      ],
      below: [
        AuthSwitchRow(
          prompt: 'Already have an account?',
          action: 'Log in',
          onTap: () => Get.toNamed('/login'),
        ),
        const AuthFooter(),
      ],
    );
  }
}
