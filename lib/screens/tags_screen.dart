import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final usage = prov.getTagUsage();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddTag(context, prov),
                  icon: const Icon(Icons.add, color: AppColors.accent),
                ),
              ],
            ),
          ),
          Expanded(
            child: prov.tags.isEmpty
                ? _buildEmpty()
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: prov.tags.length,
                      itemBuilder: (_, i) {
                        final tag = prov.tags[i];
                        final color = AppColors.tagColors[
                            tag.colorIndex % AppColors.tagColors.length];
                        final count = usage[tag.name] ?? 0;
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: 400.ms,
                          child: SlideAnimation(
                            horizontalOffset: -30,
                            child: FadeInAnimation(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: color.withOpacity(0.3)),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text('#',
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  title: Text(tag.name,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      '$count note${count != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 12)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.error, size: 20),
                                    onPressed: () =>
                                        _confirmDelete(context, prov, tag.name),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏷️', style: TextStyle(fontSize: 56))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text('No tags yet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Tap + to create your first tag',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddTag(BuildContext context, AppProvider prov) {
    final ctrl = TextEditingController();
    int selectedColor = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Tag',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Tag name...',
                  prefixText: '# ',
                  prefixStyle: TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Color',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(AppColors.tagColors.length, (i) {
                  return GestureDetector(
                    onTap: () => setS(() => selectedColor = i),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.tagColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == i
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: selectedColor == i
                            ? [
                                BoxShadow(
                                    color:
                                        AppColors.tagColors[i].withOpacity(0.5),
                                    blurRadius: 8)
                              ]
                            : [],
                      ),
                      child: selectedColor == i
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = ctrl.text.trim();
                    if (name.isEmpty) return;
                    prov.addTag(TagModel(name: name, colorIndex: selectedColor));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Tag',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider prov, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Tag',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Remove "#$name" from all notes?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              prov.deleteTag(name);
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
