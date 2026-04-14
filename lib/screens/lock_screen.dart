import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  final bool isSetup;
  const LockScreen({super.key, this.isSetup = false});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _input = '';
  String _confirm = '';
  bool _confirming = false;
  bool _error = false;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: 400.ms);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _tap(String digit) {
    if (_input.length >= 4) return;
    setState(() => _input += digit);
    if (_input.length == 4) _check();
  }

  void _delete() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _check() async {
    await Future.delayed(200.ms);
    final prov = context.read<AppProvider>();

    if (widget.isSetup) {
      if (!_confirming) {
        setState(() {
          _confirm = _input;
          _input = '';
          _confirming = true;
        });
      } else {
        if (_input == _confirm) {
          await prov.setPin(_input);
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          _shake();
          setState(() {
            _input = '';
            _confirming = false;
            _confirm = '';
          });
        }
      }
    } else {
      if (prov.verifyPin(_input)) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: 400.ms,
          ),
        );
      } else {
        _shake();
        setState(() {
          _input = '';
          _error = true;
        });
        await Future.delayed(800.ms);
        if (mounted) setState(() => _error = false);
      }
    }
  }

  void _shake() => _shakeCtrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final title = widget.isSetup
        ? (_confirming ? 'Confirm PIN' : 'Set PIN')
        : 'Enter PIN';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.accent)
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 40),
              // PIN dots
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (_, child) {
                  final shake =
                      ((_shakeCtrl.value * 4).round() % 2 == 0 ? 1.0 : -1.0) *
                          8 *
                          (1 - _shakeCtrl.value);
                  return Transform.translate(
                      offset: Offset(shake, 0), child: child);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _input.length;
                    return AnimatedContainer(
                      duration: 150.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _error
                            ? AppColors.error
                            : filled
                            ? AppColors.accent
                            : AppColors.divider,
                        boxShadow: filled && !_error
                            ? [
                          BoxShadow(
                              color: AppColors.accent.withOpacity(0.5),
                              blurRadius: 8)
                        ]
                            : [],
                      ),
                    );
                  }),
                ),
              ),
              if (_error)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('Incorrect PIN',
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13))
                      .animate()
                      .fadeIn(),
                ),
              const SizedBox(height: 48),
              _buildKeypad(),
              const SizedBox(height: 8),
              if (!widget.isSetup)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '⌫'],
          ])
            Row(
              children: row
                  .map((k) => Expanded(child: _buildKey(k)))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () {
        if (key == '⌫') {
          _delete();
        } else if (key.isNotEmpty) {
          _tap(key);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: key.isEmpty ? Colors.transparent : AppColors.bgCardLight,
              shape: BoxShape.circle,
              border: key.isEmpty
                  ? null
                  : Border.all(color: AppColors.divider, width: 1),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: key == '⌫' ? 20 : 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}