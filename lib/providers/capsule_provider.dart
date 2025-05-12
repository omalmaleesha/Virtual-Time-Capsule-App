import 'package:flutter/material.dart';
import 'package:untitled/models/capsule.dart';
import 'package:untitled/models/capsule_content.dart';
import 'package:untitled/services/capsule_service.dart';

class CapsuleProvider extends ChangeNotifier {
  final CapsuleService _capsuleService = CapsuleService();
  List<Capsule> _capsules = [];
  Capsule? _selectedCapsule;
  bool _isLoading = false;
  String? _error;

  List<Capsule> get capsules => _capsules;
  Capsule? get selectedCapsule => _selectedCapsule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Capsule> get lockedCapsules => 
      _capsules.where((capsule) => capsule.status == CapsuleStatus.locked).toList();
  
  List<Capsule> get unlockedCapsules => 
      _capsules.where((capsule) => capsule.status == CapsuleStatus.unlocked).toList();
  
  List<Capsule> get upcomingCapsules => 
      _capsules.where((capsule) => capsule.status == CapsuleStatus.upcoming).toList();

  Future<void> fetchCapsules(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _capsules = await _capsuleService.getCapsulesByUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCapsuleById(String capsuleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCapsule = await _capsuleService.getCapsuleById(capsuleId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createCapsule(Capsule capsule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCapsule = await _capsuleService.createCapsule(capsule);
      _capsules.add(newCapsule);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCapsule(Capsule capsule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCapsule = await _capsuleService.updateCapsule(capsule);
      
      final index = _capsules.indexWhere((c) => c.id == capsule.id);
      if (index != -1) {
        _capsules[index] = updatedCapsule;
      }
      
      if (_selectedCapsule?.id == capsule.id) {
        _selectedCapsule = updatedCapsule;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCapsule(String capsuleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _capsuleService.deleteCapsule(capsuleId);
      
      _capsules.removeWhere((capsule) => capsule.id == capsuleId);
      
      if (_selectedCapsule?.id == capsuleId) {
        _selectedCapsule = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addContentToCapsule(String capsuleId, CapsuleContent content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCapsule = await _capsuleService.addContentToCapsule(capsuleId, content);
      
      final index = _capsules.indexWhere((c) => c.id == capsuleId);
      if (index != -1) {
        _capsules[index] = updatedCapsule;
      }
      
      if (_selectedCapsule?.id == capsuleId) {
        _selectedCapsule = updatedCapsule;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeContentFromCapsule(String capsuleId, String contentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCapsule = await _capsuleService.removeContentFromCapsule(capsuleId, contentId);
      
      final index = _capsules.indexWhere((c) => c.id == capsuleId);
      if (index != -1) {
        _capsules[index] = updatedCapsule;
      }
      
      if (_selectedCapsule?.id == capsuleId) {
        _selectedCapsule = updatedCapsule;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> shareCapsule(String capsuleId, List<String> userIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCapsule = await _capsuleService.shareCapsule(capsuleId, userIds);
      
      final index = _capsules.indexWhere((c) => c.id == capsuleId);
      if (index != -1) {
        _capsules[index] = updatedCapsule;
      }
      
      if (_selectedCapsule?.id == capsuleId) {
        _selectedCapsule = updatedCapsule;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedCapsule() {
    _selectedCapsule = null;
    notifyListeners();
  }
}
