import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (prov.lottieEnabled)
                  Lottie.asset(
                    'assets/lottie/about.json',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.psychology_outlined,
                      size: 100,
                      color: AppColors.accent,
                    ),
                  )
                else
                  const Icon(Icons.psychology_outlined,
                      size: 100, color: AppColors.accent),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),

                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GlassCard(
                    child: Text(
                      AppStrings.appDesc,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GlassCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Developer',
                          value: AppStrings.devName,
                        ),
                        const Divider(color: AppColors.divider, height: 20),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Contact',
                          value: AppStrings.devEmail,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 40),
                Text(
                  'Made with 💜 for mindful journalers',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
