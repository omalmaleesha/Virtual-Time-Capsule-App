import 'package:untitled/models/user.dart';
import 'package:uuid/uuid.dart';

// Mock implementation - in a real app, this would connect to Firebase Auth or another auth provider
class AuthService {
  User? _currentUser;
  final Map<String, User> _users = {};
  final _uuid = const Uuid();

  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would validate credentials against a backend
    final user = _users.values.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('Invalid email or password'),
    );
    
    // Update last login
    final updatedUser = user.copyWith(
      lastLogin: DateTime.now(),
    );
    
    _users[updatedUser.id] = updatedUser;
    _currentUser = updatedUser;
    
    return updatedUser;
  }

  Future<User> register(String email, String password, String username) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if email already exists
    if (_users.values.any((user) => user.email == email)) {
      throw Exception('Email already in use');
    }
    
    // Check if username already exists
    if (_users.values.any((user) => user.username == username)) {
      throw Exception('Username already taken');
    }
    
    // Create new user
    final newUser = User(
      id: _uuid.v4(),
      email: email,
      username: username,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    
    _users[newUser.id] = newUser;
    _currentUser = newUser;
    
    return newUser;
  }

  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _currentUser = null;
  }

  Future<User?> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _currentUser;
  }

  Future<User> updateProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }
    
    final updatedUser = user.copyWith(
      displayName: displayName ?? user.displayName,
      photoUrl: photoUrl ?? user.photoUrl,
    );
    
    _users[userId] = updatedUser;
    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }
    
    return updatedUser;
  }
}
