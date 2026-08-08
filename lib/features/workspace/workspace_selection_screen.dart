import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/app_provider.dart';
import '../../services/workspace_service.dart';

class WorkspaceSelectionScreen extends StatefulWidget {
  const WorkspaceSelectionScreen({super.key});

  @override
  State<WorkspaceSelectionScreen> createState() => _WorkspaceSelectionScreenState();
}

class _WorkspaceSelectionScreenState extends State<WorkspaceSelectionScreen> {
  String? _selectedPath;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingWorkspace();
  }

  Future<void> _checkExistingWorkspace() async {
    final workspacePath = await WorkspaceService.getWorkspacePath();
    if (workspacePath != null && mounted) {
      final isValid = await WorkspaceService.validateWorkspace(workspacePath);
      if (isValid) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _selectWorkspace() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Workspace Location',
    );

    if (result != null) {
      setState(() {
        _selectedPath = result;
        _errorMessage = null;
      });
    }
  }

  Future<void> _initializeWorkspace() async {
    if (_selectedPath == null) {
      setState(() {
        _errorMessage = 'Please select a workspace location';
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final success = await WorkspaceService.initializeWorkspace(_selectedPath!);

    if (success && mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.setWorkspace(_selectedPath!);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to initialize workspace. Please try another location.';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Icon(
                  Icons.folder_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Choose Your Workspace',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a folder where NooK will store your documents, settings, and database.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Workspace Structure',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStructureItem(context, 'Documents/', 'Your text files'),
                      _buildStructureItem(context, 'Trash/', 'Deleted documents'),
                      _buildStructureItem(context, 'Database/', 'Document metadata'),
                      _buildStructureItem(context, 'Settings/', 'Application settings'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (_selectedPath != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedPath!,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isInitializing ? null : _selectWorkspace,
                        icon: const Icon(Icons.folder_open_rounded),
                        label: const Text('Browse'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: BorderSide(color: colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isInitializing ? null : _initializeWorkspace,
                        icon: _isInitializing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded),
                        label: Text(_isInitializing ? 'Initializing...' : 'Continue'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

  Widget _buildStructureItem(BuildContext context, String name, String description) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.folder_outlined,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Consolas',
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
