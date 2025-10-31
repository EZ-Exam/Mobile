import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WebGoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const WebGoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  State<WebGoogleSignInButton> createState() => _WebGoogleSignInButtonState();
}

class _WebGoogleSignInButtonState extends State<WebGoogleSignInButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleWebGoogleSignIn,
        icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.asset(
              'assets/icons/google-icon.png',
              width: 20,
              height: 20,
            ),
        label: Text(
          _isLoading ? 'Signing in...' : 'Sign in with Google',
          style: const TextStyle(
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

  Future<void> _handleWebGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      // For web, we'll use a different approach
      // This is a placeholder - you would need to implement OAuth2 flow
      await _simulateGoogleSignIn();
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _simulateGoogleSignIn() async {
    // This is a simulation - in real implementation, you would:
    // 1. Open Google OAuth2 popup
    // 2. Get authorization code
    // 3. Exchange code for access token
    // 4. Get user info from Google API
    
    // For now, we'll show a message that this needs proper OAuth2 implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Sign-In'),
        content: const Text(
          'Google Sign-In on web requires proper OAuth2 implementation. '
          'For now, please use email/password login or access the app on mobile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleError(dynamic error) {
    Fluttertoast.showToast(
      msg: "Google Sign-In failed: $error",
      toastLength: Toast.LENGTH_LONG,
    );
    widget.onError?.call();
  }
}
