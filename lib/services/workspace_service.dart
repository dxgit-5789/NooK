import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class WorkspaceService {
  static const String _workspaceKey = 'workspace_path';
  static String? _currentWorkspace;

  static Future<String?> getWorkspacePath() async {
    if (_currentWorkspace != null) return _currentWorkspace;

    final prefs = await SharedPreferences.getInstance();
    _currentWorkspace = prefs.getString(_workspaceKey);
    return _currentWorkspace;
  }

  static Future<void> setWorkspacePath(String workspacePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workspaceKey, workspacePath);
    _currentWorkspace = workspacePath;
  }

  static Future<bool> initializeWorkspace(String workspacePath) async {
    try {
      final workspaceDir = Directory(workspacePath);
      if (!await workspaceDir.exists()) {
        await workspaceDir.create(recursive: true);
      }

      final documentsDir = Directory(path.join(workspacePath, 'Documents'));
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final trashDir = Directory(path.join(workspacePath, 'Trash'));
      if (!await trashDir.exists()) {
        await trashDir.create(recursive: true);
      }

      final databaseDir = Directory(path.join(workspacePath, 'Database'));
      if (!await databaseDir.exists()) {
        await databaseDir.create(recursive: true);
      }

      final settingsDir = Directory(path.join(workspacePath, 'Settings'));
      if (!await settingsDir.exists()) {
        await settingsDir.create(recursive: true);
      }

      await setWorkspacePath(workspacePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> validateWorkspace(String workspacePath) async {
    try {
      final workspaceDir = Directory(workspacePath);
      if (!await workspaceDir.exists()) return false;

      final documentsDir = Directory(path.join(workspacePath, 'Documents'));
      final trashDir = Directory(path.join(workspacePath, 'Trash'));
      final databaseDir = Directory(path.join(workspacePath, 'Database'));
      final settingsDir = Directory(path.join(workspacePath, 'Settings'));

      return await documentsDir.exists() &&
          await trashDir.exists() &&
          await databaseDir.exists() &&
          await settingsDir.exists();
    } catch (e) {
      return false;
    }
  }

  static String getDocumentsPath(String workspacePath) {
    return path.join(workspacePath, 'Documents');
  }

  static String getTrashPath(String workspacePath) {
    return path.join(workspacePath, 'Trash');
  }

  static String getDatabasePath(String workspacePath) {
    return path.join(workspacePath, 'Database');
  }

  static String getSettingsPath(String workspacePath) {
    return path.join(workspacePath, 'Settings');
  }
}
