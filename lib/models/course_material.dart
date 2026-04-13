class CourseMaterial {
  final String title;
  final String fileUrl;
  final String professorName;

  CourseMaterial({
    required this.title,
    required this.fileUrl,
    required this.professorName,
  });

  // 1. Convert raw JSON map into a safe object
  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      title: json['title'] ?? 'Untitled Document',
      fileUrl: json['fileUrl'] ?? '',
      // Safely dig into the nested professor object
      professorName: json['professor']?['name'] ?? 'Unknown',
    );
  }

  // 2. Helper to build the full file URL
  String get fullFileUrl {
    if (fileUrl.isEmpty) return "";
    return "http://192.168.1.25:5000$fileUrl";
  }
}
