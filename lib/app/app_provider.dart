import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';
import '../services/workspace_service.dart';

class AppProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String? _workspacePath;
  List<DocumentModel> _documents = [];
  List<DocumentModel> _recentDocuments = [];
  List<DocumentModel> _pinnedDocuments = [];
  List<DocumentModel> _favoriteDocuments = [];
  List<DocumentModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  ThemeMode get themeMode => _themeMode;
  String? get workspacePath => _workspacePath;
  List<DocumentModel> get documents => _documents;
  List<DocumentModel> get recentDocuments => _recentDocuments;
  List<DocumentModel> get pinnedDocuments => _pinnedDocuments;
  List<DocumentModel> get favoriteDocuments => _favoriteDocuments;
  List<DocumentModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> initialize() async {
    _themeMode = await SettingsService.getThemeMode();
    _workspacePath = await WorkspaceService.getWorkspacePath();

    if (_workspacePath != null) {
      await DatabaseService.initialize(_workspacePath!);
      await refreshDocuments();
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await SettingsService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setWorkspace(String path) async {
    _workspacePath = path;
    await WorkspaceService.setWorkspacePath(path);
    await DatabaseService.initialize(path);
    await refreshDocuments();
    notifyListeners();
  }

  Future<void> refreshDocuments() async {
    if (_workspacePath == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _documents = await DatabaseService.getAllDocuments();
      _recentDocuments = await DatabaseService.getRecentDocuments(limit: 10);
      _pinnedDocuments = await DatabaseService.getPinnedDocuments();
      _favoriteDocuments = await DatabaseService.getFavoriteDocuments();

      if (_searchQuery.isNotEmpty) {
        _searchResults = await DatabaseService.searchDocuments(_searchQuery);
      }
    } catch (e) {
      _documents = [];
      _recentDocuments = [];
      _pinnedDocuments = [];
      _favoriteDocuments = [];
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<DocumentModel?> createDocument({String? title, String? content}) async {
    if (_workspacePath == null) return null;

    final doc = await FileService.createDocument(
      workspacePath: _workspacePath!,
      title: title,
      content: content,
    );

    if (doc != null) {
      await refreshDocuments();
    }

    return doc;
  }

  Future<bool> saveDocument({
    required String filePath,
    required String content,
    required String id,
  }) async {
    final result = await FileService.saveDocument(
      filePath: filePath,
      content: content,
      id: id,
    );

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<bool> renameDocument({
    required String oldPath,
    required String newTitle,
    required String id,
  }) async {
    final result = await FileService.renameDocument(
      oldPath: oldPath,
      newTitle: newTitle,
      id: id,
    );

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<DocumentModel?> duplicateDocument(String sourceId) async {
    if (_workspacePath == null) return null;

    final doc = await FileService.duplicateDocument(
      workspacePath: _workspacePath!,
      sourceId: sourceId,
    );

    if (doc != null) {
      await refreshDocuments();
    }

    return doc;
  }

  Future<bool> moveToTrash(String id) async {
    if (_workspacePath == null) return false;

    final result = await FileService.moveToTrash(
      workspacePath: _workspacePath!,
      id: id,
    );

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<bool> restoreFromTrash(String id) async {
    if (_workspacePath == null) return false;

    final result = await FileService.restoreFromTrash(
      workspacePath: _workspacePath!,
      id: id,
    );

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<bool> deleteDocumentPermanently(String id) async {
    final result = await FileService.deleteDocumentPermanently(id: id);

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<bool> togglePin(String id) async {
    final result = await FileService.togglePin(id);

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<bool> toggleFavorite(String id) async {
    final result = await FileService.toggleFavorite(id);

    if (result) {
      await refreshDocuments();
    }

    return result;
  }

  Future<bool> updateLastOpened(String id) async {
    return await FileService.updateLastOpened(id);
  }

  Future<DocumentModel?> importTextFile(String sourcePath) async {
    if (_workspacePath == null) return null;

    final doc = await FileService.importTextFile(
      workspacePath: _workspacePath!,
      sourcePath: sourcePath,
    );

    if (doc != null) {
      await refreshDocuments();
    }

    return doc;
  }

  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = await DatabaseService.searchDocuments(query);
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> rebuildDatabase() async {
    if (_workspacePath == null) return;

    _isLoading = true;
    notifyListeners();

    await DatabaseService.rebuildFromFiles(_workspacePath!);
    await refreshDocuments();

    _isLoading = false;
    notifyListeners();
  }
}
