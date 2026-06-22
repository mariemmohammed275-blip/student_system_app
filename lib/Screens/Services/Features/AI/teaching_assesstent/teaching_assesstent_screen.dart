import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'teaching_assesstent_api.dart';

const Color _primaryBlue = Color(0xFF2A73FF);
const Color _deepBlue = Color.fromARGB(255, 28, 55, 212);
const Color _lightBackground = Color(0xffF5F7FB);
const Color _softBlue = Color(0xffE9EEF5);
const Color _borderColor = Color(0xffDDE5F0);

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
            'File processed successfully.\n\nThread ID: ${processed.threadId}\nUploaded File: ${processed.uploadedFile}\nExtracted to: ${processed.textFile}\n\nYou can now use any feature below.';
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
                secondary: primaryColor,
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
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              minimumSize: const Size.fromHeight(46),
              side: BorderSide(color: primaryColor.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
                  unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
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
          if (result.isNotEmpty)
            _OutputCard(title: 'Exam Results', text: result),
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
        _OutputCard(title: 'Answer', text: answer),
        _QuestionBox(
          controller: followUpController,
          label: 'Follow-up',
          buttonLabel: 'Ask Follow-up',
          onPressed: loading ? null : onFollowUp,
        ),
        _OutputCard(title: 'Follow-up Answer', text: followUpAnswer),
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
        _OutputCard(title: 'Quick Recap', text: tldr),
        _OutputCard(title: 'Key Terms & Definitions', text: terms),
        _OutputCard(title: 'Structured Notes', text: notes),
        _OutputCard(title: 'Paragraph Summary', text: paragraph),
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
    final options = question.options.isEmpty
        ? 'No options'
        : question.options.join('\n');

    return _OutputCard(
      title: 'Generated Question',
      text:
          '${question.question}\n\n$options\n\nCorrect Answer: ${question.answer}\n\nExplanation: ${question.explanation}',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey[700] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
