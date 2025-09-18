import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/app/service/hive_service.dart';
import 'package:mocklet_source/app_logger.dart';

import '../service/pref_service.dart';

class CoreResponse {
  final bool success;
  final String message;

  CoreResponse({required this.success, required this.message});
}

class Core {
  final _auth = FirebaseAuth.instance;

  Future<CoreResponse> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      AppLogger.info('User logged in successfully');
      return CoreResponse(success: true, message: 'Login successful');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return CoreResponse(
          success: false,
          message: 'No user found for that email.',
        );
      } else if (e.code == 'invalid-email') {
        return CoreResponse(success: false, message: 'Invalid email format.');
      } else if (e.code == 'wrong-password') {
        return CoreResponse(
          success: false,
          message: 'Wrong password provided for that user.',
        );
      } else {
        return CoreResponse(
          success: false,
          message: 'Login failed: ${e.message}',
        );
      }
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Login error');
      return CoreResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<CoreResponse> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.info('User signed up successfully');
      return CoreResponse(success: true, message: 'Sign up successful');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return CoreResponse(
          success: false,
          message: 'The email address is already in use by another account.',
        );
      } else if (e.code == 'invalid-email') {
        return CoreResponse(success: false, message: 'Invalid email format.');
      } else if (e.code == 'weak-password') {
        return CoreResponse(
          success: false,
          message: 'The password is too weak.',
        );
      } else {
        return CoreResponse(
          success: false,
          message: 'Sign up failed: ${e.message}',
        );
      }
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Sign up error');
      return CoreResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<CoreResponse> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent successfully');
      return CoreResponse(success: true, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return CoreResponse(
          success: false,
          message: 'No user found for that email.',
        );
      } else if (e.code == 'invalid-email') {
        return CoreResponse(success: false, message: 'Invalid email format.');
      } else {
        return CoreResponse(
          success: false,
          message: 'Failed to send password reset email: ${e.message}',
        );
      }
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Forgot password error');
      return CoreResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Logout error');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await HiveService.deleteUserData(user.uid);
        await user.delete();
        AppLogger.info('User account deleted successfully');
      } else {
        AppLogger.warning('No user is currently logged in', 'Delete account');
      }
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Delete account error');
    }
  }

  String getRoute() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return '/main';
      } else {
        if (PrefService.isFirstRun) {
          return '/welcome';
        } else {
          return '/login';
        }
      }
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Error determining route');
      return '/login';
    }
  }
}

final coreProvider = Provider<Core>((ref) => Core());
