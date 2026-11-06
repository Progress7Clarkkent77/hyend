import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Colours shared by the login, sign-up and forgot-password screens.
class AuthPalette {
  static const Color ink = Colors.black;
  static const Color paper = Color(0xFFF3F4F6);
  static const Color field = Color(0xFFF3F4F6);
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF6B7280);
}

/// Goes back one page. If there is nothing to go back to (for example the
/// user refreshed the browser on /signup), it falls back to [fallback].
void authGoBack(BuildContext context, {String fallback = '/login'}) {
  if (Navigator.of(context).canPop()) {
    Get.back();
  } else {
    Get.offAllNamed(fallback);
  }
}

/// Page shell: a black header with a back button, logo and title, and a white
/// card that overlaps the header. The header shrinks while the keyboard is
/// open so the form always has room.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final List<Widget> cardChildren;
  final List<Widget> below;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.cardChildren,
    this.below = const [],
  });

  static const double _overlap = 40;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final top = media.padding.top;

    final headerHeight = top + (keyboardOpen ? 160 : 280);
    final logoSize = keyboardOpen ? 44.0 : 80.0;
    const anim = Duration(milliseconds: 250);

    return Scaffold(
      backgroundColor: AuthPalette.paper,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Stack(
          children: [
            // ---------------- HEADER ----------------
            AnimatedContainer(
              duration: anim,
              curve: Curves.easeInOut,
              width: double.infinity,
              height: headerHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, Color(0xFF232323)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Stack(
                    children: [
                      Positioned(
                        top: top + 8,
                        left: 12,
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: onBack,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.12),
                            foregroundColor: Colors.white,
                            fixedSize: const Size(44, 44),
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: _overlap + 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    keyboardOpen ? 16 : 26,
                                  ),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    keyboardOpen ? 12 : 21,
                                  ),
                                  child: AnimatedContainer(
                                    duration: anim,
                                    curve: Curves.easeInOut,
                                    width: logoSize,
                                    height: logoSize,
                                    child: Image.asset(
                                      'assets/images/HyEnd.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: keyboardOpen ? 10 : 16),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: keyboardOpen ? 22 : 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              if (!keyboardOpen) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------------- CARD ----------------
            AnimatedPadding(
              duration: anim,
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(top: headerHeight - _overlap),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AuthPalette.hairline),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(children: cardChildren),
                        ),
                        ...below,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filled, rounded text field with a black focus ring.
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLength;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLength,
    this.suffix,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLength: maxLength,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      cursorColor: AuthPalette.ink,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: AuthPalette.field,
        counterText: '',
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        labelStyle: const TextStyle(color: AuthPalette.muted),
        floatingLabelStyle: const TextStyle(
          color: AuthPalette.ink,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 20, color: AuthPalette.muted),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: border(Colors.transparent, 0),
        enabledBorder: border(Colors.transparent, 0),
        focusedBorder: border(AuthPalette.ink, 1.5),
      ),
    );
  }
}

/// Primary black button with a built-in loading state.
class AuthButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthPalette.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AuthPalette.ink,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

/// "Don't have an account?  Sign up" style row.
class AuthSwitchRow extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchRow({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prompt,
            style: const TextStyle(fontSize: 13.5, color: AuthPalette.muted),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AuthPalette.ink,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 40),
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand tagline shown under every auth card.
class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        'Wholesale beyond Borders.',
        style: TextStyle(
          fontSize: 11.5,
          fontStyle: FontStyle.italic,
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
