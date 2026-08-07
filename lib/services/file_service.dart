import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';
import 'database_service.dart';
import 'workspace_service.dart';

class FileService {
  static const _uuid = Uuid();

  static Future<DocumentModel?> createDocument({
    required String workspacePath,
    String? title,
    String? content,
  }) async {
    try {
      final id = _uuid.v4();
      final filename = '$id.txt';
      final filePath = path.join(
        WorkspaceService.getDocumentsPath(workspacePath),
        filename,
      );

      final actualTitle = title ?? 'Untitled';
      final actualContent = content ?? '';
      final fullContent = actualContent.isEmpty ? actualTitle : actualContent;

      final file = File(filePath);
      await file.writeAsString(fullContent);

      final stat = await file.stat();
      final lines = fullContent.split('\n');
      final firstLine = lines.isNotEmpty ? lines.first.trim() : '';
      final documentTitle = firstLine.isNotEmpty ? firstLine : actualTitle;

      final document = DocumentModel(
        id: id,
        title: documentTitle,
        filename: filename,
        path: filePath,
        createdAt: stat.changed,
        modifiedAt: stat.modified,
        wordCount: _countWords(fullContent),
        characterCount: fullContent.length,
        lineCount: lines.length,
        searchIndex: '${documentTitle.toLowerCase()} ${filename.toLowerCase()} ${fullContent.toLowerCase()}',
      );

      await DatabaseService.insertDocument(document);
      return document;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> readDocument(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveDocument({
    required String filePath,
    required String content,
    required String id,
  }) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);

      final stat = await file.stat();
      final lines = content.split('\n');
      final firstLine = lines.isNotEmpty ? lines.first.trim() : '';
      final title = firstLine.isNotEmpty ? firstLine : path.basenameWithoutExtension(filePath);

      final existingDoc = await DatabaseService.getDocument(id);
      if (existingDoc != null) {
        final updatedDoc = existingDoc.copyWith(
          title: title,
          modifiedAt: stat.modified,
          wordCount: _countWords(content),
          characterCount: content.length,
          lineCount: lines.length,
          searchIndex: '${title.toLowerCase()} ${existingDoc.filename.toLowerCase()} ${content.toLowerCase()}',
        );
        await DatabaseService.updateDocument(updatedDoc);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> renameDocument({
    required String oldPath,
    required String newTitle,
    required String id,
  }) async {
    try {
      final content = await readDocument(oldPath);
      if (content == null) return false;

      final lines = content.split('\n');
      final newContent = lines.isEmpty ? newTitle : [newTitle, ...lines.skip(1)].join('\n');

      final file = File(oldPath);
      await file.writeAsString(newContent);

      final stat = await file.stat();
      final existingDoc = await DatabaseService.getDocument(id);
      if (existingDoc != null) {
        final updatedDoc = existingDoc.copyWith(
          title: newTitle,
          modifiedAt: stat.modified,
          wordCount: _countWords(newContent),
          characterCount: newContent.length,
          lineCount: newContent.split('\n').length,
          searchIndex: '${newTitle.toLowerCase()} ${existingDoc.filename.toLowerCase()} ${newContent.toLowerCase()}',
        );
        await DatabaseService.updateDocument(updatedDoc);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<DocumentModel?> duplicateDocument({
    required String workspacePath,
    required String sourceId,
  }) async {
    try {
      final sourceDoc = await DatabaseService.getDocument(sourceId);
      if (sourceDoc == null) return null;

      final content = await readDocument(sourceDoc.path);
      if (content == null) return null;

      return await createDocument(
        workspacePath: workspacePath,
        title: '${sourceDoc.title} (Copy)',
        content: content,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> moveToTrash({
    required String workspacePath,
    required String id,
  }) async {
    try {
      final doc = await DatabaseService.getDocument(id);
      if (doc == null) return false;

      final sourceFile = File(doc.path);
      if (!await sourceFile.exists()) return false;

      final trashPath = path.join(
        WorkspaceService.getTrashPath(workspacePath),
        doc.filename,
      );

      await sourceFile.rename(trashPath);

      final updatedDoc = doc.copyWith(path: trashPath);
      await DatabaseService.updateDocument(updatedDoc);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> restoreFromTrash({
    required String workspacePath,
    required String id,
  }) async {
    try {
      final doc = await DatabaseService.getDocument(id);
      if (doc == null) return false;

      final sourceFile = File(doc.path);
      if (!await sourceFile.exists()) return false;

      final documentsPath = path.join(
        WorkspaceService.getDocumentsPath(workspacePath),
        doc.filename,
      );

      await sourceFile.rename(documentsPath);

      final updatedDoc = doc.copyWith(path: documentsPath);
      await DatabaseService.updateDocument(updatedDoc);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteDocumentPermanently({
    required String id,
  }) async {
    try {
      final doc = await DatabaseService.getDocument(id);
      if (doc == null) return false;

      final file = File(doc.path);
      if (await file.exists()) {
        await file.delete();
      }

      await DatabaseService.deleteDocument(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> togglePin(String id) async {
    try {
      final doc = await DatabaseService.getDocument(id);
      if (doc == null) return false;

      final updatedDoc = doc.copyWith(isPinned: !doc.isPinned);
      await DatabaseService.updateDocument(updatedDoc);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleFavorite(String id) async {
    try {
      final doc = await DatabaseService.getDocument(id);
      if (doc == null) return false;

      final updatedDoc = doc.copyWith(isFavorite: !doc.isFavorite);
      await DatabaseService.updateDocument(updatedDoc);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateLastOpened(String id) async {
    try {
      final doc = await DatabaseService.getDocument(id);
      if (doc == null) return false;

      final updatedDoc = doc.copyWith(lastOpenedAt: DateTime.now());
      await DatabaseService.updateDocument(updatedDoc);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<DocumentModel?> importTextFile({
    required String workspacePath,
    required String sourcePath,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final content = await sourceFile.readAsString();
      final lines = content.split('\n');
      final firstLine = lines.isNotEmpty ? lines.first.trim() : '';
      final title = firstLine.isNotEmpty ? firstLine : path.basenameWithoutExtension(sourcePath);

      return await createDocument(
        workspacePath: workspacePath,
        title: title,
        content: content,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> exportDocument({
    required String documentPath,
    required String destinationPath,
  }) async {
    try {
      final sourceFile = File(documentPath);
      if (!await sourceFile.exists()) return false;

      await sourceFile.copy(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> revealInExplorer(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      await Process.run('explorer', ['/select,', filePath]);
      return true;
    } catch (e) {
      return false;
    }
  }

  static int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
}
