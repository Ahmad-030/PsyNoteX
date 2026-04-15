import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardPage(this.emoji, this.title, this.subtitle, this.accent);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      '🧠',
      'Capture Thoughts',
      'Write micro notes in seconds.\nNo friction, just flow.',
      AppColors.accent,
    ),
    _OnboardPage(
      '😊',
      'Track Your Mood',
      'Tag how you feel with every entry.\nSee patterns emerge over time.',
      AppColors.primaryLight,
    ),
    _OnboardPage(
      '📊',
      'Understand Yourself',
      'Smart insights reveal when you\'re\nhappiest and most stressed.',
      AppColors.success,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() async {
    await context.read<AppProvider>().completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: 500.ms,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Skip',
                      style: TextStyle(color: cs.textSecondary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _buildPage(_pages[i], cs),
                ),
              ),
              _buildDots(cs),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: _next,
                  child: AnimatedContainer(
                    duration: 300.ms,
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, _pages[_page].accent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _page == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page, AppColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 80))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: TextStyle(
              color: cs.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: TextStyle(
              color: cs.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildDots(AppColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        return AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _page ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _page ? cs.accent : cs.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
