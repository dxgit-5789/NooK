class DocumentModel {
  final String id;
  final String title;
  final String filename;
  final String path;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isPinned;
  final bool isFavorite;
  final int wordCount;
  final int characterCount;
  final int lineCount;
  final DateTime? lastOpenedAt;
  final String searchIndex;

  DocumentModel({
    required this.id,
    required this.title,
    required this.filename,
    required this.path,
    required this.createdAt,
    required this.modifiedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.wordCount = 0,
    this.characterCount = 0,
    this.lineCount = 0,
    this.lastOpenedAt,
    this.searchIndex = '',
  });

  int get readingTimeMinutes => (wordCount / 200).ceil();

  DocumentModel copyWith({
    String? id,
    String? title,
    String? filename,
    String? path,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isPinned,
    bool? isFavorite,
    int? wordCount,
    int? characterCount,
    int? lineCount,
    DateTime? lastOpenedAt,
    String? searchIndex,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filename: filename ?? this.filename,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      lineCount: lineCount ?? this.lineCount,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      searchIndex: searchIndex ?? this.searchIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filename': filename,
      'path': path,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'is_pinned': isPinned ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'word_count': wordCount,
      'character_count': characterCount,
      'line_count': lineCount,
      'last_opened_at': lastOpenedAt?.toIso8601String(),
      'search_index': searchIndex,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      filename: map['filename'] as String,
      path: map['path'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      modifiedAt: DateTime.parse(map['modified_at'] as String),
      isPinned: (map['is_pinned'] as int) == 1,
      isFavorite: (map['is_favorite'] as int) == 1,
      wordCount: map['word_count'] as int,
      characterCount: map['character_count'] as int,
      lineCount: map['line_count'] as int,
      lastOpenedAt: map['last_opened_at'] != null
          ? DateTime.parse(map['last_opened_at'] as String)
          : null,
      searchIndex: map['search_index'] as String,
    );
  }
}
