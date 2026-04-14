import 'dart:convert';

enum Mood { happy, neutral, sad, angry, anxious, excited, tired, grateful }

extension MoodExt on Mood {
  String get emoji {
    const e = ['😊', '😐', '😢', '😠', '😰', '🤩', '😴', '🙏'];
    return e[index];
  }

  String get label {
    const l = ['Happy', 'Neutral', 'Sad', 'Angry', 'Anxious', 'Excited', 'Tired', 'Grateful'];
    return l[index];
  }

  int get score {
    const s = [5, 3, 1, 1, 2, 5, 2, 4];
    return s[index];
  }
}

class NoteModel {
  final String id;
  final String content;
  final Mood mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NoteModel({
    required this.id,
    required this.content,
    required this.mood,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  NoteModel copyWith({
    String? content,
    Mood? mood,
    List<String>? tags,
    DateTime? updatedAt,
  }) =>
      NoteModel(
        id: id,
        content: content ?? this.content,
        mood: mood ?? this.mood,
        tags: tags ?? this.tags,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'mood': mood.index,
        'tags': tags,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
        id: map['id'],
        content: map['content'],
        mood: Mood.values[map['mood'] ?? 0],
        tags: List<String>.from(map['tags'] ?? []),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
            : null,
      );

  String toJson() => jsonEncode(toMap());
  factory NoteModel.fromJson(String s) => NoteModel.fromMap(jsonDecode(s));
}

class TagModel {
  final String name;
  final int colorIndex;

  TagModel({required this.name, required this.colorIndex});

  Map<String, dynamic> toMap() => {'name': name, 'colorIndex': colorIndex};
  factory TagModel.fromMap(Map<String, dynamic> m) =>
      TagModel(name: m['name'], colorIndex: m['colorIndex']);
}
