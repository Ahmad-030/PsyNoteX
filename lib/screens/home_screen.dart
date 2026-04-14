import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/note_card.dart';
import '../widgets/shared_widgets.dart';
import 'analytics_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'tags_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _fabCtrl;
  bool _fabExpanded = false;

  final _screens = const [
    _TimelineTab(),
    AnalyticsScreen(),
    TagsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(vsync: this, duration: 300.ms);
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
    _fabExpanded ? _fabCtrl.forward() : _fabCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: GradientBackground(
        child: IndexedStack(index: _navIndex, children: _screens),
      ),
      floatingActionButton: _navIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_fabExpanded)
          ...[
            _fabMini(Icons.search, 'Search', () {
              _toggleFab();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            }),
            const SizedBox(height: 8),
            _fabMini(Icons.edit_note, 'New Note', () {
              _toggleFab();
              showNoteSheet(context);
            }),
            const SizedBox(height: 12),
          ],
        FloatingActionButton(
          onPressed: _toggleFab,
          child: AnimatedRotation(
            turns: _fabExpanded ? 0.125 : 0,
            duration: 300.ms,
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _fabMini(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(0, Icons.home_rounded, 'Home'),
            _navItem(1, Icons.bar_chart_rounded, 'Analytics'),
            _navItem(2, Icons.label_rounded, 'Tags'),
            _navItem(3, Icons.settings_rounded, 'Settings', onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label, {VoidCallback? onTap}) {
    final selected = _navIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () => setState(() => _navIndex = idx),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.accent : AppColors.textHint,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.accent : AppColors.textHint,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Timeline Tab ─────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  const _TimelineTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final notes = prov.notes;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, prov)),
          if (notes.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => AnimationConfiguration.staggeredList(
                  position: i,
                  duration: 400.ms,
                  child: SlideAnimation(
                    verticalOffset: 30,
                    child: FadeInAnimation(
                      child: Slidable(
                        key: ValueKey(notes[i].id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  showNoteSheet(context, existing: notes[i]),
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                              borderRadius: BorderRadius.circular(12),
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  prov.deleteNote(notes[i].id),
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                        child: NoteCard(
                          note: notes[i],
                          onEdit: () => showNoteSheet(context, existing: notes[i]),
                          onDelete: () => _confirmDelete(context, prov, notes[i].id),
                        ),
                      ),
                    ),
                  ),
                ),
                childCount: notes.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider prov) {
    final streak = prov.getStreak();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PsyNoteX',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  Text(
                    '${prov.notes.length} thoughts captured',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              if (streak > 0)
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text('$streak day${streak > 1 ? 's' : ''}',
                          style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          const SectionHeader(title: 'RECENT THOUGHTS'),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧠', style: TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text('No thoughts yet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Tap + to capture your first thought',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider prov, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Note',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              prov.deleteNote(id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
