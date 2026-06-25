import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'teaching_assesstent_api.dart';
import 'ta_theme.dart';
import 'ta_tabs.dart';

class TeachingAssesstentScreen extends StatefulWidget {
  const TeachingAssesstentScreen({super.key});

  @override
  State<TeachingAssesstentScreen> createState() =>
      _TeachingAssesstentScreenState();
}

class _TeachingAssesstentScreenState
    extends State<TeachingAssesstentScreen> {
  // ── API ────────────────────────────────────────────────────────────────────
  final TeachingAssesstentApi _api = TeachingAssesstentApi();

  // ── Controllers ────────────────────────────────────────────────────────────
  final _projectIdController      = TextEditingController();
  final _qgFeedbackController     = TextEditingController();
  final _bulkFeedbackController   = TextEditingController();
  final _qaQuestionController     = TextEditingController();
  final _qaFollowUpController     = TextEditingController();
  final _summaryFeedbackController = TextEditingController();

  // ── Upload state ───────────────────────────────────────────────────────────
  PlatformFile? _selectedFile;
  String _uploadStatus    = 'Choose a file and project ID to start.';
  String _cleanTextFilePath = '';
  bool   _loadingUpload   = false;

  // ── Question Gen state ─────────────────────────────────────────────────────
  String            _qgType     = 'MCQ';
  String            _qgThreadId = '';
  GeneratedQuestion? _generatedQuestion;
  bool              _loadingQG  = false;

  // ── Exam state ─────────────────────────────────────────────────────────────
  String            _bulkType      = 'MCQ';
  int               _numQuestions  = 5;
  String            _examThreadId  = '';
  List<ExamQuestion> _examQuestions = [];
  List<String?>     _examAnswers   = [];
  String            _examResult    = '';
  bool              _loadingBulk   = false;

  // ── Q&A state ──────────────────────────────────────────────────────────────
  String _qaThreadId      = '';
  String _qaAnswer        = '';
  String _qaFollowUpAnswer = '';
  bool   _streamingQA     = false;

  // ── Summary state ──────────────────────────────────────────────────────────
  String _summaryDepth    = 'standard';
  String _summaryThreadId = '';
  String _summaryTerms    = '';
  String _summaryTldr     = '';
  String _summaryNotes    = '';
  String _summaryParagraph = '';
  bool   _streamingSummary = false;

  bool get _hasProcessedFile => _cleanTextFilePath.isNotEmpty;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

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

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx', 'mp3', 'wav', 'm4a'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.single);
  }

  Future<void> _uploadFile() async {
    final file      = _selectedFile;
    final projectId = _projectIdController.text.trim();
    if (file == null || file.path == null || projectId.isEmpty) {
      _showMessage('File and Project ID are required.');
      return;
    }
    setState(() => _loadingUpload = true);
    try {
      final processed = await _api.uploadFile(
        projectId: projectId,
        filePath:  file.path!,
        fileName:  file.name,
      );
      setState(() {
        _cleanTextFilePath = processed.textFile;
        _uploadStatus =
            'File processed successfully.\n\nYou can now use any AI features.';
      });
    } catch (e) {
      _showMessage('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _loadingUpload = false);
    }
  }

  // ── Question Generation ────────────────────────────────────────────────────

  Future<void> _startQuestionGeneration() async {
    if (!_ensureProcessedFile()) return;
    setState(() => _loadingQG = true);
    try {
      final result = await _api.startQuestionGeneration(
        projectId:        _projectIdController.text.trim(),
        questionType:     _qgType,
        cleanTextFilePath: _cleanTextFilePath,
      );
      setState(() {
        _qgThreadId        = result.threadId;
        _generatedQuestion = result.question;
      });
    } catch (e) {
      _showMessage('Question generation failed: $e');
    } finally {
      if (mounted) setState(() => _loadingQG = false);
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
        projectId:        _projectIdController.text.trim(),
        threadId:         _qgThreadId,
        userFeedback:     _qgFeedbackController.text.trim(),
        questionType:     _qgType,
        cleanTextFilePath: _cleanTextFilePath,
      );
      setState(() {
        _qgThreadId        = result.threadId;
        _generatedQuestion = result.question;
      });
      _qgFeedbackController.clear();
    } catch (e) {
      _showMessage('Feedback failed: $e');
    } finally {
      if (mounted) setState(() => _loadingQG = false);
    }
  }

  // ── Exam ───────────────────────────────────────────────────────────────────

  Future<void> _startBulkGeneration() async {
    if (!_ensureProcessedFile()) return;
    setState(() { _loadingBulk = true; _examResult = ''; });
    try {
      final result = await _api.startBulkGeneration(
        projectId:        _projectIdController.text.trim(),
        questionType:     _bulkType,
        numQuestions:     _numQuestions,
        cleanTextFilePath: _cleanTextFilePath,
      );
      setState(() {
        _examThreadId  = result.threadId;
        _examQuestions = result.questions;
        _examAnswers   = List<String?>.filled(result.questions.length, null);
      });
    } catch (e) {
      _showMessage('Exam generation failed: $e');
    } finally {
      if (mounted) setState(() => _loadingBulk = false);
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
        threadId:     _examThreadId,
        userFeedback: _bulkFeedbackController.text.trim(),
      );
      setState(() {
        _examQuestions = result.questions;
        _examAnswers   = List<String?>.filled(result.questions.length, null);
      });
      _bulkFeedbackController.clear();
    } catch (e) {
      _showMessage('Exam feedback failed: $e');
    } finally {
      if (mounted) setState(() => _loadingBulk = false);
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
      final q       = _examQuestions[i];
      final answer  = _examAnswers[i];
      var normalized = answer ?? '';
      if (q.questionType == 'MCQ' &&
          normalized.length > 1 &&
          normalized[1] == '.') {
        normalized = normalized[0].toUpperCase();
      }
      final isCorrect = normalized.toUpperCase() == q.answer.toUpperCase();
      if (isCorrect) correct++;
      lines.add(
        '${isCorrect ? 'Correct' : 'Wrong'} - Q${i + 1}: ${q.question}\n'
        'Your answer: ${answer ?? 'No answer'}\n'
        'Correct answer: ${q.answer}\n'
        'Explanation: ${q.explanation}',
      );
    }
    final percent =
        (correct / (_examQuestions.isEmpty ? 1 : _examQuestions.length) * 100)
            .round();
    setState(() {
      _examResult =
          'Score: $correct/${_examQuestions.length} ($percent%)\n\n'
          '${lines.join('\n\n')}';
    });
  }

  // ── Q&A ────────────────────────────────────────────────────────────────────

  Future<void> _askQuestion({required bool followUp}) async {
    if (!_ensureProcessedFile()) return;
    final controller =
        followUp ? _qaFollowUpController : _qaQuestionController;
    final question = controller.text.trim();
    if (question.isEmpty) { _showMessage('Write your question first.'); return; }

    setState(() {
      _streamingQA = true;
      if (followUp) { _qaFollowUpAnswer = ''; } else { _qaAnswer = ''; }
    });
    try {
      final stream = followUp && _qaThreadId.isNotEmpty
          ? _api.continueQuestionAnswering(
              threadId: _qaThreadId, userQuestion: question)
          : _api.startQuestionAnswering(
              cleanTextFilePath: _cleanTextFilePath, userQuestion: question);

      await for (final event in stream) {
        if (!mounted) return;
        if (event.threadId.isNotEmpty) _qaThreadId = event.threadId;
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
    } catch (e) {
      _showMessage('Q&A failed: $e');
    } finally {
      if (mounted) setState(() => _streamingQA = false);
    }
  }

  // ── Summary ────────────────────────────────────────────────────────────────

  Future<void> _startSummarization() async {
    if (!_ensureProcessedFile()) return;
    setState(() {
      _streamingSummary = true;
      _summaryTerms = _summaryTldr = _summaryNotes = _summaryParagraph = '';
    });
    try {
      await _consumeSummaryStream(_api.startSummarization(
        cleanTextFilePath: _cleanTextFilePath,
        projectId:         _projectIdController.text.trim(),
        depth:             _summaryDepth,
      ));
    } catch (e) {
      _showMessage('Summarization failed: $e');
    } finally {
      if (mounted) setState(() => _streamingSummary = false);
    }
  }

  Future<void> _continueSummarization() async {
    if (_summaryThreadId.isEmpty) {
      _showMessage('Generate a summary first.');
      return;
    }
    setState(() {
      _streamingSummary = true;
      _summaryTerms = _summaryTldr = _summaryNotes = _summaryParagraph = '';
    });
    try {
      await _consumeSummaryStream(_api.continueSummarization(
        projectId:         _projectIdController.text.trim(),
        cleanTextFilePath: _cleanTextFilePath,
        threadId:          _summaryThreadId,
        userFeedback:      _summaryFeedbackController.text.trim(),
      ));
      _summaryFeedbackController.clear();
    } catch (e) {
      _showMessage('Summary feedback failed: $e');
    } finally {
      if (mounted) setState(() => _streamingSummary = false);
    }
  }

  Future<void> _consumeSummaryStream(
      Stream<AssistantStreamEvent> stream) async {
    await for (final event in stream) {
      if (!mounted) return;
      if (event.threadId.isNotEmpty) _summaryThreadId = event.threadId;
      if (event.event == 'token') {
        setState(() {
          switch (event.section) {
            case 'key_terms':        _summaryTerms     += event.token; break;
            case 'tldr':             _summaryTldr      += event.token; break;
            case 'structured_notes': _summaryNotes     += event.token; break;
            case 'paragraph_summary':
            case 'rewriter':         _summaryParagraph += event.token; break;
          }
        });
      } else if (event.event == 'interrupt' && event.payload != null) {
        final p = event.payload!;
        setState(() {
          _summaryTerms     = p['key_terms']?.toString()       ?? _summaryTerms;
          _summaryTldr      = p['tldr']?.toString()            ?? _summaryTldr;
          _summaryNotes     = p['structured_notes']?.toString() ?? _summaryNotes;
          _summaryParagraph = p['paragraph_summary']?.toString() ?? _summaryParagraph;
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _ensureProcessedFile() {
    if (_hasProcessedFile) return true;
    _showMessage('Upload and process a file first.');
    return false;
  }

  void _showMessage(String message) {
    Get.snackbar('Teaching Assistant', message,
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.blueAccent : taPrimary;
    final bgColor     = isDark ? Colors.grey[900] : taBackground;

    return DefaultTabController(
      length: 5,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary:   primaryColor,
            secondary: taSecondary,
            tertiary:  taAccent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : taBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : taBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            labelStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(
                  color: primaryColor.withValues(alpha: 0.5), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            systemOverlayStyle: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            elevation: 0,
            backgroundColor: bgColor,
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
                  child: Icon(Icons.school_outlined,
                      color: primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Teaching Assistant',
                    style: TextStyle(fontWeight: FontWeight.w700)),
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
                      color: isDark ? Colors.grey[800]! : taBorder),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white70 : Colors.black87,
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
              TaUploadTab(
                selectedFile:        _selectedFile,
                projectIdController: _projectIdController,
                status:              _uploadStatus,
                loading:             _loadingUpload,
                onPickFile:          _pickFile,
                onUpload:            _uploadFile,
              ),
              TaQuestionGenerationTab(
                questionType:       _qgType,
                loading:            _loadingQG,
                question:           _generatedQuestion,
                feedbackController: _qgFeedbackController,
                onTypeChanged:      (v) => setState(() => _qgType = v),
                onGenerate:         _startQuestionGeneration,
                onApplyFeedback:    _continueQuestionGeneration,
              ),
              TaExamTab(
                questionType:       _bulkType,
                questionCount:      _numQuestions,
                loading:            _loadingBulk,
                questions:          _examQuestions,
                answers:            _examAnswers,
                result:             _examResult,
                feedbackController: _bulkFeedbackController,
                onTypeChanged:      (v) => setState(() => _bulkType = v),
                onCountChanged:     (v) => setState(() => _numQuestions = v),
                onGenerate:         _startBulkGeneration,
                onApplyFeedback:    _applyBulkFeedback,
                onAnswerChanged:    (i, v) =>
                    setState(() => _examAnswers[i] = v),
                onSubmit:           _scoreExam,
              ),
              TaQaTab(
                questionController:  _qaQuestionController,
                followUpController:  _qaFollowUpController,
                answer:              _qaAnswer,
                followUpAnswer:      _qaFollowUpAnswer,
                loading:             _streamingQA,
                onAsk:               () => _askQuestion(followUp: false),
                onFollowUp:          () => _askQuestion(followUp: true),
              ),
              TaSummaryTab(
                depth:              _summaryDepth,
                loading:            _streamingSummary,
                terms:              _summaryTerms,
                tldr:               _summaryTldr,
                notes:              _summaryNotes,
                paragraph:          _summaryParagraph,
                feedbackController: _summaryFeedbackController,
                onDepthChanged:     (v) => setState(() => _summaryDepth = v),
                onGenerate:         _startSummarization,
                onApplyFeedback:    _continueSummarization,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
