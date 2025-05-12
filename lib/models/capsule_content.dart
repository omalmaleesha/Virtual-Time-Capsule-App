enum ContentType {
  text,
  image,
  video,
  audio
}

class CapsuleContent {
  final String id;
  final ContentType type;
  final String title;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  CapsuleContent({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
    this.metadata,
  });

  factory CapsuleContent.fromJson(Map<String, dynamic> json) {
    return CapsuleContent(
      id: json['id'],
      type: ContentType.values.byName(json['type']),
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
