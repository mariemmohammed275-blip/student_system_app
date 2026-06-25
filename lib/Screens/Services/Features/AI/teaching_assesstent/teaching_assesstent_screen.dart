import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'teaching_assesstent_api.dart';

// ─── Project Color Palette ────────────────────────────────────────────────────
const Color _primaryBlue = Color(0xFF1D4ED8); // Primary
const Color _secondaryGreen = Color(0xFF10B981); // Secondary
const Color _accentOrange = Color(0xFFF59E0B); // Accent
const Color _neutralDark = Color(0xFF0D1B4B); // Neutral
const Color _deepBlue = Color(0xFF1D4ED8);
const Color _lightBackground = Color(0xffF5F7FB);
const Color _softBlue = Color(0xffEEF2FF);
const Color _borderColor = Color(0xffC7D2FE);

class TeachingAssesstentScreen extends StatefulWidget {
  const TeachingAssesstentScreen({super.key});

  @override
  State<TeachingAssesstentScreen> createState() =>
      _TeachingAssesstentScreenState();
}

class _TeachingAssesstentScreenState extends State<TeachingAssesstentScreen> {
  final TeachingAssesstentApi _api = TeachingAssesstentApi();

  final TextEditingController _projectIdController = TextEditingController();
  final TextEditingController _qgFeedbackController = TextEditingController();
  final TextEditingController _bulkFeedbackController = TextEditingController();
  final TextEditingController _qaQuestionController = TextEditingController();
  final TextEditingController _qaFollowUpController = TextEditingController();
  final TextEditingController _summaryFeedbackController =
      TextEditingController();

  PlatformFile? _selectedFile;
  String _uploadStatus = 'Choose a file and project ID to start.';
  String _cleanTextFilePath = '';
  String _qgThreadId = '';
  String _qgType = 'MCQ';
  String _bulkType = 'MCQ';
  String _summaryDepth = 'standard';
  int _numQuestions = 5;
  bool _loadingUpload = false;
  bool _loadingQG = false;
  bool _loadingBulk = false;
  bool _streamingQA = false;
  bool _streamingSummary = false;

  GeneratedQuestion? _generatedQuestion;
  List<ExamQuestion> _examQuestions = [];
  List<String?> _examAnswers = [];
  String _examThreadId = '';
  String _examResult = '';
  String _qaThreadId = '';
  String _qaAnswer = '';
  String _qaFollowUpAnswer = '';
  String _summaryThreadId = '';
  String _summaryTerms = '';
  String _summaryTldr = '';
  String _summaryNotes = '';
  String _summaryParagraph = '';

  bool get _hasProcessedFile => _cleanTextFilePath.isNotEmpty;

  @override
  void dispose() {
    _projectIdController.dispose();
    _qgFeedbackController.dispose();
    _bulkFeedbackController.dispose();
    _qaQuestionController.dispose();
    _qaFollowUpController.dispose();
    _summaryFeedbackController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx', 'mp3', 'wav', 'm4a'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() => _selectedFile = result.files.single);
  }

  Future<void> _uploadFile() async {
    final file = _selectedFile;
    final projectId = _projectIdController.text.trim();

    if (file == null || file.path == null || projectId.isEmpty) {
      _showMessage('File and Project ID are required.');
      return;
    }

    setState(() => _loadingUpload = true);

    try {
      final processed = await _api.uploadFile(
        projectId: projectId,
        filePath: file.path!,
        fileName: file.name,
      );

      setState(() {
        _cleanTextFilePath = processed.textFile;
        _uploadStatus =
            'File processed successfully.\n\nYou can now use any AI features.';
      });
    } catch (error) {
      _showMessage('Upload failed: $error');
    } finally {
      if (mounted) {
        setState(() => _loadingUpload = false);
      }
    }
  }

  Future<void> _startQuestionGeneration() async {
    if (!_ensureProcessedFile()) return;

    setState(() => _loadingQG = true);

    try {
      final result = await _api.startQuestionGeneration(
        projectId: _projectIdController.text.trim(),
        questionType: _qgType,
        cleanTextFilePath: _cleanTextFilePath,
      );

      setState(() {
        _qgThreadId = result.threadId;
        _generatedQuestion = result.question;
      });
    } catch (error) {
      _showMessage('Question generation failed: $error');
    } finally {
      if (mounted) {
        setState(() => _loadingQG = false);
      }
    }
  }

  Future<void> _continueQuestionGeneration() async {
    if (_qgThreadId.isEmpty) {
      _showMessage('Start a question session first.');
      return;
    }

    setState(() => _loadingQG = true);

    try {
      final result = await _api.continueQuestionGeneration(
        projectId: _projectIdController.text.trim(),
        threadId: _qgThreadId,
        userFeedback: _qgFeedbackController.text.trim(),
        questionType: _qgType,
        cleanTextFilePath: _cleanTextFilePath,
      );

      setState(() {
        _qgThreadId = result.threadId;
        _generatedQuestion = result.question;
      });
      _qgFeedbackController.clear();
    } catch (error) {
      _showMessage('Feedback failed: $error');
    } finally {
      if (mounted) {
        setState(() => _loadingQG = false);
      }
    }
  }

  Future<void> _startBulkGeneration() async {
    if (!_ensureProcessedFile()) return;

    setState(() {
      _loadingBulk = true;
      _examResult = '';
    });

    try {
      final result = await _api.startBulkGeneration(
        projectId: _projectIdController.text.trim(),
        questionType: _bulkType,
        numQuestions: _numQuestions,
        cleanTextFilePath: _cleanTextFilePath,
      );

      setState(() {
        _examThreadId = result.threadId;
        _examQuestions = result.questions;
        _examAnswers = List<String?>.filled(result.questions.length, null);
      });
    } catch (error) {
      _showMessage('Exam generation failed: $error');
    } finally {
      if (mounted) {
        setState(() => _loadingBulk = false);
      }
    }
  }

  Future<void> _applyBulkFeedback() async {
    if (_examThreadId.isEmpty) {
      _showMessage('Generate exam questions first.');
      return;
    }

    setState(() => _loadingBulk = true);

    try {
      final result = await _api.continueBulkGeneration(
        threadId: _examThreadId,
        userFeedback: _bulkFeedbackController.text.trim(),
      );

      setState(() {
        _examQuestions = result.questions;
        _examAnswers = List<String?>.filled(result.questions.length, null);
      });
      _bulkFeedbackController.clear();
    } catch (error) {
      _showMessage('Exam feedback failed: $error');
    } finally {
      if (mounted) {
        setState(() => _loadingBulk = false);
      }
    }
  }

  Future<void> _askQuestion({required bool followUp}) async {
    if (!_ensureProcessedFile()) return;

    final controller = followUp ? _qaFollowUpController : _qaQuestionController;
    final question = controller.text.trim();
    if (question.isEmpty) {
      _showMessage('Write your question first.');
      return;
    }

    setState(() {
      _streamingQA = true;
      if (followUp) {
        _qaFollowUpAnswer = '';
      } else {
        _qaAnswer = '';
      }
    });

    try {
      final stream = followUp && _qaThreadId.isNotEmpty
          ? _api.continueQuestionAnswering(
              threadId: _qaThreadId,
              userQuestion: question,
            )
          : _api.startQuestionAnswering(
              cleanTextFilePath: _cleanTextFilePath,
              userQuestion: question,
            );

      await for (final event in stream) {
        if (!mounted) return;

        if (event.threadId.isNotEmpty) {
          _qaThreadId = event.threadId;
        }

        if (event.event == 'token') {
          setState(() {
            if (followUp) {
              _qaFollowUpAnswer += event.token;
            } else {
              _qaAnswer += event.token;
            }
          });
        }
      }
    } catch (error) {
      _showMessage('Q&A failed: $error');
    } finally {
      if (mounted) {
        setState(() => _streamingQA = false);
      }
    }
  }

  Future<void> _startSummarization() async {
    if (!_ensureProcessedFile()) return;

    setState(() {
      _streamingSummary = true;
      _summaryTerms = '';
      _summaryTldr = '';
      _summaryNotes = '';
      _summaryParagraph = '';
    });

    try {
      await _consumeSummaryStream(
        _api.startSummarization(
          cleanTextFilePath: _cleanTextFilePath,
          projectId: _projectIdController.text.trim(),
          depth: _summaryDepth,
        ),
      );
    } catch (error) {
      _showMessage('Summarization failed: $error');
    } finally {
      if (mounted) {
        setState(() => _streamingSummary = false);
      }
    }
  }

  Future<void> _continueSummarization() async {
    if (_summaryThreadId.isEmpty) {
      _showMessage('Generate a summary first.');
      return;
    }

    setState(() {
      _streamingSummary = true;
      _summaryTerms = '';
      _summaryTldr = '';
      _summaryNotes = '';
      _summaryParagraph = '';
    });

    try {
      await _consumeSummaryStream(
        _api.continueSummarization(
          projectId: _projectIdController.text.trim(),
          cleanTextFilePath: _cleanTextFilePath,
          threadId: _summaryThreadId,
          userFeedback: _summaryFeedbackController.text.trim(),
        ),
      );
      _summaryFeedbackController.clear();
    } catch (error) {
      _showMessage('Summary feedback failed: $error');
    } finally {
      if (mounted) {
        setState(() => _streamingSummary = false);
      }
    }
  }

  Future<void> _consumeSummaryStream(
    Stream<AssistantStreamEvent> stream,
  ) async {
    await for (final event in stream) {
      if (!mounted) return;

      if (event.threadId.isNotEmpty) {
        _summaryThreadId = event.threadId;
      }

      if (event.event == 'token') {
        setState(() {
          switch (event.section) {
            case 'key_terms':
              _summaryTerms += event.token;
              break;
            case 'tldr':
              _summaryTldr += event.token;
              break;
            case 'structured_notes':
              _summaryNotes += event.token;
              break;
            case 'paragraph_summary':
            case 'rewriter':
              _summaryParagraph += event.token;
              break;
          }
        });
      } else if (event.event == 'interrupt' && event.payload != null) {
        final payload = event.payload!;
        setState(() {
          _summaryTerms = payload['key_terms']?.toString() ?? _summaryTerms;
          _summaryTldr = payload['tldr']?.toString() ?? _summaryTldr;
          _summaryNotes =
              payload['structured_notes']?.toString() ?? _summaryNotes;
          _summaryParagraph =
              payload['paragraph_summary']?.toString() ?? _summaryParagraph;
        });
      }
    }
  }

  void _scoreExam() {
    if (_examQuestions.isEmpty) {
      _showMessage('Generate exam questions first.');
      return;
    }

    var correct = 0;
    final lines = <String>[];

    for (var i = 0; i < _examQuestions.length; i++) {
      final question = _examQuestions[i];
      final answer = _examAnswers[i];
      var normalized = answer ?? '';

      if (question.questionType == 'MCQ' &&
          normalized.length > 1 &&
          normalized[1] == '.') {
        normalized = normalized[0].toUpperCase();
      }

      final isCorrect =
          normalized.toUpperCase() == question.answer.toUpperCase();
      if (isCorrect) correct++;

      lines.add(
        '${isCorrect ? 'Correct' : 'Wrong'} - Q${i + 1}: ${question.question}\nYour answer: ${answer ?? 'No answer'}\nCorrect answer: ${question.answer}\nExplanation: ${question.explanation}',
      );
    }

    final percent =
        ((_examQuestions.isEmpty ? 0 : correct / _examQuestions.length) * 100)
            .round();

    setState(() {
      _examResult =
          'Score: $correct/${_examQuestions.length} ($percent%)\n\n${lines.join('\n\n')}';
    });
  }

  bool _ensureProcessedFile() {
    if (_hasProcessedFile) {
      return true;
    }

    _showMessage('Upload and process a file first.');
    return false;
  }

  void _showMessage(String message) {
    Get.snackbar(
      'Teaching Assistant',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.blueAccent : _primaryBlue;
    final backgroundColor = isDark ? Colors.grey[900] : _lightBackground;

    return DefaultTabController(
      length: 5,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: primaryColor,
            secondary: _secondaryGreen,
            tertiary: _accentOrange,
          ),
          chipTheme: ChipThemeData(
            selectedColor: primaryColor,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            secondaryLabelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(color: _borderColor),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : _borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : _borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(
                color: primaryColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            systemOverlayStyle: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            elevation: 0,
            backgroundColor: backgroundColor,
            foregroundColor: isDark ? Colors.white : Colors.black,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Teaching Assistant',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Container(
                height: 48,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : _borderColor,
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? Colors.white70
                      : Colors.black54,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tabs: const [
                    Tab(text: 'Upload'),
                    Tab(text: 'Question Gen'),
                    Tab(text: 'Exam'),
                    Tab(text: 'Q&A'),
                    Tab(text: 'Summarize'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _UploadTab(
                selectedFile: _selectedFile,
                projectIdController: _projectIdController,
                status: _uploadStatus,
                loading: _loadingUpload,
                onPickFile: _pickFile,
                onUpload: _uploadFile,
              ),
              _QuestionGenerationTab(
                questionType: _qgType,
                loading: _loadingQG,
                question: _generatedQuestion,
                feedbackController: _qgFeedbackController,
                onTypeChanged: (value) => setState(() => _qgType = value),
                onGenerate: _startQuestionGeneration,
                onApplyFeedback: _continueQuestionGeneration,
              ),
              _ExamTab(
                questionType: _bulkType,
                questionCount: _numQuestions,
                loading: _loadingBulk,
                questions: _examQuestions,
                answers: _examAnswers,
                result: _examResult,
                feedbackController: _bulkFeedbackController,
                onTypeChanged: (value) => setState(() => _bulkType = value),
                onCountChanged: (value) =>
                    setState(() => _numQuestions = value),
                onGenerate: _startBulkGeneration,
                onApplyFeedback: _applyBulkFeedback,
                onAnswerChanged: (index, value) {
                  setState(() => _examAnswers[index] = value);
                },
                onSubmit: _scoreExam,
              ),
              _QaTab(
                questionController: _qaQuestionController,
                followUpController: _qaFollowUpController,
                answer: _qaAnswer,
                followUpAnswer: _qaFollowUpAnswer,
                loading: _streamingQA,
                onAsk: () => _askQuestion(followUp: false),
                onFollowUp: () => _askQuestion(followUp: true),
              ),
              _SummaryTab(
                depth: _summaryDepth,
                loading: _streamingSummary,
                terms: _summaryTerms,
                tldr: _summaryTldr,
                notes: _summaryNotes,
                paragraph: _summaryParagraph,
                feedbackController: _summaryFeedbackController,
                onDepthChanged: (value) =>
                    setState(() => _summaryDepth = value),
                onGenerate: _startSummarization,
                onApplyFeedback: _continueSummarization,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadTab extends StatelessWidget {
  const _UploadTab({
    required this.selectedFile,
    required this.projectIdController,
    required this.status,
    required this.loading,
    required this.onPickFile,
    required this.onUpload,
  });

  final PlatformFile? selectedFile;
  final TextEditingController projectIdController;
  final String status;
  final bool loading;
  final VoidCallback onPickFile;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      children: [
        _SectionTitle(
          title: 'Document Upload',
          subtitle: 'Upload PDF, TXT, DOCX, or audio files.',
        ),
        _InputCard(
          child: Column(
            children: [
              TextField(
                controller: projectIdController,
                decoration: const InputDecoration(
                  labelText: 'Project ID',
                  hintText: 'biology-101',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: loading ? null : onPickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(selectedFile?.name ?? 'Choose file'),
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: loading ? 'Processing...' : 'Upload & Process',
                icon: Icons.upload_file,
                onPressed: loading ? null : onUpload,
              ),
            ],
          ),
        ),
        _OutputCard(title: 'Processing Status', text: status),
      ],
    );
  }
}

class _QuestionGenerationTab extends StatelessWidget {
  const _QuestionGenerationTab({
    required this.questionType,
    required this.loading,
    required this.question,
    required this.feedbackController,
    required this.onTypeChanged,
    required this.onGenerate,
    required this.onApplyFeedback,
  });

  final String questionType;
  final bool loading;
  final GeneratedQuestion? question;
  final TextEditingController feedbackController;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onGenerate;
  final VoidCallback onApplyFeedback;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      children: [
        _SectionTitle(
          title: 'Iterative Question Generation',
          subtitle: 'Generate one question, then refine it with feedback.',
        ),
        _InputCard(
          child: Column(
            children: [
              _SegmentedChoices(
                value: questionType,
                values: const ['MCQ', 'T/F'],
                onChanged: onTypeChanged,
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: loading ? 'Generating...' : 'Generate Question',
                icon: Icons.track_changes,
                onPressed: loading ? null : onGenerate,
              ),
            ],
          ),
        ),
        if (question != null) _GeneratedQuestionCard(question: question!),
        _InputCard(
          child: Column(
            children: [
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: "Type feedback, 'auto', or 'save'",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: 'Apply Feedback',
                icon: Icons.refresh,
                onPressed: loading ? null : onApplyFeedback,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExamTab extends StatelessWidget {
  const _ExamTab({
    required this.questionType,
    required this.questionCount,
    required this.loading,
    required this.questions,
    required this.answers,
    required this.result,
    required this.feedbackController,
    required this.onTypeChanged,
    required this.onCountChanged,
    required this.onGenerate,
    required this.onApplyFeedback,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  final String questionType;
  final int questionCount;
  final bool loading;
  final List<ExamQuestion> questions;
  final List<String?> answers;
  final String result;
  final TextEditingController feedbackController;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onGenerate;
  final VoidCallback onApplyFeedback;
  final void Function(int index, String? value) onAnswerChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      children: [
        _SectionTitle(
          title: 'AI-Generated Exam',
          subtitle: 'Generate, refine, then answer the exam questions.',
        ),
        _InputCard(
          child: Column(
            children: [
              _SegmentedChoices(
                value: questionType,
                values: const ['MCQ', 'T/F', 'Both'],
                onChanged: onTypeChanged,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Questions'),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 50,
                      divisions: 49,
                      value: questionCount.toDouble(),
                      label: questionCount.toString(),
                      onChanged: (value) => onCountChanged(value.round()),
                    ),
                  ),
                  Text(questionCount.toString()),
                ],
              ),
              _PrimaryButton(
                label: loading ? 'Generating...' : 'Generate Questions',
                icon: Icons.casino_outlined,
                onPressed: loading ? null : onGenerate,
              ),
            ],
          ),
        ),
        if (questions.isNotEmpty) ...[
          _InputCard(
            child: Column(
              children: [
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback',
                    hintText: 'Make hard questions harder',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _SecondaryButton(
                  label: 'Regenerate',
                  icon: Icons.refresh,
                  onPressed: loading ? null : onApplyFeedback,
                ),
              ],
            ),
          ),
          ...List.generate(questions.length, (index) {
            final question = questions[index];
            final options = question.options.isNotEmpty
                ? question.options
                : const ['True', 'False'];

            return _InputCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(
                    text:
                        '${_badge(question.complexity)} · ${question.questionType}',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Q${index + 1}. ${question.question}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  ...options.map(
                    (option) => RadioListTile<String>(
                      value: option,
                      groupValue: answers[index],
                      onChanged: (value) => onAnswerChanged(index, value),
                      title: Text(option),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            );
          }),
          _PrimaryButton(
            label: 'Submit & See Results',
            icon: Icons.check_circle_outline,
            onPressed: onSubmit,
          ),
          if (result.isNotEmpty) _ExamResultCard(result: result),
        ],
      ],
    );
  }
}

class _QaTab extends StatelessWidget {
  const _QaTab({
    required this.questionController,
    required this.followUpController,
    required this.answer,
    required this.followUpAnswer,
    required this.loading,
    required this.onAsk,
    required this.onFollowUp,
  });

  final TextEditingController questionController;
  final TextEditingController followUpController;
  final String answer;
  final String followUpAnswer;
  final bool loading;
  final VoidCallback onAsk;
  final VoidCallback onFollowUp;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      children: [
        _SectionTitle(
          title: 'Document Question Answering',
          subtitle: 'Ask anything about the uploaded document.',
        ),
        _QuestionBox(
          controller: questionController,
          label: 'Your Question',
          buttonLabel: loading ? 'Asking...' : 'Ask',
          onPressed: loading ? null : onAsk,
        ),
        _QaAnswerCard(
          title: 'Answer',
          text: answer,
          loading: loading && followUpAnswer.isEmpty,
        ),
        _QuestionBox(
          controller: followUpController,
          label: 'Follow-up',
          buttonLabel: 'Ask Follow-up',
          onPressed: loading ? null : onFollowUp,
        ),
        _QaAnswerCard(
          title: 'Follow-up Answer',
          text: followUpAnswer,
          loading: loading && answer.isNotEmpty,
        ),
      ],
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({
    required this.depth,
    required this.loading,
    required this.terms,
    required this.tldr,
    required this.notes,
    required this.paragraph,
    required this.feedbackController,
    required this.onDepthChanged,
    required this.onGenerate,
    required this.onApplyFeedback,
  });

  final String depth;
  final bool loading;
  final String terms;
  final String tldr;
  final String notes;
  final String paragraph;
  final TextEditingController feedbackController;
  final ValueChanged<String> onDepthChanged;
  final VoidCallback onGenerate;
  final VoidCallback onApplyFeedback;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      children: [
        _SectionTitle(
          title: 'AI Study Summary Generator',
          subtitle: 'Generate key terms, recap, notes, and study guide.',
        ),
        _InputCard(
          child: Column(
            children: [
              _SegmentedChoices(
                value: depth,
                values: const ['brief', 'standard', 'detailed'],
                onChanged: onDepthChanged,
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: loading ? 'Generating...' : 'Generate Summary',
                icon: Icons.auto_awesome,
                onPressed: loading ? null : onGenerate,
              ),
            ],
          ),
        ),
        _SummaryOutputCard(
          title: 'Quick Recap',
          icon: Icons.summarize_outlined,
          text: tldr,
        ),
        _KeyTermsCard(termsRaw: terms),
        _SummaryOutputCard(
          title: 'Structured Notes',
          icon: Icons.format_list_bulleted_rounded,
          text: notes,
        ),
        _SummaryOutputCard(
          title: 'Paragraph Summary',
          icon: Icons.article_outlined,
          text: paragraph,
        ),
        _InputCard(
          child: Column(
            children: [
              TextField(
                controller: feedbackController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: "Add examples, type 'auto', or 'save'",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: 'Apply Feedback',
                icon: Icons.refresh,
                onPressed: loading ? null : onApplyFeedback,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneratedQuestionCard extends StatelessWidget {
  const _GeneratedQuestionCard({required this.question});

  final GeneratedQuestion question;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.grey[800] : const Color(0xffE9EEF5);
    final correctAnswerLetter = question.answer.trim().toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Generated Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: SelectableText(
              question.question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          if (question.options.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...question.options.map((option) {
              final optionLetter =
                  option.trim().isNotEmpty &&
                      option.trim()[0].toUpperCase() == correctAnswerLetter
                  ? correctAnswerLetter
                  : null;
              final isCorrect =
                  option.trim().toUpperCase().startsWith(correctAnswerLetter) &&
                  question.options.length > 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? _primaryBlue.withValues(alpha: 0.1)
                      : isDark
                      ? Colors.grey[850]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect ? _primaryBlue : _borderColor,
                    width: isCorrect ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCorrect ? _primaryBlue : null,
                          fontWeight: isCorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _primaryBlue,
                        size: 18,
                      ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          // Correct Answer row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Correct Answer: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  question.answer,
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: _primaryBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionBox extends StatelessWidget {
  const _QuestionBox({
    required this.controller,
    required this.label,
    required this.buttonLabel,
    required this.onPressed,
  });

  final TextEditingController controller;
  final String label;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _InputCard(
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryButton(
            label: buttonLabel,
            icon: Icons.search,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final child in children) ...[child, const SizedBox(height: 14)],
        ],
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
            fontSize: 14,
            height: 1.4,
            color: isDark ? Colors.white70 : Colors.black54,
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
        color: isDark ? Colors.grey[800] : _softBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
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
            text.trim().isEmpty ? 'Output will appear here.' : text.trim(),
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

class _SegmentedChoices extends StatelessWidget {
  const _SegmentedChoices({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((item) {
        return ChoiceChip(
          label: Text(item),
          selected: value == item,
          onSelected: (_) => onChanged(item),
        );
      }).toList(),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // Pick color based on difficulty part
    final lower = text.toLowerCase();
    Color bg, fg;
    if (lower.contains('easy')) {
      bg = _secondaryGreen.withValues(alpha: 0.15);
      fg = _secondaryGreen;
    } else if (lower.contains('medium')) {
      bg = _accentOrange.withValues(alpha: 0.15);
      fg = _accentOrange;
    } else if (lower.contains('hard')) {
      bg = Colors.red.withValues(alpha: 0.12);
      fg = Colors.red;
    } else {
      bg = _primaryBlue.withValues(alpha: 0.12);
      fg = _primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

String _badge(String level) {
  switch (level.toLowerCase()) {
    case 'easy':
      return 'Easy';
    case 'medium':
      return 'Medium';
    case 'hard':
      return 'Hard';
    default:
      return level;
  }
}

// ─── Exam Results Card ───────────────────────────────────────────────────────

class _ExamResultCard extends StatelessWidget {
  const _ExamResultCard({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = result.split('\n\n');
    final scoreLine = lines.isNotEmpty ? lines.first : '';
    final questionBlocks = lines.skip(1).toList();

    // Parse score
    final scoreMatch = RegExp(r'(\d+)/(\d+)').firstMatch(scoreLine);
    final correct = int.tryParse(scoreMatch?.group(1) ?? '0') ?? 0;
    final total = int.tryParse(scoreMatch?.group(2) ?? '1') ?? 1;
    final percent = total > 0 ? (correct / total * 100).round() : 0;

    Color scoreColor;
    if (percent >= 70) {
      scoreColor = Colors.green;
    } else if (percent >= 40) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xffE9EEF5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score header
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: scoreColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Exam Results',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Score pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $correct / $total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Individual question results
          ...questionBlocks.map((block) {
            final isCorrect = block.trimLeft().startsWith('Correct');
            final blockColor = isCorrect ? Colors.green : Colors.red;
            final bgColor = blockColor.withValues(alpha: 0.06);
            final borderColor = blockColor.withValues(alpha: 0.3);

            // Parse block lines
            final blockLines = block.trim().split('\n');
            final questionLine = blockLines.isNotEmpty ? blockLines[0] : '';
            final yourAnswer = blockLines.firstWhere(
              (l) => l.startsWith('Your answer:'),
              orElse: () => '',
            );
            final correctAnswer = blockLines.firstWhere(
              (l) => l.startsWith('Correct answer:'),
              orElse: () => '',
            );
            final explanation = blockLines.firstWhere(
              (l) => l.startsWith('Explanation:'),
              orElse: () => '',
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: blockColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          questionLine.replaceFirst(
                            RegExp(r'^(Correct|Wrong) - '),
                            '',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (yourAnswer.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ResultRow(
                      label: 'Your answer',
                      value: yourAnswer.replaceFirst('Your answer: ', ''),
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ],
                  if (correctAnswer.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _ResultRow(
                      label: 'Correct answer',
                      value: correctAnswer.replaceFirst('Correct answer: ', ''),
                      color: Colors.green,
                    ),
                  ],
                  if (explanation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: _primaryBlue,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              explanation.replaceFirst('Explanation: ', ''),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, color: color)),
        ),
      ],
    );
  }
}

// ─── Key Terms Card ──────────────────────────────────────────────────────────

class _KeyTermsCard extends StatelessWidget {
  const _KeyTermsCard({required this.termsRaw});
  final String termsRaw;

  List<Map<String, String>> _parseTerms(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      // Try JSON parse
      final trimmed = raw.trim();
      // Remove leading/trailing brackets if present
      final jsonStr = trimmed.startsWith('[') ? trimmed : '[$trimmed]';
      final decoded = (jsonStr.contains('"term"'))
          ? _extractTermsFromJson(jsonStr)
          : <Map<String, String>>[];
      if (decoded.isNotEmpty) return decoded;
    } catch (_) {}
    return [];
  }

  List<Map<String, String>> _extractTermsFromJson(String json) {
    final results = <Map<String, String>>[];
    final termPattern = RegExp(r'"term"\s*:\s*"([^"]+)"');
    final defPattern = RegExp(r'"definition"\s*:\s*"([^"]+)"');
    final terms = termPattern
        .allMatches(json)
        .map((m) => m.group(1) ?? '')
        .toList();
    final defs = defPattern
        .allMatches(json)
        .map((m) => m.group(1) ?? '')
        .toList();
    for (var i = 0; i < terms.length; i++) {
      results.add({
        'term': terms[i],
        'definition': i < defs.length ? defs[i] : '',
      });
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsed = _parseTerms(termsRaw);

    if (termsRaw.trim().isEmpty) {
      return _SummaryOutputCard(
        title: 'Key Terms & Definitions',
        icon: Icons.menu_book_outlined,
        text: '',
      );
    }

    if (parsed.isEmpty) {
      // fallback to plain text
      return _SummaryOutputCard(
        title: 'Key Terms & Definitions',
        icon: Icons.menu_book_outlined,
        text: termsRaw,
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : _softBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: _primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Key Terms & Definitions',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _secondaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${parsed.length} terms',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _secondaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: parsed.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    bottom: i < parsed.length - 1 ? 10 : 0,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _accentOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _accentOrange,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['term'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((item['definition'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _softBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['definition'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Output Card ─────────────────────────────────────────────────────

class _SummaryOutputCard extends StatelessWidget {
  const _SummaryOutputCard({
    required this.title,
    required this.icon,
    required this.text,
  });
  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : _softBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: _primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: text.trim().isEmpty
                ? Text(
                    'Output will appear here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : _MarkdownText(text: text.trim(), isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ─── Q&A Answer Card ─────────────────────────────────────────────────────────

class _QaAnswerCard extends StatelessWidget {
  const _QaAnswerCard({
    required this.title,
    required this.text,
    required this.loading,
  });
  final String title;
  final String text;
  final bool loading;

  /// Strip leading {"score":"..."} prefix that the API injects
  static final _scorePrefix = RegExp(r'^\{"score"\s*:\s*"[^"]*"\}');

  String _clean(String raw) => raw.replaceFirst(_scorePrefix, '').trimLeft();

  bool? _scoreValue(String raw) {
    final m = RegExp(r'"score"\s*:\s*"([^"]+)"').firstMatch(raw);
    if (m == null) return null;
    return m.group(1)?.toLowerCase() == 'yes';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleaned = _clean(text);
    final isEmpty = cleaned.trim().isEmpty;
    final scoreOk = _scoreValue(text); // null if no score prefix yet

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : _softBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: _primaryBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primaryBlue,
                    ),
                  )
                else if (scoreOk != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scoreOk
                          ? _secondaryGreen.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: scoreOk
                            ? _secondaryGreen.withValues(alpha: 0.5)
                            : Colors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          scoreOk
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 13,
                          color: scoreOk ? _secondaryGreen : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scoreOk ? 'On-Topic' : 'Off-Topic',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: scoreOk ? _secondaryGreen : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: isEmpty && !loading
                ? Text(
                    'Answer will appear here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : _MarkdownText(text: cleaned, isDark: isDark),
          ),
        ],
      ),
    );
  }
}
// ─── Markdown Text Renderer ──────────────────────────────────────────────────
// Lightweight markdown parser — no external package needed.
// Handles: ## headings, **bold**, `code`, ```code blocks```, - bullets, blank lines.

class _MarkdownText extends StatelessWidget {
  const _MarkdownText({required this.text, required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    bool inCodeBlock = false;
    final codeLines = <String>[];

    void flushCodeBlock() {
      if (codeLines.isEmpty) return;
      widgets.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[900]
                : const Color(0xFF0D1B4B).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor),
          ),
          child: SelectableText(
            codeLines.join('\n'),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.55,
              color: isDark ? Colors.greenAccent[200] : const Color(0xFF1D4ED8),
            ),
          ),
        ),
      );
      codeLines.clear();
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Code block toggle
      if (line.trimLeft().startsWith('```')) {
        if (inCodeBlock) {
          inCodeBlock = false;
          flushCodeBlock();
        } else {
          inCodeBlock = true;
        }
        continue;
      }

      if (inCodeBlock) {
        codeLines.add(line);
        continue;
      }

      // H2 heading  ## ...
      if (line.startsWith('## ')) {
        widgets.add(const SizedBox(height: 10));
        widgets.add(
          Text(
            line.substring(3).trim(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _primaryBlue,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // H3 heading  ### ...
      if (line.startsWith('### ')) {
        widgets.add(
          Text(
            line.substring(4).trim(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : _neutralDark,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 2));
        continue;
      }

      // Bullet  - ... or   - ...
      final bulletMatch = RegExp(r'^(\s*)- (.+)').firstMatch(line);
      if (bulletMatch != null) {
        final indent = bulletMatch.group(1)!.length;
        final content = bulletMatch.group(2)!;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: indent * 6.0, top: 3, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Container(
                    width: indent == 0 ? 6 : 4,
                    height: indent == 0 ? 6 : 4,
                    decoration: BoxDecoration(
                      color: indent == 0 ? _primaryBlue : _secondaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: _InlineText(text: content, isDark: isDark),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Blank line = spacing
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Normal paragraph line
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _InlineText(text: line, isDark: isDark),
        ),
      );
    }

    // Flush any unclosed code block
    if (inCodeBlock) flushCodeBlock();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

/// Renders inline markdown: **bold**, `code`, plain text.
class _InlineText extends StatelessWidget {
  const _InlineText({required this.text, required this.isDark});
  final String text;
  final bool isDark;

  List<InlineSpan> _parse(String raw) {
    final spans = <InlineSpan>[];
    // Pattern: **bold** or `code`
    final pattern = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
    int cursor = 0;

    for (final match in pattern.allMatches(raw)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: raw.substring(cursor, match.start)));
      }
      if (match.group(1) != null) {
        // **bold**
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        // `code`
        spans.add(
          TextSpan(
            text: match.group(2),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              color: _primaryBlue,
              backgroundColor: _primaryBlue.withValues(alpha: 0.08),
            ),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < raw.length) {
      spans.add(TextSpan(text: raw.substring(cursor)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: isDark ? Colors.white : Colors.black87,
        ),
        children: _parse(text),
      ),
    );
  }
}
