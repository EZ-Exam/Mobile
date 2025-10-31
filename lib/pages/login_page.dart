import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/google_signin_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  
  bool _showPassword = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response['token'] != null) {
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        
        // Fetch and store userId for later payment-related calls
        try {
          final profile = await _apiService.getUserProfile();
          final dynamic id = profile['id'];
          if (id != null) {
            await prefs.setString('userId', id.toString());
          }
        } catch (_) {}
        
        _showSnackBar(response['message'] ?? 'Đăng nhập thành công!');
        
        // Navigate to main app
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      String errorMessage = 'Đăng nhập thất bại';
      
      // Handle specific error cases
      if (e.toString().contains('401')) {
        errorMessage = 'Email hoặc mật khẩu không đúng';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Tài khoản bị khóa';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Tài khoản không tồn tại';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Lỗi máy chủ, vui lòng thử lại sau';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Kết nối quá chậm, vui lòng thử lại';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Không có kết nối internet';
      } else {
        errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
      }
      
      _showSnackBar(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _isGoogleLoading = true);

    try {
      final response = await _googleSignInService.signInWithGoogle();
      
      if (response['success'] && response['data']['token'] != null) {
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['data']['token']);
        
        // Fetch and store userId for later payment-related calls
        try {
          final profile = await _apiService.getUserProfile();
          final dynamic id = profile['id'];
          if (id != null) {
            await prefs.setString('userId', id.toString());
          }
        } catch (_) {}
        
        _showSnackBar('Đăng nhập Google thành công!');
        
        // Navigate to main app
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      _showSnackBar('Đăng nhập Google thất bại: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    SizedBox(height: isDesktop ? 60 : 40),
                    
                    // Logo Section
                    _buildLogoSection(isDesktop),
                    
                    SizedBox(height: isDesktop ? 60 : 40),
                    
                    // Login Form
                    _buildLoginForm(isDesktop),
                    
                    SizedBox(height: isDesktop ? 40 : 30),
                    
                    // Google Sign In
                    _buildGoogleSignIn(isDesktop),
                    
                    SizedBox(height: isDesktop ? 30 : 20),
                    
                    // Register Link
                    _buildRegisterLink(isDesktop),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isDesktop) {
    return Column(
      children: [
        // Animated Logo
        Container(
          width: isDesktop ? 120 : 100,
          height: isDesktop ? 120 : 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isDesktop ? 30 : 25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 60,
            color: Color(0xFF667eea),
          ),
        ),
        
        SizedBox(height: isDesktop ? 24 : 20),
        
        // App Name
        Text(
          'EZEXAM',
          style: TextStyle(
            fontSize: isDesktop ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        
        SizedBox(height: isDesktop ? 8 : 6),
        
        // Subtitle
        Text(
          'AI-Powered Learning Platform',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          SizedBox(height: isDesktop ? 8 : 6),
          
          Text(
            'Chào mừng trở lại! Vui lòng đăng nhập để tiếp tục.',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: isDesktop ? 32 : 24),
          
          // Email Field
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            hint: 'Nhập email của bạn',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDesktop: isDesktop,
          ),
          
          SizedBox(height: isDesktop ? 20 : 16),
          
          // Password Field
          _buildInputField(
            controller: _passwordController,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            icon: Icons.lock_outlined,
            isPassword: true,
            isDesktop: isDesktop,
          ),
          
          SizedBox(height: isDesktop ? 24 : 20),
          
          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: isDesktop ? 20 : 16,
                      width: isDesktop ? 20 : 16,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Forgot Password
          Center(
            child: TextButton(
              onPressed: () {
                _showSnackBar('Tính năng quên mật khẩu sẽ có sớm!');
              },
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: const Color(0xFF667eea),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        
        SizedBox(height: isDesktop ? 8 : 6),
        
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !_showPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 12,
              vertical: isDesktop ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInNotice(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: isDesktop ? 20 : 16,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Google Sign-in tạm thời không khả dụng',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: isDesktop ? 4 : 2),
                Text(
                  'Vui lòng sử dụng email/password để đăng nhập',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignIn(bool isDesktop) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isGoogleLoading ? null : _googleLogin,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          backgroundColor: Colors.white.withOpacity(0.1),
        ),
        icon: _isGoogleLoading
            ? SizedBox(
                height: isDesktop ? 20 : 16,
                width: isDesktop ? 20 : 16,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Container(
                width: isDesktop ? 24 : 20,
                height: isDesktop ? 24 : 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.login,
                  color: Color(0xFF4285F4),
                  size: 16,
                ),
              ),
        label: Text(
          _isGoogleLoading ? 'Đang đăng nhập...' : 'Tiếp tục với Google',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            'Đăng ký ngay',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}