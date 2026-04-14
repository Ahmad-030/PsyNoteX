import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'about_screen.dart';
import 'lock_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.textPrimary, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    ],
                  ),
                ),
              ),

              // ── APPEARANCE ──────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'APPEARANCE',
                  children: [
                    _SettingTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Theme',
                      trailing: DropdownButton<ThemeMode>(
                        value: prov.themeMode,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                              value: ThemeMode.dark, child: Text('Dark')),
                          DropdownMenuItem(
                              value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(
                              value: ThemeMode.system, child: Text('System')),
                        ],
                        onChanged: (v) {
                          if (v != null) prov.setThemeMode(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── SECURITY ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'SECURITY',
                  children: [
                    _SettingTile(
                      icon: Icons.lock_outline,
                      title: 'PIN Lock',
                      subtitle: prov.pinEnabled ? 'Enabled' : 'Disabled',
                      trailing: Switch(
                        value: prov.pinEnabled,
                        onChanged: (v) {
                          if (v) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const LockScreen(isSetup: true)),
                            );
                          } else {
                            prov.disablePin();
                          }
                        },
                      ),
                    ),
                    if (prov.pinEnabled)
                      _SettingTile(
                        icon: Icons.edit_outlined,
                        title: 'Change PIN',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LockScreen(isSetup: true)),
                        ),
                      ),
                  ],
                ),
              ),

              // ── DATA ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'DATA',
                  children: [
                    _SettingTile(
                      icon: Icons.delete_sweep_outlined,
                      title: 'Reset All Data',
                      subtitle: 'Delete all notes and tags',
                      titleColor: AppColors.error,
                      onTap: () => _confirmReset(context, prov),
                    ),
                  ],
                ),
              ),

              // ── ABOUT ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'ABOUT',
                  children: [
                    _SettingTile(
                      icon: Icons.info_outline,
                      title: 'About PsyNoteX',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen())),
                    ),
                    _SettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen())),
                    ),
                    _SettingTile(
                      icon: Icons.info_outlined,
                      title: 'Version',
                      trailing: const Text(AppStrings.version,
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, AppProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Data',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'All notes and tags will be permanently deleted. This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              prov.resetData();
              Navigator.pop(context);
            },
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: children
                  .asMap()
                  .entries
                  .map((e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 56),
                ],
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}

// ── Individual tile ───────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: titleColor ?? AppColors.accent, size: 18),
      ),
      title: Text(title,
          style: TextStyle(
              color: titleColor ?? AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!,
          style: const TextStyle(
              color: AppColors.textHint, fontSize: 12))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 18)
              : null),
    );
  }
}