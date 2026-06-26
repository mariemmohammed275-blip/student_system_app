import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'code_assesstent_api.dart';

// ─── Brand Colors ─────────────────────────────────────────────────────────────
class _AppColors {
  // Primary palette
  static const primary = Color(0xFF2A73FF);
  static const secondary = Color(0xFF10B981);
  static const accent = Color(0xFFF59E0B);

  // Light mode
  static const lightBg = Color(0xFFF0F4FF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightSubtitle = Color(0xFF64748B);
  static const lightBorder = Color(0xFFDDE3F0);
  static const lightTabBar = Colors.white;

  // Dark mode — matches project grey dark theme
  static const darkBg = Color(0xFF1C1C1E);
  static const darkCard = Color(0xFF2C2C2E);
  static const darkBorder = Color(0xFF3A3A3C);
  static const darkMuted = Color(0xFF8E8E93);
  static const darkTabBar = Color(0xFF2C2C2E);
}

class CodeAssesstentScreen extends StatefulWidget {
  const CodeAssesstentScreen({super.key});

  @override
  State<CodeAssesstentScreen> createState() => _CodeAssesstentScreenState();
}

class _CodeAssesstentScreenState extends State<CodeAssesstentScreen> {
  final CodeAssesstentApi _api = CodeAssesstentApi();
  final TextEditingController _projectIdController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_CodeMessage> _messages = [
    const _CodeMessage(
      role: _MessageRole.assistant,
      content:
          'Welcome to CodeMind.\n\nI can generate code, explain snippets, detect bugs, autocomplete partial code, audit security issues, and refactor code.',
    ),
  ];

  PlatformFile? _selectedFile;
  CodeProjectUpload? _project;
  bool _uploading = false;
  bool _sending = false;
  bool _useProjectContext = false;
  String _uploadStatus = 'Choose a file and project ID to start.';

  @override
  void initState() {
    super.initState();
    _projectIdController.text = 'code-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _projectIdController.dispose();
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickRarFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['rar'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.single);
  }

  Future<void> _uploadProject() async {
    final file = _selectedFile;
    final projectId = _projectIdController.text.trim();

    if (projectId.isEmpty) {
      _showMessage('Project ID is required.');
      return;
    }
    if (file == null || file.path == null) {
      _showMessage('Choose a .rar project file first.');
      return;
    }

    setState(() => _uploading = true);
    try {
      final uploaded = await _api.uploadProject(
        projectId: projectId,
        filePath: file.path!,
        fileName: file.name,
      );
      setState(() {
        _project = uploaded;
        _useProjectContext = true;
        _uploadStatus =
            '${uploaded.message}\n\nProject ID: ${uploaded.projectId}\nStatus: ${uploaded.status}\nFiles path: ${uploaded.filesPath}';
        _messages.add(
          _CodeMessage(
            role: _MessageRole.assistant,
            content:
                'Project uploaded successfully.\n\nFile: ${file.name}\nFiles path: ${uploaded.filesPath}\n\nYou can now ask questions about your codebase.',
          ),
        );
      });
    } catch (error) {
      _showMessage('Upload failed: $error');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    final projectId = _projectIdController.text.trim();

    if (projectId.isEmpty) {
      _showMessage('Project ID is required.');
      return;
    }
    if (prompt.isEmpty) {
      _showMessage('Write your coding request first.');
      return;
    }

    setState(() {
      _sending = true;
      _messages.add(_CodeMessage(role: _MessageRole.user, content: prompt));
    });
    _promptController.clear();
    _scrollToBottom();

    try {
      final reply = await _api.sendPrompt(
        projectId: projectId,
        prompt: prompt,
        useProjectContext: _useProjectContext,
      );
      setState(() {
        _messages.add(
          _CodeMessage(
            role: _MessageRole.assistant,
            content: reply.result.trim().isNotEmpty
                ? reply.result.trim()
                : 'No response from server.',
            intent: reply.intent,
            lastCode: reply.lastCode.trim().isNotEmpty
                ? reply.lastCode.trim()
                : null,
            outputFiles: reply.outputFiles,
            projectChunks: reply.projectChunks,
            codebaseChunks: reply.codebaseChunks,
          ),
        );
      });
    } catch (error) {
      setState(() {
        _messages.add(
          _CodeMessage(
            role: _MessageRole.error,
            content: 'Request failed: $error',
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _CodeMessage(
            role: _MessageRole.assistant,
            content: 'Chat cleared. Paste code or describe what you need.',
          ),
        );
    });
  }

  void _showMessage(String message) {
    Get.snackbar(
      'Code Assistant',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PillTabScaffold(
      isDark: isDark,
      onClearChat: _clearChat,
      tabs: const ['Chat', 'Upload', 'History'],
      tabIcons: const [
        Icons.chat_bubble_outline_rounded,
        Icons.upload_file_outlined,
        Icons.history_rounded,
      ],
      children: [
        _ChatTab(
          messages: _messages,
          promptController: _promptController,
          scrollController: _scrollController,
          sending: _sending,
          useProjectContext: _useProjectContext,
          hasProject: _project != null,
          onContextChanged: (v) => setState(() => _useProjectContext = v),
          onSend: _sendPrompt,
          isDark: isDark,
        ),
        _UploadTab(
          selectedFile: _selectedFile,
          project: _project,
          projectIdController: _projectIdController,
          status: _uploadStatus,
          uploading: _uploading,
          onPickFile: _pickRarFile,
          onUpload: _uploadProject,
          isDark: isDark,
        ),
        _HistoryTab(messages: _messages, isDark: isDark),
      ],
    );
  }
}

// ─── Pill Tab Scaffold ────────────────────────────────────────────────────────
class _PillTabScaffold extends StatefulWidget {
  const _PillTabScaffold({
    required this.isDark,
    required this.onClearChat,
    required this.tabs,
    required this.tabIcons,
    required this.children,
  });

  final bool isDark;
  final VoidCallback onClearChat;
  final List<String> tabs;
  final List<IconData> tabIcons;
  final List<Widget> children;

  @override
  State<_PillTabScaffold> createState() => _PillTabScaffoldState();
}

class _PillTabScaffoldState extends State<_PillTabScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? _AppColors.darkBg : _AppColors.lightBg;
    final tabBarBg = isDark ? _AppColors.darkTabBar : _AppColors.lightTabBar;
    final mutedColor = isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.code_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CodeMind',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: widget.onClearChat,
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
        // Pill tab bar as bottom widget
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: tabBarBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: List.generate(widget.tabs.length, (i) {
                  final selected = _selectedIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: selected
                              ? _AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            widget.tabs[i],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected ? Colors.white : mutedColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: widget.children[_selectedIndex],
    );
  }
}

// ─── Chat Tab ─────────────────────────────────────────────────────────────────
class _ChatTab extends StatelessWidget {
  const _ChatTab({
    required this.messages,
    required this.promptController,
    required this.scrollController,
    required this.sending,
    required this.useProjectContext,
    required this.hasProject,
    required this.onContextChanged,
    required this.onSend,
    required this.isDark,
  });

  final List<_CodeMessage> messages;
  final TextEditingController promptController;
  final ScrollController scrollController;
  final bool sending, useProjectContext, hasProject, isDark;
  final ValueChanged<bool> onContextChanged;
  final VoidCallback onSend;

  Color get _cardColor => isDark ? _AppColors.darkCard : _AppColors.lightCard;
  Color get _borderColor =>
      isDark ? _AppColors.darkBorder : _AppColors.lightBorder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Context toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasProject
                      ? _AppColors.secondary.withValues(alpha: 0.5)
                      : _borderColor,
                ),
              ),
              child: SwitchListTile(
                value: useProjectContext,
                onChanged: hasProject ? onContextChanged : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                activeColor: _AppColors.secondary,
                dense: true,
                title: Text(
                  'Use project context',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  hasProject
                      ? 'Retrieves relevant code from your project.'
                      : 'Upload a .rar project first.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? _AppColors.darkMuted
                        : _AppColors.lightSubtitle,
                  ),
                ),
                secondary: Icon(
                  hasProject
                      ? Icons.folder_open_rounded
                      : Icons.folder_off_outlined,
                  color: hasProject
                      ? _AppColors.secondary
                      : isDark
                      ? _AppColors.darkMuted
                      : _AppColors.lightSubtitle,
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              itemCount: messages.length + (sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length)
                  return _TypingIndicator(isDark: isDark);
                return _MessageBubble(message: messages[index], isDark: isDark);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border(top: BorderSide(color: _borderColor)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: promptController,
                    minLines: 1,
                    maxLines: 5,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask to generate, explain, debug...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? _AppColors.darkMuted
                            : _AppColors.lightSubtitle,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? _AppColors.darkBg
                          : _AppColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: sending ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AppColors.primary,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upload Tab ───────────────────────────────────────────────────────────────
class _UploadTab extends StatelessWidget {
  const _UploadTab({
    required this.selectedFile,
    required this.project,
    required this.projectIdController,
    required this.status,
    required this.uploading,
    required this.onPickFile,
    required this.onUpload,
    required this.isDark,
  });

  final PlatformFile? selectedFile;
  final CodeProjectUpload? project;
  final TextEditingController projectIdController;
  final String status;
  final bool uploading, isDark;
  final VoidCallback onPickFile, onUpload;

  Color get _cardColor => isDark ? _AppColors.darkCard : _AppColors.lightCard;
  Color get _borderColor =>
      isDark ? _AppColors.darkBorder : _AppColors.lightBorder;
  Color get _bgColor => isDark ? _AppColors.darkBg : _AppColors.lightBg;
  Color get _textColor => isDark ? Colors.white : Colors.black87;
  Color get _mutedColor =>
      isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: _AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Project',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Upload your project as a .rar archive.',
                      style: TextStyle(fontSize: 13, color: _mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Project ID card
          _UploadCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag_rounded, size: 15, color: _mutedColor),
                    const SizedBox(width: 6),
                    Text(
                      'Project ID',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: projectIdController,
                  style: TextStyle(fontSize: 15, color: _textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bgColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // File picker card
          _UploadCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_zip_outlined,
                      size: 15,
                      color: _mutedColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Project Archive (.rar)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: uploading ? null : onPickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedFile != null
                            ? _AppColors.secondary.withValues(alpha: 0.6)
                            : _borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedFile != null
                              ? Icons.check_circle_rounded
                              : Icons.upload_rounded,
                          color: selectedFile != null
                              ? _AppColors.secondary
                              : _mutedColor,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFile?.name ?? 'Tap to choose a .rar file',
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedFile != null
                                  ? _textColor
                                  : _mutedColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedFile != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatFileSize(selectedFile!.size),
                            style: TextStyle(fontSize: 13, color: _mutedColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Upload button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: uploading ? null : onUpload,
              icon: uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.rocket_launch_rounded, size: 20),
              label: Text(
                uploading ? 'Uploading...' : 'Upload Project',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _AppColors.primary.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Status card
          if (project == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: _mutedColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: _mutedColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _SuccessStatusCard(project: project!, isDark: isDark),
        ],
      ),
    );
  }
}

// ─── History Tab ──────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.messages, required this.isDark});

  final List<_CodeMessage> messages;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle,
            ),
            const SizedBox(height: 12),
            Text(
              'No conversation yet.',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _HistoryCard(
          message: messages[index],
          index: index,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isDark});

  final _CodeMessage message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _MessageRole.user;
    final isError = message.role == _MessageRole.error;

    final bubbleBg = isError
        ? (isDark ? const Color(0xFF3B0A0A) : Colors.red.shade50)
        : isUser
        ? _AppColors.primary
        : (isDark ? _AppColors.darkCard : Colors.white);

    final textColor = isError
        ? Colors.red.shade400
        : isUser
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87);

    final roleColor = isUser ? _AppColors.primary : _AppColors.secondary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Role chip
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(message.role.icon, size: 13, color: roleColor),
                  const SizedBox(width: 5),
                  Text(
                    message.intent?.isNotEmpty == true
                        ? '${message.role.label}  ·  ${message.intent}'
                        : message.role.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Main text bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 18),
                ),
                border: !isUser && !isError
                    ? Border.all(
                        color: isDark
                            ? _AppColors.darkBorder
                            : _AppColors.lightBorder,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SelectableText(
                message.content,
                style: TextStyle(fontSize: 15, height: 1.6, color: textColor),
              ),
            ),

            // Code block
            if (message.lastCode != null && message.lastCode!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _CodeBlock(code: message.lastCode!, isDark: isDark),
            ],

            // Output files
            if (message.outputFiles != null &&
                message.outputFiles!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _OutputFilesChips(files: message.outputFiles!, isDark: isDark),
            ],

            // Context footer
            if (!isUser &&
                !isError &&
                (message.projectChunks != null ||
                    message.codebaseChunks != null)) ...[
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 12,
                      color: isDark
                          ? _AppColors.darkMuted
                          : _AppColors.lightSubtitle,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${message.projectChunks ?? 0} project · ${message.codebaseChunks ?? 0} codebase chunks',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? _AppColors.darkMuted
                            : _AppColors.lightSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? _AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(5),
          ),
          border: Border.all(
            color: isDark ? _AppColors.darkBorder : _AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CodeMind is thinking…',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Code Block ──────────────────────────────────────────────────────────────
class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, required this.isDark});
  final String code;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1430) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                const Icon(
                  Icons.code_rounded,
                  size: 14,
                  color: _AppColors.accent,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Generated Code',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.accent,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: code)),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          // Code content - scrollable horizontally, no overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF9ECBFF),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Output Files Chips ───────────────────────────────────────────────────────
class _OutputFilesChips extends StatelessWidget {
  const _OutputFilesChips({required this.files, required this.isDark});
  final List<Map<String, dynamic>> files;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? _AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? _AppColors.darkBorder : _AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_open_rounded,
                size: 14,
                color: _AppColors.accent,
              ),
              const SizedBox(width: 5),
              const Text(
                'Output Files',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: files.map((file) {
              final name =
                  file['file_path'] ?? file['file_name'] ?? file.toString();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? _AppColors.darkBg : _AppColors.lightBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? _AppColors.darkBorder
                        : _AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  name.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Success Status Card ──────────────────────────────────────────────────────
class _SuccessStatusCard extends StatelessWidget {
  const _SuccessStatusCard({required this.project, required this.isDark});
  final CodeProjectUpload project;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? _AppColors.darkCard : Colors.white;
    final borderColor = _AppColors.secondary.withValues(alpha: 0.4);
    final mutedColor = isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: _AppColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.message.isNotEmpty
                        ? project.message
                        : 'Project uploaded successfully',
                    style: const TextStyle(
                      color: _AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Detail rows
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.tag_rounded,
                  label: 'Project ID',
                  value: project.projectId,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  icon: Icons.circle,
                  label: 'Status',
                  value: project.status,
                  valueColor: _AppColors.secondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  icon: Icons.folder_outlined,
                  label: 'Files Path',
                  value: project.filesPath,
                  mono: true,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    this.mono = false,
  });
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final bool mono, isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: mutedColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? textColor,
              fontFamily: mono ? 'monospace' : null,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.message,
    required this.index,
    required this.isDark,
  });
  final _CodeMessage message;
  final int index;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _MessageRole.user;
    final isError = message.role == _MessageRole.error;
    final roleColor = isUser
        ? _AppColors.primary
        : isError
        ? Colors.redAccent
        : _AppColors.secondary;
    final cardColor = isDark ? _AppColors.darkCard : Colors.white;
    final borderColor = isDark ? _AppColors.darkBorder : _AppColors.lightBorder;
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : Colors.black87;
    final mutedColor = isDark ? _AppColors.darkMuted : _AppColors.lightSubtitle;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(message.role.icon, size: 15, color: roleColor),
                const SizedBox(width: 6),
                Text(
                  message.role.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: roleColor,
                  ),
                ),
                if (message.intent?.isNotEmpty == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.intent!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '#${index + 1}',
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ],
            ),
          ),

          // Text
          Padding(
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              message.content,
              style: TextStyle(fontSize: 15, color: textColor, height: 1.6),
            ),
          ),

          // Code block
          if (message.lastCode != null && message.lastCode!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _CodeBlock(code: message.lastCode!, isDark: isDark),
            ),

          // Output files
          if (message.outputFiles != null && message.outputFiles!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _OutputFilesChips(
                files: message.outputFiles!,
                isDark: isDark,
              ),
            ),

          // Context footer
          if (!isUser &&
              !isError &&
              (message.projectChunks != null || message.codebaseChunks != null))
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.layers_outlined, size: 12, color: mutedColor),
                  const SizedBox(width: 5),
                  Text(
                    '${message.projectChunks ?? 0} project chunks  ·  ${message.codebaseChunks ?? 0} codebase chunks',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Upload Card ──────────────────────────────────────────────────────────────
class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? _AppColors.darkBorder : _AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────
class _CodeMessage {
  const _CodeMessage({
    required this.role,
    required this.content,
    this.intent,
    this.lastCode,
    this.outputFiles,
    this.projectChunks,
    this.codebaseChunks,
  });

  final _MessageRole role;
  final String content;
  final String? intent, lastCode;
  final List<Map<String, dynamic>>? outputFiles;
  final int? projectChunks, codebaseChunks;
}

enum _MessageRole {
  user,
  assistant,
  error;

  String get label {
    switch (this) {
      case _MessageRole.user:
        return 'You';
      case _MessageRole.assistant:
        return 'CodeMind';
      case _MessageRole.error:
        return 'Error';
    }
  }

  IconData get icon {
    switch (this) {
      case _MessageRole.user:
        return Icons.person_outline;
      case _MessageRole.assistant:
        return Icons.code_rounded;
      case _MessageRole.error:
        return Icons.error_outline;
    }
  }
}
