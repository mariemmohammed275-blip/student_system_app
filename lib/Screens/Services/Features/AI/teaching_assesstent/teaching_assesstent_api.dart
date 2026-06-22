import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

class TeachingAssesstentApi {
  TeachingAssesstentApi({
    Dio? dio,
    String baseUrl = const String.fromEnvironment(
      'TEACHING_ASSISTANT_BASE_URL',
      defaultValue: 'http://192.168.1.5:9000/api/TA',
    ),
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  Future<ProcessedFile> uploadFile({
    required String projectId,
    required String filePath,
    required String fileName,
  }) async {
    final data = FormData.fromMap({
      'project_id': projectId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post('/fileProcessing', data: data);
    final body = Map<String, dynamic>.from(response.data as Map);

    return ProcessedFile(
      threadId: body['thread_id']?.toString() ?? '',
      uploadedFile: body['uploaded_file']?.toString() ?? '',
      textFile: body['text_file']?.toString() ?? '',
    );
  }

  Future<QuestionGenerationResult> startQuestionGeneration({
    required String projectId,
    required String questionType,
    required String cleanTextFilePath,
  }) async {
    final response = await _dio.post(
      '/start_session',
      data: {
        'project_id': projectId,
        'question_type': questionType,
        'clean_text_file_path': cleanTextFilePath,
      },
    );

    return QuestionGenerationResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<QuestionGenerationResult> continueQuestionGeneration({
    required String projectId,
    required String threadId,
    required String userFeedback,
    required String questionType,
    required String cleanTextFilePath,
  }) async {
    final response = await _dio.post(
      '/continue',
      data: {
        'project_id': projectId,
        'thread_id': threadId,
        'user_feedback': userFeedback,
        'question_type': questionType,
        'clean_text_file_path': cleanTextFilePath,
      },
    );

    return QuestionGenerationResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<BulkQuestionsResult> startBulkGeneration({
    required String projectId,
    required String questionType,
    required int numQuestions,
    required String cleanTextFilePath,
  }) async {
    final response = await _dio.post(
      '/start_bulk_session',
      data: {
        'project_id': projectId,
        'question_type': questionType,
        'num_questions': numQuestions,
        'clean_text_file_path': cleanTextFilePath,
      },
    );

    return BulkQuestionsResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<BulkQuestionsResult> continueBulkGeneration({
    required String threadId,
    required String userFeedback,
  }) async {
    final response = await _dio.post(
      '/bulk_continue',
      data: {'thread_id': threadId, 'user_feedback': userFeedback},
    );

    return BulkQuestionsResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Stream<AssistantStreamEvent> startQuestionAnswering({
    required String cleanTextFilePath,
    required String userQuestion,
  }) {
    return _postSse('/start_QA_session', {
      'clean_text_file_path': cleanTextFilePath,
      'user_question': userQuestion,
    });
  }

  Stream<AssistantStreamEvent> continueQuestionAnswering({
    required String threadId,
    required String userQuestion,
  }) {
    return _postSse('/QA_continue', {
      'thread_id': threadId,
      'user_question': userQuestion,
    });
  }

  Stream<AssistantStreamEvent> startSummarization({
    required String cleanTextFilePath,
    required String projectId,
    required String depth,
  }) {
    return _postSse('/start_SG_session', {
      'clean_text_file_path': cleanTextFilePath,
      'project_id': projectId,
      'depth': depth,
    });
  }

  Stream<AssistantStreamEvent> continueSummarization({
    required String projectId,
    required String cleanTextFilePath,
    required String threadId,
    required String userFeedback,
  }) {
    return _postSse('/SG_continue', {
      'project_id': projectId,
      'clean_text_file_path': cleanTextFilePath,
      'thread_id': threadId,
      'user_feedback': userFeedback,
    });
  }

  Stream<AssistantStreamEvent> _postSse(
    String path,
    Map<String, dynamic> data,
  ) async* {
    final response = await _dio.post<ResponseBody>(
      path,
      data: data,
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (!line.startsWith('data: ')) {
        continue;
      }

      final payload = line.substring(6);
      if (payload.trim().isEmpty) {
        continue;
      }

      yield AssistantStreamEvent.fromJson(
        Map<String, dynamic>.from(jsonDecode(payload) as Map),
      );
    }
  }
}

class ProcessedFile {
  const ProcessedFile({
    required this.threadId,
    required this.uploadedFile,
    required this.textFile,
  });

  final String threadId;
  final String uploadedFile;
  final String textFile;
}

class QuestionGenerationResult {
  const QuestionGenerationResult({
    required this.threadId,
    required this.question,
  });

  factory QuestionGenerationResult.fromJson(Map<String, dynamic> json) {
    return QuestionGenerationResult(
      threadId: json['thread_id']?.toString() ?? '',
      question: GeneratedQuestion.fromJson(
        Map<String, dynamic>.from((json['graph_response'] ?? {}) as Map),
      ),
    );
  }

  final String threadId;
  final GeneratedQuestion question;
}

class GeneratedQuestion {
  const GeneratedQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions.map((option) => option.toString()).toList()
        : rawOptions is String && rawOptions.trim().isNotEmpty
        ? rawOptions
              .split('\n')
              .where((option) => option.trim().isNotEmpty)
              .toList()
        : <String>[];

    return GeneratedQuestion(
      question: json['question']?.toString() ?? '',
      options: options,
      answer: json['answer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  final String question;
  final List<String> options;
  final String answer;
  final String explanation;
}

class BulkQuestionsResult {
  const BulkQuestionsResult({required this.threadId, required this.questions});

  factory BulkQuestionsResult.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];

    return BulkQuestionsResult(
      threadId: json['thread_id']?.toString() ?? '',
      questions: rawQuestions is List
          ? rawQuestions
                .map(
                  (question) => ExamQuestion.fromJson(
                    Map<String, dynamic>.from(question as Map),
                  ),
                )
                .toList()
          : <ExamQuestion>[],
    );
  }

  final String threadId;
  final List<ExamQuestion> questions;
}

class ExamQuestion {
  const ExamQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.questionType,
    required this.complexity,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return ExamQuestion(
      question: json['question']?.toString() ?? '',
      options: rawOptions is List
          ? rawOptions.map((option) => option.toString()).toList()
          : <String>[],
      answer: json['answer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      questionType: json['question_type']?.toString() ?? '',
      complexity: json['complexity']?.toString() ?? '',
    );
  }

  final String question;
  final List<String> options;
  final String answer;
  final String explanation;
  final String questionType;
  final String complexity;
}

class AssistantStreamEvent {
  const AssistantStreamEvent({
    required this.event,
    required this.threadId,
    this.token = '',
    this.section = '',
    this.payload,
  });

  factory AssistantStreamEvent.fromJson(Map<String, dynamic> json) {
    return AssistantStreamEvent(
      event: json['event']?.toString() ?? '',
      threadId: json['thread_id']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
    );
  }

  final String event;
  final String threadId;
  final String token;
  final String section;
  final Map<String, dynamic>? payload;
}
