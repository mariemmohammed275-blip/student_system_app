class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool seen;
  final String type;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.seen,
    required this.type,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? 'No Content',
      seen: json['seen'] ?? false,
      type: json['type'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
