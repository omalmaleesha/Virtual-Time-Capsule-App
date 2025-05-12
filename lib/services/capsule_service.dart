import 'package:untitled/models/capsule.dart';
import 'package:untitled/models/capsule_content.dart';
import 'package:uuid/uuid.dart';

// Mock implementation - in a real app, this would connect to a backend service
class CapsuleService {
  final Map<String, Capsule> _capsules = {};
  final _uuid = const Uuid();

  Future<List<Capsule>> getCapsulesByUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Filter capsules by creator or shared with
    return _capsules.values
        .where((capsule) => 
            capsule.creatorId == userId || 
            capsule.sharedWithIds.contains(userId) ||
            capsule.isPublic)
        .toList();
  }

  Future<Capsule> getCapsuleById(String capsuleId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final capsule = _capsules[capsuleId];
    if (capsule == null) {
      throw Exception('Capsule not found');
    }
    
    return capsule;
  }

  Future<Capsule> createCapsule(Capsule capsule) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final newCapsule = capsule.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    
    _capsules[newCapsule.id] = newCapsule;
    
    return newCapsule;
  }

  Future<Capsule> updateCapsule(Capsule capsule) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!_capsules.containsKey(capsule.id)) {
      throw Exception('Capsule not found');
    }
    
    _capsules[capsule.id] = capsule;
    
    return capsule;
  }

  Future<void> deleteCapsule(String capsuleId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!_capsules.containsKey(capsuleId)) {
      throw Exception('Capsule not found');
    }
    
    _capsules.remove(capsuleId);
  }

  Future<Capsule> addContentToCapsule(String capsuleId, CapsuleContent content) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final capsule = _capsules[capsuleId];
    if (capsule == null) {
      throw Exception('Capsule not found');
    }
    
    final newContent = CapsuleContent(
      id: _uuid.v4(),
      type: content.type,
      title: content.title,
      content: content.content,
      createdAt: DateTime.now(),
      metadata: content.metadata,
    );
    
    final updatedContents = List<CapsuleContent>.from(capsule.contents)..add(newContent);
    
    final updatedCapsule = capsule.copyWith(
      contents: updatedContents,
    );
    
    _capsules[capsuleId] = updatedCapsule;
    
    return updatedCapsule;
  }

  Future<Capsule> removeContentFromCapsule(String capsuleId, String contentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final capsule = _capsules[capsuleId];
    if (capsule == null) {
      throw Exception('Capsule not found');
    }
    
    final updatedContents = List<CapsuleContent>.from(capsule.contents)
      ..removeWhere((content) => content.id == contentId);
    
    final updatedCapsule = capsule.copyWith(
      contents: updatedContents,
    );
    
    _capsules[capsuleId] = updatedCapsule;
    
    return updatedCapsule;
  }

  Future<Capsule> shareCapsule(String capsuleId, List<String> userIds) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final capsule = _capsules[capsuleId];
    if (capsule == null) {
      throw Exception('Capsule not found');
    }
    
    final updatedSharedWithIds = List<String>.from(capsule.sharedWithIds)
      ..addAll(userIds.where((id) => !capsule.sharedWithIds.contains(id)));
    
    final updatedCapsule = capsule.copyWith(
      sharedWithIds: updatedSharedWithIds,
    );
    
    _capsules[capsuleId] = updatedCapsule;
    
    return updatedCapsule;
  }
}
