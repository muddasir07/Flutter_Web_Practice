import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

abstract class AuthRepository {
  Future<bool> signup(String username, String email, String password);
  Future<User?> login(String username, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}

class AuthRepositoryImpl implements AuthRepository {
  final Box<User> userBox;
  final Box authBox;

  AuthRepositoryImpl({
    required this.userBox,
    required this.authBox,
  });

  @override
  Future<bool> signup(String username, String email, String password) async {
    try {
      // Check if username already exists
      for (final user in userBox.values) {
        if (user.username.toLowerCase() == username.toLowerCase() ||
            user.email.toLowerCase() == email.toLowerCase()) {
          return false; // User already exists
        }
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        password: password, // In production, hash this password
        createdAt: DateTime.now(),
      );

      await userBox.put(user.id, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User?> login(String username, String password) async {
    try {
      for (final user in userBox.values) {
        if ((user.username.toLowerCase() == username.toLowerCase() ||
                user.email.toLowerCase() == username.toLowerCase()) &&
            user.password == password) {
          // Store current user ID
          await authBox.put('currentUserId', user.id);
          return user;
        }
      }
      return null; // User not found or wrong password
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await authBox.delete('currentUserId');
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userId = authBox.get('currentUserId') as String?;
      if (userId != null) {
        return userBox.get(userId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final userId = authBox.get('currentUserId') as String?;
    return userId != null && userBox.containsKey(userId);
  }
}

