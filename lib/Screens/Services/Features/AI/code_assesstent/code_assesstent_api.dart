import 'package:dio/dio.dart';

class CodeAssesstentApi {
  CodeAssesstentApi({
    Dio? dio,
    String baseUrl = const String.fromEnvironment(
      'CODE_ASSISTANT_BASE_URL',
      defaultValue: 'http://192.168.1.5:10000/api/v1',
    ),
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  Future<CodeProjectUpload> uploadProject({
    required String projectId,
    required String filePath,
    required String fileName,
  }) async {
    final data = FormData.fromMap({
      'project_id': projectId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post('/projects/upload', data: data);
    return CodeProjectUpload.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<CodeAssistantReply> sendPrompt({
    required String projectId,
    required String prompt,
    required bool useProjectContext,
  }) async {
    final response = await _dio.post(
      '/quick-tasks/help',
      data: {
        'project_id': projectId,
        'prompt': prompt,
        'use_project_context': useProjectContext,
      },
    );

    return CodeAssistantReply.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

class CodeProjectUpload {
  const CodeProjectUpload({
    required this.message,
    required this.projectId,
    required this.status,
    required this.filesPath,
  });

  factory CodeProjectUpload.fromJson(Map<String, dynamic> json) {
    return CodeProjectUpload(
      message: json['message']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      filesPath: json['files_path']?.toString() ?? '',
    );
  }

  final String message;
  final String projectId;
  final String status;
  final String filesPath;
}

class CodeAssistantReply {
  const CodeAssistantReply({
    required this.projectId,
    required this.intent,
    required this.result,
    required this.lastCode,
    required this.outputFiles,
    required this.projectChunks,
    required this.codebaseChunks,
  });

  factory CodeAssistantReply.fromJson(Map<String, dynamic> json) {
    final context = json['context_used'] is Map
        ? Map<String, dynamic>.from(json['context_used'] as Map)
        : <String, dynamic>{};
    final rawFiles = json['output_files'];

    return CodeAssistantReply(
      projectId: json['project_id']?.toString() ?? '',
      intent: json['intent']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      lastCode: json['last_code']?.toString() ?? '',
      outputFiles: rawFiles is List
          ? rawFiles
                .whereType<Map>()
                .map((file) => Map<String, dynamic>.from(file))
                .toList()
          : const [],
      projectChunks:
          int.tryParse(context['project_chunks']?.toString() ?? '') ?? 0,
      codebaseChunks:
          int.tryParse(context['codebase_chunks']?.toString() ?? '') ?? 0,
    );
  }

  final String projectId;
  final String intent;
  final String result;
  final String lastCode;
  final List<Map<String, dynamic>> outputFiles;
  final int projectChunks;
  final int codebaseChunks;
}
