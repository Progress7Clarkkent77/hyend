import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/startup_controller.dart';
import 'package:hyend/theme/app_theme.dart';
import 'package:hyend/widgets/hyend_logo.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _footerFade;

  final StartupController startupCtrl = Get.put(StartupController());

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _footerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    // Start after the first frame so nothing changes state during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startupCtrl.initializeApp();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1B2747), AppColors.navy],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: const HyEndLogo(size: 104),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      const Text(
                        'HYEND',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(width: 48, height: 2, color: AppColors.gold),
                      const SizedBox(height: 14),
                      Text(
                        'Wholesale Beyond Borders.',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _footerFade,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'POWERED BY',
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 3,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'AFIA SPLENDID LTD',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: AppColors.goldSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
