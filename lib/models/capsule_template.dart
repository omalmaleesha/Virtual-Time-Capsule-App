import 'package:flutter/material.dart';
import 'package:untitled/models/capsule.dart';

class CapsuleTemplate {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final Color primaryColor;
  final Color secondaryColor;
  final CapsuleTheme theme;
  final Duration defaultDuration;
  final List<String> suggestedContentTypes;
  final String backgroundImage;
  final List<String> promptQuestions;

  const CapsuleTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.theme,
    required this.defaultDuration,
    this.suggestedContentTypes = const [],
    this.backgroundImage = '',
    this.promptQuestions = const [],
  });

  // Create a capsule from this template
  Capsule createCapsule({
    required String title,
    required String description,
    required String creatorId,
    DateTime? unlockDate,
    bool isPublic = false,
  }) {
    final now = DateTime.now();
    return Capsule(
      id: '',  // Will be set by the service
      title: title,
      description: description,
      createdAt: now,
      unlockDate: unlockDate ?? now.add(defaultDuration),
      status: CapsuleStatus.locked,
      theme: theme,
      contents: [],
      creatorId: creatorId,
      isPublic: isPublic,
    );
  }
}
