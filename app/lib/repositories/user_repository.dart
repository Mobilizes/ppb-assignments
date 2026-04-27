import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/user.dart';

class UserRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _sessionKey = 'user_session_expiry';
  static const String _userIdKey = 'user_id';

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
Future<void> checkSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_sessionKey);
    final userId = prefs.getString(_userIdKey);

    if (expiryString != null && userId != null) {
      final expiryTime = DateTime.parse(expiryString);
      if (DateTime.now().isBefore(expiryTime)) {
        // Session is still valid, fetch user details
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          _currentUser = User.fromMap(doc.id, doc.data()!);
          notifyListeners();
          return;
        }
      }
    }
  } catch (e) {
    debugPrint("Session check failed: $e");
  }

  // Invalid or expired session
  await logout();
}
  Future<void> login(String email, String password) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('User not found.');
    }

    final doc = query.docs.first;
    final user = User.fromMap(doc.id, doc.data());

    if (user.hashedPassword != _hashPassword(password)) {
      throw Exception('Incorrect password.');
    }

    _currentUser = user;
    await _saveSession(user.id);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception('Email already exists.');
    }

    final docRef = await _firestore.collection('users').add({
      'email': email,
      'hashedPassword': _hashPassword(password),
    });

    _currentUser = User(
      id: docRef.id,
      email: email,
      hashedPassword: _hashPassword(password),
    );
    await _saveSession(docRef.id);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      debugPrint("Failed to logout or remove session: $e");
    }
    notifyListeners();
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final expiryTime = DateTime.now().add(const Duration(days: 7));
    await prefs.setString(_sessionKey, expiryTime.toIso8601String());
    await prefs.setString(_userIdKey, userId);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
