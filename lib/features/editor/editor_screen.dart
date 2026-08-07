import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../app/app_provider.dart';
import '../../models/document_model.dart';
import '../../services/file_service.dart';
import '../../services/settings_service.dart';

class EditorScreen extends StatefulWidget {
  final DocumentModel document;

  const EditorScreen({super.key, required this.document});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _contentController;
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();

  String _originalContent = '';
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showFindReplace = false;
  Timer? _autosaveTimer;
  int _autosaveInterval = 30;
  double _fontSize = 16.0;
  double _zoom = 1.0;

  int _wordCount = 0;
  int _characterCount = 0;
  int _lineCount = 0;
  int _cursorLine = 1;
  int _cursorColumn = 1;

  final UndoHistoryController _undoController = UndoHistoryController();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _loadDocument();
    _loadSettings();
    _contentController.addListener(_onContentChanged);
    _startAutosave();
  }

  Future<void> _loadSettings() async {
    final fontSize = await SettingsService.getEditorFontSize();
    final autosaveInterval = await SettingsService.getAutosaveInterval();
    setState(() {
      _fontSize = fontSize;
      _autosaveInterval = autosaveInterval;
    });
  }

  Future<void> _loadDocument() async {
    final content = await FileService.readDocument(widget.document.path);
    if (content != null) {
      setState(() {
        _originalContent = content;
        _contentController.text = content;
        _isLoading = false;
        _updateStats();
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onContentChanged() {
    final content = _contentController.text;
    setState(() {
      _hasUnsavedChanges = content != _originalContent;
      _updateStats();
    });
  }

  void _updateStats() {
    final text = _contentController.text;
    final lines = text.split('\n');

    setState(() {
      _characterCount = text.length;
      _lineCount = lines.length;
      _wordCount = text.isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

      final cursorPosition = _contentController.selection.baseOffset;
      if (cursorPosition >= 0) {
        final textBeforeCursor = text.substring(0, cursorPosition);
        _cursorLine = '\n'.allMatches(textBeforeCursor).length + 1;
        _cursorColumn = cursorPosition - textBeforeCursor.lastIndexOf('\n');
      }
    });
  }

  void _startAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(Duration(seconds: _autosaveInterval), (timer) {
      if (_hasUnsavedChanges && !_isSaving) {
        _saveDocument(showSnackbar: false);
      }
    });
  }

  Future<void> _saveDocument({bool showSnackbar = true}) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final success = await appProvider.saveDocument(
      filePath: widget.document.path,
      content: _contentController.text,
      id: widget.document.id,
    );

    setState(() {
      _isSaving = false;
      if (success) {
        _originalContent = _contentController.text;
        _hasUnsavedChanges = false;
      }
    });

    if (showSnackbar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Document saved' : 'Failed to save document'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleFindReplace() {
    setState(() {
      _showFindReplace = !_showFindReplace;
      if (!_showFindReplace) {
        _findController.clear();
        _replaceController.clear();
      }
    });
  }

  void _find() {
    final query = _findController.text;
    if (query.isEmpty) return;

    final text = _contentController.text;
    final currentPosition = _contentController.selection.baseOffset;
    final index = text.indexOf(query, currentPosition);

    if (index != -1) {
      _contentController.selection = TextSelection(
        baseOffset: index,
        extentOffset: index + query.length,
      );
    } else {
      final indexFromStart = text.indexOf(query);
      if (indexFromStart != -1) {
        _contentController.selection = TextSelection(
          baseOffset: indexFromStart,
          extentOffset: indexFromStart + query.length,
        );
      }
    }
  }

  void _replace() {
    final find = _findController.text;
    final replace = _replaceController.text;
    if (find.isEmpty) return;

    final selection = _contentController.selection;
    final selectedText = _contentController.text.substring(
      selection.baseOffset,
      selection.extentOffset,
    );

    if (selectedText == find) {
      final newText = _contentController.text.replaceRange(
        selection.baseOffset,
        selection.extentOffset,
        replace,
      );
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset + replace.length,
        ),
      );
      _find();
    }
  }

  void _replaceAll() {
    final find = _findController.text;
    final replace = _replaceController.text;
    if (find.isEmpty) return;

    final newText = _contentController.text.replaceAll(find, replace);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: 0),
    );
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 0.1).clamp(0.5, 2.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 0.1).clamp(0.5, 2.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoom = 1.0;
    });
  }

  Future<void> _showDocumentMenu() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(widget.document.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                title: Text(widget.document.isPinned ? 'Unpin' : 'Pin'),
                onTap: () async {
                  await appProvider.togglePin(widget.document.id);
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(widget.document.isFavorite ? Icons.star : Icons.star_outline),
                title: Text(widget.document.isFavorite ? 'Remove from favorites' : 'Add to favorites'),
                onTap: () async {
                  await appProvider.toggleFavorite(widget.document.id);
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Duplicate'),
                onTap: () async {
                  await appProvider.duplicateDocument(widget.document.id);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document duplicated')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Reveal in File Explorer'),
                onTap: () async {
                  await FileService.revealInExplorer(widget.document.path);
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Move to Trash'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Move to Trash'),
                      content: const Text('Are you sure you want to move this document to trash?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Move to Trash'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await appProvider.moveToTrash(widget.document.id);
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save before closing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return false;
    if (result == true) {
      await _saveDocument(showSnackbar: false);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.document.title,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            if (_hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unsaved',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              onPressed: _toggleFindReplace,
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Find & Replace',
            ),
            IconButton(
              onPressed: _isSaving ? null : () => _saveDocument(),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              tooltip: 'Save',
            ),
            IconButton(
              onPressed: _showDocumentMenu,
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'More',
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            : Column(
                children: [
                  if (_showFindReplace) _buildFindReplaceBar(colorScheme),
                  Expanded(
                    child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const _SaveIntent(),
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const _FindIntent(),
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH): const _ReplaceIntent(),
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.equal): const _ZoomInIntent(),
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.minus): const _ZoomOutIntent(),
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit0): const _ResetZoomIntent(),
                      },
                      child: Actions(
                        actions: <Type, Action<Intent>>{
                          _SaveIntent: CallbackAction<_SaveIntent>(
                            onInvoke: (_) => _saveDocument(),
                          ),
                          _FindIntent: CallbackAction<_FindIntent>(
                            onInvoke: (_) {
                              _toggleFindReplace();
                              return null;
                            },
                          ),
                          _ReplaceIntent: CallbackAction<_ReplaceIntent>(
                            onInvoke: (_) {
                              _toggleFindReplace();
                              return null;
                            },
                          ),
                          _ZoomInIntent: CallbackAction<_ZoomInIntent>(
                            onInvoke: (_) {
                              _zoomIn();
                              return null;
                            },
                          ),
                          _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
                            onInvoke: (_) {
                              _zoomOut();
                              return null;
                            },
                          ),
                          _ResetZoomIntent: CallbackAction<_ResetZoomIntent>(
                            onInvoke: (_) {
                              _resetZoom();
                              return null;
                            },
                          ),
                        },
                        child: _buildEditor(colorScheme),
                      ),
                    ),
                  ),
                  _buildStatusBar(colorScheme),
                ],
              ),
      ),
    );
  }

  Widget _buildFindReplaceBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _findController,
              decoration: const InputDecoration(
                hintText: 'Find',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _find(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _replaceController,
              decoration: const InputDecoration(
                hintText: 'Replace',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _replace(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _find,
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Find Next',
          ),
          IconButton(
            onPressed: _replace,
            icon: const Icon(Icons.find_replace_rounded),
            tooltip: 'Replace',
          ),
          IconButton(
            onPressed: _replaceAll,
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Replace All',
          ),
          IconButton(
            onPressed: _toggleFindReplace,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: TextField(
        controller: _contentController,
        focusNode: _editorFocusNode,
        maxLines: null,
        expands: true,
        autofocus: true,
        style: TextStyle(
          fontFamily: 'Consolas',
          fontSize: _fontSize * _zoom,
          height: 1.6,
          color: colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          hintText: 'Start writing...',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        textAlignVertical: TextAlignVertical.top,
        undoController: _undoController,
      ),
    );
  }

  Widget _buildStatusBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Line $_cursorLine, Column $_cursorColumn',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '$_wordCount words',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '$_characterCount characters',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            '$_lineCount lines',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Text(
            'Zoom: ${(_zoom * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(Icons.remove_rounded, size: 16),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Reset Zoom',
          ),
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(Icons.add_rounded, size: 16),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Zoom In',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _contentController.dispose();
    _findController.dispose();
    _replaceController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _FindIntent extends Intent {
  const _FindIntent();
}

class _ReplaceIntent extends Intent {
  const _ReplaceIntent();
}

class _ZoomInIntent extends Intent {
  const _ZoomInIntent();
}

class _ZoomOutIntent extends Intent {
  const _ZoomOutIntent();
}

class _ResetZoomIntent extends Intent {
  const _ResetZoomIntent();
}
