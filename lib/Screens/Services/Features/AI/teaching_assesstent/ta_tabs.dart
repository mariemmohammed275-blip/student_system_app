import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'teaching_assesstent_api.dart';
import 'ta_shared_widgets.dart';
import 'ta_output_cards.dart';

// ─── Upload Tab ───────────────────────────────────────────────────────────────

class TaUploadTab extends StatelessWidget {
  const TaUploadTab({
    super.key,
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
    return TaTabScaffold(
      children: [
        const TaSectionTitle(
          title: 'Document Upload',
          subtitle: 'Upload PDF, TXT, DOCX, or audio files.',
        ),
        TaInputCard(
          child: Column(
            children: [
              TextField(
                controller: projectIdController,
                decoration: const InputDecoration(
                  labelText: 'Project ID',
                  hintText: 'biology-101',
                ),
              ),
              const SizedBox(height: 12),
              TaSecondaryButton(
                label: selectedFile?.name ?? 'Choose file',
                icon: Icons.attach_file,
                onPressed: loading ? null : onPickFile,
              ),
              const SizedBox(height: 12),
              TaPrimaryButton(
                label: loading ? 'Processing...' : 'Upload & Process',
                icon: Icons.upload_file,
                onPressed: loading ? null : onUpload,
              ),
            ],
          ),
        ),
        TaOutputCard(title: 'Processing Status', text: status),
      ],
    );
  }
}

// ─── Question Generation Tab ──────────────────────────────────────────────────

class TaQuestionGenerationTab extends StatelessWidget {
  const TaQuestionGenerationTab({
    super.key,
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
    return TaTabScaffold(
      children: [
        const TaSectionTitle(
          title: 'Question Generation',
          subtitle: 'Generate one question, then refine it with feedback.',
        ),
        TaInputCard(
          child: Column(
            children: [
              TaSegmentedChoices(
                value: questionType,
                values: const ['MCQ', 'T/F'],
                onChanged: onTypeChanged,
              ),
              const SizedBox(height: 12),
              TaPrimaryButton(
                label: loading ? 'Generating...' : 'Generate Question',
                icon: Icons.track_changes,
                onPressed: loading ? null : onGenerate,
              ),
            ],
          ),
        ),
        if (question != null)
          TaGeneratedQuestionCard(
            question: (
              question: question!.question,
              options: question!.options,
              answer: question!.answer,
              explanation: question!.explanation,
            ),
          ),
        TaInputCard(
          child: Column(
            children: [
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: "Type feedback, 'auto', or 'save'",
                ),
              ),
              const SizedBox(height: 12),
              TaSecondaryButton(
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

// ─── Exam Tab ─────────────────────────────────────────────────────────────────

class TaExamTab extends StatelessWidget {
  const TaExamTab({
    super.key,
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
    return TaTabScaffold(
      children: [
        const TaSectionTitle(
          title: 'AI-Generated Exam',
          subtitle: 'Generate, refine, then answer the exam questions.',
        ),
        TaInputCard(
          child: Column(
            children: [
              TaSegmentedChoices(
                value: questionType,
                values: const ['MCQ', 'T/F', 'Both'],
                onChanged: onTypeChanged,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Questions',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 50,
                      divisions: 49,
                      value: questionCount.toDouble(),
                      label: questionCount.toString(),
                      onChanged: (v) => onCountChanged(v.round()),
                    ),
                  ),
                  Text(questionCount.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              TaPrimaryButton(
                label: loading ? 'Generating...' : 'Generate Questions',
                icon: Icons.casino_outlined,
                onPressed: loading ? null : onGenerate,
              ),
            ],
          ),
        ),
        if (questions.isNotEmpty) ...[
          TaInputCard(
            child: Column(
              children: [
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback',
                    hintText: 'Make hard questions harder',
                  ),
                ),
                const SizedBox(height: 12),
                TaSecondaryButton(
                  label: 'Regenerate',
                  icon: Icons.refresh,
                  onPressed: loading ? null : onApplyFeedback,
                ),
              ],
            ),
          ),
          ...List.generate(questions.length, (index) {
            final q = questions[index];
            final options =
                q.options.isNotEmpty ? q.options : const ['True', 'False'];
            return TaInputCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaBadge(
                    text: '${taBadgeLabel(q.complexity)} · ${q.questionType}',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Q${index + 1}. ${q.question}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  ...options.map((option) => RadioListTile<String>(
                        value: option,
                        groupValue: answers[index],
                        onChanged: (v) => onAnswerChanged(index, v),
                        title: Text(option,
                            style: const TextStyle(fontSize: 14.5)),
                        contentPadding: EdgeInsets.zero,
                      )),
                ],
              ),
            );
          }),
          TaPrimaryButton(
            label: 'Submit & See Results',
            icon: Icons.check_circle_outline,
            onPressed: onSubmit,
          ),
          if (result.isNotEmpty) TaExamResultCard(result: result),
        ],
      ],
    );
  }
}

// ─── Q&A Tab ──────────────────────────────────────────────────────────────────

class TaQaTab extends StatelessWidget {
  const TaQaTab({
    super.key,
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
    return TaTabScaffold(
      children: [
        const TaSectionTitle(
          title: 'Q&A',
          subtitle: 'Ask anything about the uploaded document.',
        ),
        TaQuestionBox(
          controller: questionController,
          label: 'Your Question',
          buttonLabel: loading ? 'Asking...' : 'Ask',
          onPressed: loading ? null : onAsk,
        ),
        TaQaAnswerCard(
          title: 'Answer',
          text: answer,
          loading: loading && followUpAnswer.isEmpty,
        ),
        TaQuestionBox(
          controller: followUpController,
          label: 'Follow-up Question',
          buttonLabel: 'Ask Follow-up',
          onPressed: loading ? null : onFollowUp,
        ),
        TaQaAnswerCard(
          title: 'Follow-up Answer',
          text: followUpAnswer,
          loading: loading && answer.isNotEmpty,
        ),
      ],
    );
  }
}

// ─── Summary Tab ──────────────────────────────────────────────────────────────

class TaSummaryTab extends StatelessWidget {
  const TaSummaryTab({
    super.key,
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
    return TaTabScaffold(
      children: [
        const TaSectionTitle(
          title: 'Study Summary',
          subtitle: 'Generate key terms, recap, notes, and paragraph summary.',
        ),
        TaInputCard(
          child: Column(
            children: [
              TaSegmentedChoices(
                value: depth,
                values: const ['brief', 'standard', 'detailed'],
                onChanged: onDepthChanged,
              ),
              const SizedBox(height: 12),
              TaPrimaryButton(
                label: loading ? 'Generating...' : 'Generate Summary',
                icon: Icons.auto_awesome,
                onPressed: loading ? null : onGenerate,
              ),
            ],
          ),
        ),
        TaSummaryOutputCard(
            title: 'Quick Recap', icon: Icons.summarize_outlined, text: tldr),
        TaKeyTermsCard(termsRaw: terms),
        TaSummaryOutputCard(
            title: 'Structured Notes',
            icon: Icons.format_list_bulleted_rounded,
            text: notes),
        TaSummaryOutputCard(
            title: 'Paragraph Summary',
            icon: Icons.article_outlined,
            text: paragraph),
        TaInputCard(
          child: Column(
            children: [
              TextField(
                controller: feedbackController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: "Add examples, type 'auto', or 'save'",
                ),
              ),
              const SizedBox(height: 12),
              TaSecondaryButton(
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
