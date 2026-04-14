import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadFlutterAsset('assets/html/privacy_policy.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: WebViewWidget(controller: _controller),
                    ),
                    if (_loading)
                      const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
