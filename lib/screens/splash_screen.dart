import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final prov = context.read<AppProvider>();
    if (!prov.onboarded) {
      Navigator.pushReplacement(
          context, _route(const OnboardingScreen()));
    } else if (prov.isLocked) {
      Navigator.pushReplacement(context, _route(const LockScreen()));
    } else {
      Navigator.pushReplacement(context, _route(const HomeScreen()));
    }
  }

  PageRouteBuilder _route(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      );

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prov.lottieEnabled)
                Lottie.asset(
                  'assets/lottie/splash.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _fallbackIcon(),
                )
              else
                _fallbackIcon(),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                AppStrings.tagline,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: const Icon(Icons.psychology_outlined, size: 60, color: Colors.white),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }
}
