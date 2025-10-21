import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Test API endpoint first
      print('🔍 Testing API endpoint...');
      final isApiWorking = await _apiService.testApiEndpoint();
      print('🔍 API Test Result: $isApiWorking');
      
      if (!isApiWorking) {
        _showSnackBar('Không thể kết nối đến server. Vui lòng kiểm tra lại URL.', isError: true);
        return;
      }

      final response = await _apiService.register({
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });

      // Check if registration was successful
      if (response['message'] != null) {
        _showSnackBar(response['message']);
        
        // Navigate to signin page after successful registration
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      } else {
        _showSnackBar('Đăng ký thành công!');
        
        // Navigate to signin page
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      }
    } catch (e) {
      _showSnackBar('Đăng ký thất bại: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testApi() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔍 Testing API endpoint...');
      final isApiWorking = await _apiService.testApiEndpoint();
      print('🔍 API Test Result: $isApiWorking');
      
      if (isApiWorking) {
        _showSnackBar('✅ API connection successful!');
      } else {
        _showSnackBar('❌ API connection failed. Check console for details.', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ API test error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: isDesktop ? 40 : 30),
                  
                  // Logo Section
                  _buildLogoSection(isDesktop),
                  
                  SizedBox(height: isDesktop ? 40 : 30),
                  
                  // Sign Up Form
                  _buildSignUpForm(isDesktop),
                  
                  SizedBox(height: isDesktop ? 30 : 20),
                  
                  // Login Link
                  _buildLoginLink(isDesktop),
                ],
              ),
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
          width: isDesktop ? 100 : 80,
          height: isDesktop ? 100 : 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            size: 50,
            color: Color(0xFF667eea),
          ),
        ),
        
        SizedBox(height: isDesktop ? 20 : 16),
        
        // App Name
        Text(
          'Đăng ký tài khoản',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        
        SizedBox(height: isDesktop ? 6 : 4),
        
        // Subtitle
        Text(
          'Tạo tài khoản EZEXAM của bạn',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(bool isDesktop) {
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
            'Thông tin đăng ký',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          SizedBox(height: isDesktop ? 8 : 6),
          
          Text(
            'Điền thông tin để tạo tài khoản mới',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: isDesktop ? 24 : 20),
          
          // Full Name Field
          _buildInputField(
            controller: _fullNameController,
            label: 'Họ và tên',
            hint: 'Nhập họ và tên của bạn',
            icon: Icons.person_outlined,
            isDesktop: isDesktop,
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Email Field
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            hint: 'Nhập email của bạn',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDesktop: isDesktop,
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Password Field
          _buildInputField(
            controller: _passwordController,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            icon: Icons.lock_outlined,
            isPassword: true,
            isDesktop: isDesktop,
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Confirm Password Field
          _buildInputField(
            controller: _confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            hint: 'Nhập lại mật khẩu',
            icon: Icons.lock_outlined,
            isPassword: true,
            isConfirmPassword: true,
            isDesktop: isDesktop,
          ),
          
          SizedBox(height: isDesktop ? 24 : 20),
          
          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
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
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Test API Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _testApi,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
                side: const BorderSide(color: Color(0xFF667eea)),
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
                ),
              ),
              child: Text(
                'Test API Connection',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.bold,
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
    bool isConfirmPassword = false,
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
        
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !(isConfirmPassword ? _showConfirmPassword : _showPassword),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập $label';
            }
            
            if (label == 'Email') {
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
            }
            
            if (label == 'Mật khẩu') {
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
            }
            
            if (label == 'Xác nhận mật khẩu') {
              if (value != _passwordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
            }
            
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (isConfirmPassword ? _showConfirmPassword : _showPassword) 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        if (isConfirmPassword) {
                          _showConfirmPassword = !_showConfirmPassword;
                        } else {
                          _showPassword = !_showPassword;
                        }
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
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

  Widget _buildLoginLink(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signin');
          },
          child: Text(
            'Đăng nhập ngay',
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
