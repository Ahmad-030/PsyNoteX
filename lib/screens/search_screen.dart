import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  Set<Mood> _moodFilter = {};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<NoteModel> _filter(List<NoteModel> notes) {
    return notes.where((n) {
      final matchText =
          _query.isEmpty || n.content.toLowerCase().contains(_query.toLowerCase());
      final matchMood = _moodFilter.isEmpty || _moodFilter.contains(n.mood);
      return matchText && matchMood;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final prov = context.watch<AppProvider>();
    final results = _filter(prov.notes);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: cs.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: cs.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search thoughts...',
                          prefixIcon: Icon(Icons.search,
                              color: cs.textHint, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close,
                                      color: cs.textHint, size: 18),
                                  onPressed: () {
                                    _ctrl.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ).animate().fadeIn().slideX(begin: 0.2, end: 0),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: Mood.values.map((m) {
                    final sel = _moodFilter.contains(m);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel) {
                          _moodFilter.remove(m);
                        } else {
                          _moodFilter.add(m);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary.withOpacity(0.4)
                              : cs.bgCardLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? cs.accent : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(m.label,
                                style: TextStyle(
                                  color: sel ? cs.accent : cs.textSecondary,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${results.length} result${results.length != 1 ? 's' : ''}',
                      style: TextStyle(color: cs.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔍',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty
                                  ? 'Start typing to search'
                                  : 'No results for "$_query"',
                              style: TextStyle(
                                  color: cs.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (_, i) =>
                              AnimationConfiguration.staggeredList(
                            position: i,
                            duration: 300.ms,
                            child: SlideAnimation(
                              verticalOffset: 20,
                              child: FadeInAnimation(
                                child: _HighlightCard(
                                  note: results[i],
                                  query: _query,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final NoteModel note;
  final String query;
  const _HighlightCard({required this.note, required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cs.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(note.mood.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(note.mood.label,
                    style: TextStyle(color: cs.textSecondary, fontSize: 12)),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(note.createdAt),
                  style: TextStyle(color: cs.textHint, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHighlight(note.content, query, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlight(String text, String query, AppColorScheme cs) {
    if (query.isEmpty) {
      return Text(text,
          style: TextStyle(color: cs.textPrimary, fontSize: 14, height: 1.5));
    }

    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(qLower, start);
      if (idx == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(color: cs.textPrimary),
        ));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(
          text: text.substring(start, idx),
          style: TextStyle(color: cs.textPrimary),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          color: cs.bgCard,
          backgroundColor: cs.accent,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.5),
        children: spans,
      ),
    );
  }
}
