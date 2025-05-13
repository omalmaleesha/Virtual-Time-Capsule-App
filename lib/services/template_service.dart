import 'package:flutter/material.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/models/capsule_template.dart';
import 'package:untitled/theme/app_theme.dart';

class TemplateService {
  // Singleton pattern
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  // Get all available templates
  List<CapsuleTemplate> getAllTemplates() {
    return [
      _birthdayTemplate,
      _graduationTemplate,
      _weddingTemplate,
      _anniversaryTemplate,
      _newYearTemplate,
      _timeCapsulesTemplate,
      _letterToFutureTemplate,
      _travelMemoriesTemplate,
    ];
  }

  // Get a template by ID
  CapsuleTemplate? getTemplateById(String id) {
    try {
      return getAllTemplates().firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  // Pre-defined templates
  final CapsuleTemplate _birthdayTemplate = CapsuleTemplate(
    id: 'birthday',
    name: 'Birthday Memories',
    description: 'Capture special moments from a birthday celebration to revisit in the future.',
    iconPath: 'assets/icons/birthday.png',
    primaryColor: const Color(0xFFFF5252),
    secondaryColor: const Color(0xFFFF8A80),
    theme: CapsuleTheme.birthday,
    defaultDuration: const Duration(days: 365), // 1 year
    suggestedContentTypes: ['photos', 'videos', 'messages'],
    backgroundImage: 'assets/backgrounds/birthday_bg.jpg',
    promptQuestions: [
      'What was the most memorable moment of the celebration?',
      'Who attended the birthday party?',
      'What gifts were received?',
      'What wishes do you have for the next year?',
    ],
  );

  final CapsuleTemplate _graduationTemplate = CapsuleTemplate(
    id: 'graduation',
    name: 'Graduation Milestone',
    description: 'Preserve achievements and memories from your graduation to look back on.',
    iconPath: 'assets/icons/graduation.png',
    primaryColor: const Color(0xFF5C6BC0),
    secondaryColor: const Color(0xFF7986CB),
    theme: CapsuleTheme.graduation,
    defaultDuration: const Duration(days: 1825), // 5 years
    suggestedContentTypes: ['photos', 'videos', 'certificates', 'messages'],
    backgroundImage: 'assets/backgrounds/graduation_bg.jpg',
    promptQuestions: [
      'What was your biggest achievement during your education?',
      'What are your career aspirations?',
      'Who helped you the most during your studies?',
      'What advice would you give to your future self?',
    ],
  );

  final CapsuleTemplate _weddingTemplate = CapsuleTemplate(
    id: 'wedding',
    name: 'Wedding Time Capsule',
    description: 'Save special moments from your wedding day to celebrate your anniversary.',
    iconPath: 'assets/icons/wedding.png',
    primaryColor: const Color(0xFF9C27B0),
    secondaryColor: const Color(0xFFBA68C8),
    theme: CapsuleTheme.wedding,
    defaultDuration: const Duration(days: 365), // 1 year (first anniversary)
    suggestedContentTypes: ['photos', 'videos', 'vows', 'messages'],
    backgroundImage: 'assets/backgrounds/wedding_bg.jpg',
    promptQuestions: [
      'What was your favorite moment from your wedding day?',
      'What are your hopes and dreams for your marriage?',
      'What do you love most about your partner?',
      'What are you looking forward to experiencing together?',
    ],
  );

  final CapsuleTemplate _anniversaryTemplate = CapsuleTemplate(
    id: 'anniversary',
    name: 'Anniversary Memories',
    description: 'Collect memories from your relationship to open on a future anniversary.',
    iconPath: 'assets/icons/anniversary.png',
    primaryColor: const Color(0xFFE91E63),
    secondaryColor: const Color(0xFFF48FB1),
    theme: CapsuleTheme.anniversary,
    defaultDuration: const Duration(days: 365), // 1 year
    suggestedContentTypes: ['photos', 'videos', 'letters', 'messages'],
    backgroundImage: 'assets/backgrounds/anniversary_bg.jpg',
    promptQuestions: [
      'What has been your favorite memory together this year?',
      'How has your relationship grown?',
      'What are you looking forward to in the coming year?',
      'What do you appreciate most about your partner?',
    ],
  );

  final CapsuleTemplate _newYearTemplate = CapsuleTemplate(
    id: 'new_year',
    name: 'New Year Resolutions',
    description: 'Record your goals and aspirations for the year to review next New Year\'s Eve.',
    iconPath: 'assets/icons/new_year.png',
    primaryColor: const Color(0xFF00BCD4),
    secondaryColor: const Color(0xFF4DD0E1),
    theme: CapsuleTheme.personal,
    defaultDuration: const Duration(days: 365), // 1 year
    suggestedContentTypes: ['goals', 'messages', 'photos'],
    backgroundImage: 'assets/backgrounds/new_year_bg.jpg',
    promptQuestions: [
      'What are your top goals for the coming year?',
      'What do you hope to accomplish personally and professionally?',
      'What habits do you want to develop?',
      'Where do you see yourself at the end of the year?',
    ],
  );

  final CapsuleTemplate _timeCapsulesTemplate = CapsuleTemplate(
    id: 'time_capsule',
    name: 'Classic Time Capsule',
    description: 'Create a traditional time capsule with items representing the current time.',
    iconPath: 'assets/icons/time_capsule.png',
    primaryColor: AppTheme.primaryColor,
    secondaryColor: AppTheme.secondaryColor,
    theme: CapsuleTheme.personal,
    defaultDuration: const Duration(days: 3650), // 10 years
    suggestedContentTypes: ['photos', 'videos', 'news', 'messages'],
    backgroundImage: 'assets/backgrounds/time_capsule_bg.jpg',
    promptQuestions: [
      'What are the most significant current events?',
      'What technology do you use daily?',
      'What predictions do you have for the future?',
      'What would you like to tell your future self?',
    ],
  );

  final CapsuleTemplate _letterToFutureTemplate = CapsuleTemplate(
    id: 'letter_to_future',
    name: 'Letter to Future Self',
    description: 'Write a letter to your future self with thoughts, hopes, and questions.',
    iconPath: 'assets/icons/letter.png',
    primaryColor: const Color(0xFF4CAF50),
    secondaryColor: const Color(0xFF81C784),
    theme: CapsuleTheme.personal,
    defaultDuration: const Duration(days: 1825), // 5 years
    suggestedContentTypes: ['messages', 'photos'],
    backgroundImage: 'assets/backgrounds/letter_bg.jpg',
    promptQuestions: [
      'What are you currently struggling with?',
      'What are your biggest hopes and dreams?',
      'What advice would you give to your future self?',
      'What questions would you like to ask your future self?',
    ],
  );

  final CapsuleTemplate _travelMemoriesTemplate = CapsuleTemplate(
    id: 'travel_memories',
    name: 'Travel Memories',
    description: 'Preserve memories from a special trip to revisit in the future.',
    iconPath: 'assets/icons/travel.png',
    primaryColor: const Color(0xFFFF9800),
    secondaryColor: const Color(0xFFFFB74D),
    theme: CapsuleTheme.personal,
    defaultDuration: const Duration(days: 365), // 1 year
    suggestedContentTypes: ['photos', 'videos', 'souvenirs', 'messages'],
    backgroundImage: 'assets/backgrounds/travel_bg.jpg',
    promptQuestions: [
      'What was your favorite place visited?',
      'What was the most memorable experience?',
      'What did you learn from this trip?',
      'What would you do differently next time?',
    ],
  );
}
