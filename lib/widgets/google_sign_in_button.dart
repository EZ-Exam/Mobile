import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'web_google_sign_in_button.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const GoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? null : null, // Disable clientId for web to avoid People API
    scopes: ['email', 'profile'],
  );

  @override
  Widget build(BuildContext context) {
    // Use different implementations for web and mobile
    if (kIsWeb) {
      return WebGoogleSignInButton(
        onSuccess: widget.onSuccess,
        onError: widget.onError,
      );
    }

    // Mobile version
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _handleMobileGoogleSignIn,
        icon: Image.asset(
          'assets/icons/google-icon.png',
          width: 20,
          height: 20,
        ),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMobileGoogleSignIn() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account != null) {
        await _processGoogleSignIn(account);
      }
    } catch (e) {
      _handleGoogleSignInError(e);
    }
  }

  void _handleGoogleSignInError(dynamic error) {
    String errorMessage = "Google Sign-In failed";
    
    if (error.toString().contains('People API')) {
      errorMessage = "Google Sign-In configuration error. Please contact support.";
    } else if (error.toString().contains('403')) {
      errorMessage = "Google Sign-In permission denied. Please try again.";
    } else if (error.toString().contains('network')) {
      errorMessage = "Network error. Please check your connection.";
    } else if (error.toString().contains('popup')) {
      errorMessage = "Sign-in popup was blocked. Please allow popups and try again.";
    }
    
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
    );
    
    if (kDebugMode) {
      print('Google Sign-In Error: $error');
    }
    
    widget.onError?.call();
  }

  Future<void> _processGoogleSignIn(GoogleSignInAccount account) async {
    try {
      Fluttertoast.showToast(msg: "Google Sign-In: ${account.email}");

      final response = await http.post(
        Uri.parse(ApiConfig.legacyGoogleLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "gmail": account.email,
          "name": account.displayName,
          "avatar": account.photoUrl,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        Fluttertoast.showToast(msg: "Login successful!");
        widget.onSuccess?.call();
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Google login failed");
        widget.onError?.call();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error processing Google Sign-In: $e");
      widget.onError?.call();
    }
  }
}
