import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';

class AppProvider extends ChangeNotifier {
  static const _notesKey = 'notes';
  static const _tagsKey = 'tags';
  static const _themeKey = 'theme_mode';
  static const _pinKey = 'pin_code';
  static const _pinEnabledKey = 'pin_enabled';
  static const _animKey = 'animations_enabled';
  static const _lottieKey = 'lottie_enabled';
  static const _onboardKey = 'onboarded';

  List<NoteModel> _notes = [];
  List<TagModel> _tags = [];
  ThemeMode _themeMode = ThemeMode.dark;
  String _pin = '';
  bool _pinEnabled = false;
  bool _animationsEnabled = true;
  bool _lottieEnabled = true;
  bool _onboarded = false;
  bool _isLocked = false;

  List<NoteModel> get notes => List.unmodifiable(_notes);
  List<TagModel> get tags => List.unmodifiable(_tags);
  ThemeMode get themeMode => _themeMode;
  String get pin => _pin;
  bool get pinEnabled => _pinEnabled;
  bool get animationsEnabled => _animationsEnabled;
  bool get lottieEnabled => _lottieEnabled;
  bool get onboarded => _onboarded;
  bool get isLocked => _isLocked;

  final _uuid = const Uuid();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboarded = prefs.getBool(_onboardKey) ?? false;
    _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? 1];
    _pin = prefs.getString(_pinKey) ?? '';
    _pinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
    _animationsEnabled = prefs.getBool(_animKey) ?? true;
    _lottieEnabled = prefs.getBool(_lottieKey) ?? true;
    _isLocked = _pinEnabled;

    final notesJson = prefs.getStringList(_notesKey) ?? [];
    _notes = notesJson.map((j) => NoteModel.fromJson(j)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final tagsJson = prefs.getStringList(_tagsKey) ?? [];
    _tags = tagsJson
        .map((j) => TagModel.fromMap(jsonDecode(j) as Map<String, dynamic>))
        .toList();

    notifyListeners();
  }

  // ── Notes CRUD ──────────────────────────────────────────────

  Future<void> addNote(String content, Mood mood, List<String> tags) async {
    final note = NoteModel(
      id: _uuid.v4(),
      content: content,
      mood: mood,
      tags: tags,
      createdAt: DateTime.now(),
    );
    _notes.insert(0, note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(String id, String content, Mood mood, List<String> tags) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notes[idx] = _notes[idx].copyWith(
      content: content,
      mood: mood,
      tags: tags,
      updatedAt: DateTime.now(),
    );
    await _saveNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_notesKey, _notes.map((n) => n.toJson()).toList());
  }

  // ── Tags ────────────────────────────────────────────────────

  Future<void> addTag(TagModel tag) async {
    if (_tags.any((t) => t.name == tag.name)) return;
    _tags.add(tag);
    await _saveTags();
    notifyListeners();
  }

  Future<void> deleteTag(String name) async {
    _tags.removeWhere((t) => t.name == name);
    // remove from all notes
    for (int i = 0; i < _notes.length; i++) {
      if (_notes[i].tags.contains(name)) {
        _notes[i] = _notes[i].copyWith(
          tags: _notes[i].tags.where((t) => t != name).toList(),
        );
      }
    }
    await _saveTags();
    await _saveNotes();
    notifyListeners();
  }

  Future<void> _saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tagsKey, _tags.map((t) => jsonEncode(t.toMap())).toList());
  }

  // ── Settings ────────────────────────────────────────────────

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setPin(String newPin) async {
    _pin = newPin;
    _pinEnabled = newPin.isNotEmpty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    await prefs.setBool(_pinEnabledKey, _pinEnabled);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _pin = '';
    _pinEnabled = false;
    _isLocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, '');
    await prefs.setBool(_pinEnabledKey, false);
    notifyListeners();
  }

  bool verifyPin(String input) {
    if (input == _pin) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockApp() {
    if (_pinEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<void> setAnimations(bool value) async {
    _animationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animKey, value);
    notifyListeners();
  }

  Future<void> setLottie(bool value) async {
    _lottieEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lottieKey, value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardKey, true);
    notifyListeners();
  }

  Future<void> resetData() async {
    _notes = [];
    _tags = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
    await prefs.remove(_tagsKey);
    notifyListeners();
  }

  // ── Analytics helpers ────────────────────────────────────────

  Map<Mood, int> getMoodDistribution() {
    final map = <Mood, int>{};
    for (final n in _notes) {
      map[n.mood] = (map[n.mood] ?? 0) + 1;
    }
    return map;
  }

  Map<int, int> getWeeklyMoodScores() {
    final now = DateTime.now();
    final map = <int, int>{};
    for (int i = 0; i < 7; i++) {
      map[i] = 0;
    }
    for (final n in _notes) {
      final diff = now.difference(n.createdAt).inDays;
      if (diff < 7) {
        final day = 6 - diff;
        map[day] = (map[day] ?? 0) + n.mood.score;
      }
    }
    return map;
  }

  int getStreak() {
    if (_notes.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    DateTime check = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 365; i++) {
      final hasNote = _notes.any((n) {
        final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
        return d == check;
      });
      if (hasNote) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, int> getTagUsage() {
    final map = <String, int>{};
    for (final n in _notes) {
      for (final t in n.tags) {
        map[t] = (map[t] ?? 0) + 1;
      }
    }
    return map;
  }

  List<String> getInsights() {
    if (_notes.isEmpty) return ['Start journaling to unlock insights!'];
    final insights = <String>[];

    // Day of week analysis
    final dayCounts = List.filled(7, 0);
    final dayScores = List.filled(7, 0);
    for (final n in _notes) {
      final d = n.createdAt.weekday - 1;
      dayCounts[d]++;
      dayScores[d] += n.mood.score;
    }
    final bestDay = dayScores.indexOf(dayScores.reduce((a, b) => a > b ? a : b));
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (dayCounts[bestDay] > 0) {
      insights.add('You feel happiest on ${days[bestDay]}s 🌟');
    }

    // Time of day
    int morning = 0, afternoon = 0, evening = 0, night = 0;
    for (final n in _notes) {
      final h = n.createdAt.hour;
      if (h < 12) morning++;
      else if (h < 17) afternoon++;
      else if (h < 21) evening++;
      else night++;
    }
    final maxTime = [morning, afternoon, evening, night].reduce((a, b) => a > b ? a : b);
    if (maxTime == night) insights.add('Most of your thoughts flow at night 🌙');
    else if (maxTime == morning) insights.add('You\'re a morning journaler ☀️');
    else if (maxTime == evening) insights.add('Evenings spark your reflection 🌆');

    // Frequent tags
    final tagUsage = getTagUsage();
    if (tagUsage.isNotEmpty) {
      final topTag = tagUsage.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('"${topTag.key}" appears in ${topTag.value} notes 🏷️');
    }

    // Streak
    final streak = getStreak();
    if (streak >= 3) insights.add('$streak-day journaling streak! Keep going 🔥');

    // Total
    insights.add('You\'ve captured ${_notes.length} thoughts so far 📝');

    return insights;
  }

  // ── Heatmap ──────────────────────────────────────────────────

  Map<DateTime, int> getHeatmapData() {
    final map = <DateTime, int>{};
    for (final n in _notes) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      map[d] = (map[d] ?? 0) + 1;
    }
    return map;
  }
}
