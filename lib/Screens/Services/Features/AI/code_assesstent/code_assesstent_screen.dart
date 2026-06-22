import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'code_assesstent_api.dart';

class CodeAssesstentScreen extends StatefulWidget {
  const CodeAssesstentScreen({super.key});

  @override
  State<CodeAssesstentScreen> createState() => _CodeAssesstentScreenState();
}

class _CodeAssesstentScreenState extends State<CodeAssesstentScreen> {
  final CodeAssesstentApi _api = CodeAssesstentApi();
  final TextEditingController _projectIdController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

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
  String _uploadStatus =
      'Upload a .rar project archive to add codebase context.';

  @override
  void initState() {
    super.initState();
    _projectIdController.text = 'code-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _projectIdController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickRarFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['rar'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

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
      if (mounted) {
        setState(() => _uploading = false);
      }
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
            content: _formatReply(reply),
            intent: reply.intent,
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
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  String _formatReply(CodeAssistantReply reply) {
    final buffer = StringBuffer();

    if (reply.result.trim().isNotEmpty) {
      buffer.writeln(reply.result.trim());
    } else {
      buffer.writeln('No response from server.');
    }

    if (reply.lastCode.trim().isNotEmpty) {
      buffer
        ..writeln('\nGenerated code:')
        ..writeln(reply.lastCode.trim());
    }

    if (reply.outputFiles.isNotEmpty) {
      buffer.writeln('\nOutput files:');
      for (final file in reply.outputFiles) {
        buffer.writeln('- ${file['file_path'] ?? file['file_name'] ?? file}');
      }
    }

    buffer.writeln(
      '\nContext used: ${reply.projectChunks} project chunks, ${reply.codebaseChunks} codebase chunks.',
    );

    return buffer.toString().trim();
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
    final primaryColor = isDark
        ? Colors.blueAccent
        : const Color.fromARGB(255, 28, 55, 212);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
          title: const Text(
            'Code Assistant',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Clear chat',
              onPressed: _clearChat,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: 'Chat'),
              Tab(text: 'Upload'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ChatTab(
              messages: _messages,
              promptController: _promptController,
              sending: _sending,
              useProjectContext: _useProjectContext,
              hasProject: _project != null,
              onContextChanged: (value) {
                setState(() => _useProjectContext = value);
              },
              onSend: _sendPrompt,
            ),
            _UploadTab(
              selectedFile: _selectedFile,
              project: _project,
              projectIdController: _projectIdController,
              status: _uploadStatus,
              uploading: _uploading,
              onPickFile: _pickRarFile,
              onUpload: _uploadProject,
            ),
            _HistoryTab(messages: _messages),
          ],
        ),
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({
    required this.messages,
    required this.promptController,
    required this.sending,
    required this.useProjectContext,
    required this.hasProject,
    required this.onContextChanged,
    required this.onSend,
  });

  final List<_CodeMessage> messages;
  final TextEditingController promptController;
  final bool sending;
  final bool useProjectContext;
  final bool hasProject;
  final ValueChanged<bool> onContextChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _InputCard(
              child: SwitchListTile(
                value: useProjectContext,
                onChanged: hasProject ? onContextChanged : null,
                contentPadding: EdgeInsets.zero,
                title: const Text('Use uploaded project context'),
                subtitle: Text(
                  hasProject
                      ? 'The assistant will retrieve relevant chunks from your project.'
                      : 'Upload a .rar project first to enable codebase context.',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const _MessageBubble(
                    message: _CodeMessage(
                      role: _MessageRole.assistant,
                      content: 'Thinking...',
                    ),
                  );
                }

                return _MessageBubble(message: messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _InputCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: promptController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Ask to generate, explain, debug, audit...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: sending ? null : onSend,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadTab extends StatelessWidget {
  const _UploadTab({
    required this.selectedFile,
    required this.project,
    required this.projectIdController,
    required this.status,
    required this.uploading,
    required this.onPickFile,
    required this.onUpload,
  });

  final PlatformFile? selectedFile;
  final CodeProjectUpload? project;
  final TextEditingController projectIdController;
  final String status;
  final bool uploading;
  final VoidCallback onPickFile;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle(
            title: 'Upload Project',
            subtitle: 'Upload your project as a .rar archive.',
          ),
          const SizedBox(height: 14),
          _InputCard(
            child: Column(
              children: [
                TextField(
                  controller: projectIdController,
                  decoration: const InputDecoration(
                    labelText: 'Project ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: uploading ? null : onPickFile,
                  icon: const Icon(Icons.folder_zip_outlined),
                  label: Text(selectedFile?.name ?? 'Choose .rar file'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: uploading ? null : onUpload,
                    icon: const Icon(Icons.upload_file),
                    label: Text(uploading ? 'Uploading...' : 'Upload Project'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _OutputCard(title: 'Status', text: status),
          if (project != null) ...[
            const SizedBox(height: 14),
            _OutputCard(
              title: 'Session Details',
              text:
                  'Project ID: ${project!.projectId}\nStatus: ${project!.status}\nFiles path: ${project!.filesPath}',
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.messages});

  final List<_CodeMessage> messages;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _OutputCard(title: message.role.label, text: message.content);
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _CodeMessage message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.role == _MessageRole.user;
    final color = isUser
        ? const Color.fromARGB(255, 28, 55, 212)
        : isDark
        ? Colors.grey[800]
        : const Color(0xffE9EEF5);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.role == _MessageRole.error ? Colors.red[50] : color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  message.role.icon,
                  size: 16,
                  color: isUser ? Colors.white : null,
                ),
                const SizedBox(width: 6),
                Text(
                  message.intent?.isNotEmpty == true
                      ? message.intent!
                      : message.role.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              message.content,
              style: TextStyle(
                height: 1.45,
                color: isUser
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xffE9EEF5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _InputCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SelectableText(
            text.trim().isEmpty ? 'Nothing yet.' : text.trim(),
            style: TextStyle(
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeMessage {
  const _CodeMessage({required this.role, required this.content, this.intent});

  final _MessageRole role;
  final String content;
  final String? intent;
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
