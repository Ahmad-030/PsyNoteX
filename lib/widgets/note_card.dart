import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import 'shared_widgets.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = AppColors.tagColors[note.mood.index % AppColors.tagColors.length];
    return GestureDetector(
      onLongPress: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tagColor.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: tagColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [tagColor, tagColor.withOpacity(0.2)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(note.mood.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          note.mood.label,
                          style: TextStyle(
                            color: tagColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d, h:mm a').format(note.createdAt),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.textHint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: note.tags.map((t) {
                          final prov = context.read<AppProvider>();
                          final tag = prov.tags.firstWhere(
                            (tg) => tg.name == t,
                            orElse: () => TagModel(name: t, colorIndex: 0),
                          );
                          final c = AppColors.tagColors[tag.colorIndex % AppColors.tagColors.length];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: c.withOpacity(0.3)),
                            ),
                            child: Text(
                              '#$t',
                              style: TextStyle(
                                color: c,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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

// ── Add / Edit Note Bottom Sheet ─────────────────────────────────────────────

Future<void> showNoteSheet(BuildContext context, {NoteModel? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => NoteBottomSheet(existing: existing),
  );
}

class NoteBottomSheet extends StatefulWidget {
  final NoteModel? existing;
  const NoteBottomSheet({super.key, this.existing});

  @override
  State<NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<NoteBottomSheet> {
  late TextEditingController _ctrl;
  late Mood _mood;
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing?.content ?? '');
    _mood = widget.existing?.mood ?? Mood.neutral;
    _selectedTags = List<String>.from(widget.existing?.tags ?? []);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;
    final prov = context.read<AppProvider>();
    if (widget.existing == null) {
      await prov.addNote(content, _mood, _selectedTags);
    } else {
      await prov.updateNote(widget.existing!.id, content, _mood, _selectedTags);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      widget.existing == null ? 'New Thought' : 'Edit Note',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: _ctrl,
                      builder: (_, val, __) => Text(
                        '${val.text.length}/100',
                        style: TextStyle(
                          color: val.text.length > 90
                              ? AppColors.error
                              : AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctrl,
                  maxLength: 100,
                  maxLines: 4,
                  autofocus: true,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('How are you feeling?',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: Mood.values.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: MoodChip(
                          emoji: m.emoji,
                          label: m.label,
                          selected: _mood == m,
                          onTap: () => setState(() => _mood = m),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (prov.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Tags',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: prov.tags.map((tag) {
                      final sel = _selectedTags.contains(tag.name);
                      final c = AppColors.tagColors[
                          tag.colorIndex % AppColors.tagColors.length];
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (sel) {
                            _selectedTags.remove(tag.name);
                          } else {
                            _selectedTags.add(tag.name);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? c.withOpacity(0.2) : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? c : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            '#${tag.name}',
                            style: TextStyle(
                              color: sel ? c : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      widget.existing == null ? 'Save Thought' : 'Update',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
