import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'api_service.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: ApiConfig.googleClientId,
    scopes: [
      'email',
      'profile',
    ],
  );

  final ApiService _apiService = ApiService();

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      // Send credential to backend
      final response = await _apiService.googleLogin(googleAuth.accessToken!);
      
      return {
        'success': true,
        'data': response,
        'googleUser': {
          'id': googleUser.id,
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        },
      };
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Google sign-out failed: $e');
    }
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  // Get current user
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      throw Exception('Google disconnect failed: $e');
    }
  }
}
