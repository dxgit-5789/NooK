import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import '../models/document_model.dart';

class DatabaseService {
  static Database? _database;

  static Future<void> initialize(String workspacePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = path.join(workspacePath, 'Database', 'nook.db');
    final dbDir = Directory(path.dirname(dbPath));

    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        filename TEXT NOT NULL,
        path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        modified_at TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        word_count INTEGER NOT NULL DEFAULT 0,
        character_count INTEGER NOT NULL DEFAULT 0,
        line_count INTEGER NOT NULL DEFAULT 0,
        last_opened_at TEXT,
        search_index TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_title ON documents(title)
    ''');

    await db.execute('''
      CREATE INDEX idx_filename ON documents(filename)
    ''');

    await db.execute('''
      CREATE INDEX idx_search_index ON documents(search_index)
    ''');

    await db.execute('''
      CREATE INDEX idx_modified_at ON documents(modified_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_last_opened_at ON documents(last_opened_at)
    ''');
  }

  static Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  static Future<void> insertDocument(DocumentModel document) async {
    await database.insert(
      'documents',
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateDocument(DocumentModel document) async {
    await database.update(
      'documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  static Future<void> deleteDocument(String id) async {
    await database.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<DocumentModel?> getDocument(String id) async {
    final results = await database.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DocumentModel.fromMap(results.first);
  }

  static Future<List<DocumentModel>> getAllDocuments() async {
    final results = await database.query(
      'documents',
      orderBy: 'modified_at DESC',
    );

    return results.map((map) => DocumentModel.fromMap(map)).toList();
  }

  static Future<List<DocumentModel>> getRecentDocuments({int limit = 10}) async {
    final results = await database.query(
      'documents',
      orderBy: 'last_opened_at DESC',
      limit: limit,
    );

    return results.map((map) => DocumentModel.fromMap(map)).toList();
  }

  static Future<List<DocumentModel>> getPinnedDocuments() async {
    final results = await database.query(
      'documents',
      where: 'is_pinned = ?',
      whereArgs: [1],
      orderBy: 'modified_at DESC',
    );

    return results.map((map) => DocumentModel.fromMap(map)).toList();
  }

  static Future<List<DocumentModel>> getFavoriteDocuments() async {
    final results = await database.query(
      'documents',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'modified_at DESC',
    );

    return results.map((map) => DocumentModel.fromMap(map)).toList();
  }

  static Future<List<DocumentModel>> searchDocuments(String query) async {
    if (query.isEmpty) return [];

    final searchTerm = '%${query.toLowerCase()}%';
    final results = await database.query(
      'documents',
      where: 'search_index LIKE ?',
      whereArgs: [searchTerm],
      orderBy: 'modified_at DESC',
    );

    return results.map((map) => DocumentModel.fromMap(map)).toList();
  }

  static Future<void> rebuildFromFiles(String workspacePath) async {
    await database.delete('documents');

    final documentsDir = Directory(path.join(workspacePath, 'Documents'));
    if (!await documentsDir.exists()) return;

    final files = await documentsDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.txt'))
        .cast<File>()
        .toList();

    for (final file in files) {
      try {
        final content = await file.readAsString();
        final stat = await file.stat();
        final filename = path.basename(file.path);
        final lines = content.split('\n');
        final firstLine = lines.isNotEmpty ? lines.first.trim() : '';
        final title = firstLine.isNotEmpty ? firstLine : filename;

        final document = DocumentModel(
          id: path.basenameWithoutExtension(filename),
          title: title,
          filename: filename,
          path: file.path,
          createdAt: stat.changed,
          modifiedAt: stat.modified,
          wordCount: _countWords(content),
          characterCount: content.length,
          lineCount: lines.length,
          searchIndex: '${title.toLowerCase()} ${filename.toLowerCase()} ${content.toLowerCase()}',
        );

        await insertDocument(document);
      } catch (e) {
        continue;
      }
    }
  }

  static int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
