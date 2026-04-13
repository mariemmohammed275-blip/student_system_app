class Assignment {
  final String id;
  final String title;
  final String description;
  final String? file;
  final DateTime? deadline;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    this.file,
    this.deadline,
  });

  // 1. Factory method to convert raw JSON into a safe Dart Object
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled Assignment',
      description: json['description'] ?? 'No description provided.',
      file: json['file'],
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])
          : null,
    );
  }

  // 2. Helper to format the date neatly
  String get formattedDeadline {
    if (deadline == null) return "TBA";
    return "${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}";
  }

  // 3. Helper to build the full file URL
  String get fullFileUrl {
    if (file == null || file!.isEmpty) return "";
    return "http://192.168.1.25:5000$file";
  }
}
