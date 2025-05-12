import 'package:untitled/models/capsule_content.dart';

enum CapsuleStatus {
  locked,
  unlocked,
  upcoming
}

enum CapsuleTheme {
  birthday,
  graduation,
  wedding,
  anniversary,
  personal,
  custom
}

class Capsule {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime unlockDate;
  final CapsuleStatus status;
  final CapsuleTheme theme;
  final List<CapsuleContent> contents;
  final String creatorId;
  final List<String> sharedWithIds;
  final bool isPublic;

  Capsule({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.unlockDate,
    required this.status,
    required this.theme,
    required this.contents,
    required this.creatorId,
    this.sharedWithIds = const [],
    this.isPublic = false,
  });

  factory Capsule.fromJson(Map<String, dynamic> json) {
    return Capsule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      unlockDate: DateTime.parse(json['unlockDate']),
      status: CapsuleStatus.values.byName(json['status']),
      theme: CapsuleTheme.values.byName(json['theme']),
      contents: (json['contents'] as List)
          .map((content) => CapsuleContent.fromJson(content))
          .toList(),
      creatorId: json['creatorId'],
      sharedWithIds: List<String>.from(json['sharedWithIds'] ?? []),
      isPublic: json['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'unlockDate': unlockDate.toIso8601String(),
      'status': status.name,
      'theme': theme.name,
      'contents': contents.map((content) => content.toJson()).toList(),
      'creatorId': creatorId,
      'sharedWithIds': sharedWithIds,
      'isPublic': isPublic,
    };
  }

  int get daysUntilUnlock {
    final now = DateTime.now();
    return unlockDate.difference(now).inDays;
  }

  bool get isUnlocked {
    return status == CapsuleStatus.unlocked;
  }

  Capsule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? unlockDate,
    CapsuleStatus? status,
    CapsuleTheme? theme,
    List<CapsuleContent>? contents,
    String? creatorId,
    List<String>? sharedWithIds,
    bool? isPublic,
  }) {
    return Capsule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      unlockDate: unlockDate ?? this.unlockDate,
      status: status ?? this.status,
      theme: theme ?? this.theme,
      contents: contents ?? this.contents,
      creatorId: creatorId ?? this.creatorId,
      sharedWithIds: sharedWithIds ?? this.sharedWithIds,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
