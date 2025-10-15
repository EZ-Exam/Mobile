import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.6:5000/Login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        Fluttertoast.showToast(msg: data["message"]);
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Login failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        Fluttertoast.showToast(msg: "Google Sign-In: ${googleUser.email}");

        final response = await http.post(
          Uri.parse("http://192.168.1.6:5000/api/login/google"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "gmail": googleUser.email,
            "name": googleUser.displayName,
            "avatar": googleUser.photoUrl,
          }),
        );

        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);
          Navigator.pushReplacementNamed(context, "/home");
        } else {
          Fluttertoast.showToast(msg: data["message"] ?? "Google login failed");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Google login error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/phygen-icon.png', width: 120),
              const SizedBox(height: 16),
              const Text('Welcome Back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Sign in to your PhyGen account'),

              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign In"),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: Image.asset('assets/icons/google-icon.png', width: 20),
                label: const Text('Continue with Google'),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.grey),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Sign up here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}