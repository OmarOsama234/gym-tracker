import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart' as app_user;

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  app_user.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _loadUserFromLocal(firebaseUser.uid);
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize auth: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<app_user.User?> signUp({
    required String email,
    required String password,
    required String displayName,
    required app_user.UserRole role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);

        // Create app user
        final user = app_user.User(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isFirstLogin: true,
        );

        // Save user locally
        await _saveUserToLocal(user);
        _currentUser = user;
        
        notifyListeners();
        return user;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<app_user.User?> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserFromLocal(credential.user!.uid);
        
        if (_currentUser != null) {
          _currentUser!.lastLoginAt = DateTime.now();
          await _saveUserToLocal(_currentUser!);
        }
        
        notifyListeners();
        return _currentUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<app_user.User?> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        
        // Check if user exists locally
        await _loadUserFromLocal(firebaseUser.uid);
        
        if (_currentUser == null) {
          // New user, need to set role
          return null; // Will redirect to role selection
        } else {
          _currentUser!.lastLoginAt = DateTime.now();
          await _saveUserToLocal(_currentUser!);
        }
        
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      _errorMessage = 'Google sign-in failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? bio,
    int? age,
    String? phoneNumber,
    List<String>? interests,
  }) async {
    if (_currentUser == null) return;

    try {
      if (displayName != null) _currentUser!.displayName = displayName;
      if (bio != null) _currentUser!.bio = bio;
      if (age != null) _currentUser!.age = age;
      if (phoneNumber != null) _currentUser!.phoneNumber = phoneNumber;
      if (interests != null) _currentUser!.interests = interests;

      await _saveUserToLocal(_currentUser!);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
    }
  }

  Future<void> completeFirstLogin() async {
    if (_currentUser == null) return;
    
    _currentUser!.isFirstLogin = false;
    await _saveUserToLocal(_currentUser!);
    notifyListeners();
  }

  Future<void> updateUserRole(app_user.UserRole role) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    try {
      // Create new user with role if doesn't exist
      if (_currentUser == null) {
        _currentUser = app_user.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isFirstLogin: true,
        );
      } else {
        _currentUser!.role = role;
      }
      
      await _saveUserToLocal(_currentUser!);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update user role: ${e.toString()}';
    }
  }

  Future<void> _loadUserFromLocal(String userId) async {
    final box = await Hive.openBox<app_user.User>('users');
    _currentUser = box.get(userId);
  }

  Future<void> _saveUserToLocal(app_user.User user) async {
    final box = await Hive.openBox<app_user.User>('users');
    await box.put(user.id, user);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}