import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/userAuth/authController.dart';
import 'package:hyend/userAuth/auth_widgets.dart';

//import 'package:otp_text_field/otp_text_field.dart';
//import 'package:otp_text_field/style.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late AuthController authController;

  final TextEditingController emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (authController.isLoading.value) return;

    if (emailCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    authController.sendPasswordResetEmail(emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot password?',
      subtitle: 'Enter your email to reset your password',
      onBack: () => authGoBack(context, fallback: '/login'),
      cardChildren: [
        /// EMAIL
        AuthField(
          controller: emailCtrl,
          label: 'Email',
          hint: 'Enter your email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),

        const SizedBox(height: 18),

        /// RESET BUTTON
        Obx(
          () => AuthButton(
            label: 'Send Email',
            loading: authController.isLoading.value,
            onPressed: _submit,
          ),
        ),
      ],
      below: [
        AuthSwitchRow(
          prompt: 'Remembered it?',
          action: 'Log in',
          onTap: () => Get.toNamed('/login'),
        ),
        const AuthFooter(),
      ],
    );
  }
}
