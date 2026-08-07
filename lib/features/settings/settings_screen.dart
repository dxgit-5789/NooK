import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/app_provider.dart';
import '../../services/settings_service.dart';
import '../../services/workspace_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  double _editorFontSize = 16.0;
  int _autosaveInterval = 30;
  String _workspacePath = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await SettingsService.getThemeMode();
    final editorFontSize = await SettingsService.getEditorFontSize();
    final autosaveInterval = await SettingsService.getAutosaveInterval();
    final workspacePath = await WorkspaceService.getWorkspacePath() ?? '';

    setState(() {
      _themeMode = themeMode;
      _editorFontSize = editorFontSize;
      _autosaveInterval = autosaveInterval;
      _workspacePath = workspacePath;
    });
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.setThemeMode(mode);
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _changeEditorFontSize(double size) async {
    await SettingsService.setEditorFontSize(size);
    setState(() {
      _editorFontSize = size;
    });
  }

  Future<void> _changeAutosaveInterval(int seconds) async {
    await SettingsService.setAutosaveInterval(seconds);
    setState(() {
      _autosaveInterval = seconds;
    });
  }

  Future<void> _changeWorkspace() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select New Workspace Location',
    );

    if (result != null && mounted) {
      final success = await WorkspaceService.initializeWorkspace(result);
      if (success) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.setWorkspace(result);
        setState(() {
          _workspacePath = result;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workspace changed successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to change workspace')),
          );
        }
      }
    }
  }

  Future<void> _rebuildDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rebuild Database'),
        content: const Text(
          'This will scan all text files in your Documents folder and rebuild the metadata database. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rebuild'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.rebuildDatabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database rebuilt successfully')),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all settings to their default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SettingsService.resetToDefaults();
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.setThemeMode(ThemeMode.system);
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 16),
          _buildCard(
            context,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.brightness_6_rounded, color: colorScheme.primary),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeText()),
                  trailing: DropdownButton<ThemeMode>(
                    value: _themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode != null) _changeThemeMode(mode);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Editor'),
          const SizedBox(height: 16),
          _buildCard(
            context,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.text_fields_rounded, color: colorScheme.primary),
                  title: const Text('Font Size'),
                  subtitle: Text('${_editorFontSize.toInt()}pt'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: _editorFontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: '${_editorFontSize.toInt()}pt',
                    onChanged: _changeEditorFontSize,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.save_rounded, color: colorScheme.primary),
                  title: const Text('Autosave Interval'),
                  subtitle: Text('$_autosaveInterval seconds'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: _autosaveInterval.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    label: '$_autosaveInterval seconds',
                    onChanged: (value) => _changeAutosaveInterval(value.toInt()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Workspace'),
          const SizedBox(height: 16),
          _buildCard(
            context,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.folder_rounded, color: colorScheme.primary),
                  title: const Text('Workspace Location'),
                  subtitle: Text(
                    _workspacePath.isEmpty ? 'Not set' : _workspacePath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton(
                    onPressed: _changeWorkspace,
                    child: const Text('Change'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.refresh_rounded, color: colorScheme.primary),
                  title: const Text('Rebuild Database'),
                  subtitle: const Text('Scan and rebuild metadata from files'),
                  trailing: TextButton(
                    onPressed: _rebuildDatabase,
                    child: const Text('Rebuild'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Advanced'),
          const SizedBox(height: 16),
          _buildCard(
            context,
            child: ListTile(
              leading: Icon(Icons.restart_alt_rounded, color: colorScheme.error),
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Reset all settings to default values'),
              trailing: TextButton(
                onPressed: _resetToDefaults,
                child: const Text('Reset'),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 16),
          _buildCard(
            context,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
                  title: const Text('NooK'),
                  subtitle: const Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Description'),
                  subtitle: Text(
                    'A completely offline, local-first desktop text editor and note management application.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Card(
      child: child,
    );
  }

  String _getThemeModeText() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      default:
        return 'Follow system';
    }
  }
}
