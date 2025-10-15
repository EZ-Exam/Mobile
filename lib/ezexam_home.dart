import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';

class EZEXAMHomePage extends StatefulWidget {
  const EZEXAMHomePage({super.key});

  @override
  State<EZEXAMHomePage> createState() => _EZEXAMHomePageState();
}

class _EZEXAMHomePageState extends State<EZEXAMHomePage> {
  bool _isAuthenticated = false;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _isAuthenticated = token != null;
      _userToken = token;
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  child: Column(
                    children: [
                      // Logo Section
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
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      
                      // Title
                      Text(
                        'EZEXAM',
                        style: TextStyle(
                          fontSize: isDesktop ? 48 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),
                      
                      // Subtitle
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 20 : 16,
                          vertical: isDesktop ? 12 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            SizedBox(width: isDesktop ? 12 : 8),
                            Text(
                              'AI-Powered Learning Platform',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isDesktop ? 32 : 24),
                      
                      // Main Title
                      Text(
                        'Master Your\nUniversity Entrance\nExams',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 42 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      
                      // Description
                      Text(
                        'AI-powered exam preparation platform for Math, Physics, and Chemistry. Learn with interactive lessons, practice with smart exercises, and track your progress.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 32 : 24),
                      
                      // Action Buttons
                      if (!_isAuthenticated) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showLoginDialog(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF3B82F6),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isDesktop ? 16 : 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                                  ),
                                ),
                                child: Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isDesktop ? 16 : 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showRegisterDialog(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isDesktop ? 16 : 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                                  ),
                                ),
                                child: Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to dashboard
                            Navigator.pushNamed(context, '/dashboard');
                          },
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Vào Dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF3B82F6),
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 32 : 24,
                              vertical: isDesktop ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Features Section
            Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              child: Column(
                children: [
                  Text(
                    'Why Choose EZEXAM?',
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 24 : 16),
                  
                  // Features Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 4 : 2,
                    crossAxisSpacing: isDesktop ? 16 : 12,
                    mainAxisSpacing: isDesktop ? 16 : 12,
                    childAspectRatio: isDesktop ? 1.2 : 1.1,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.psychology,
                        title: 'AI-Powered Learning',
                        description: 'Smart algorithms adapt to your learning pace',
                        color: const Color(0xFF3B82F6),
                        isDesktop: isDesktop,
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics,
                        title: 'Practice Mock Testing',
                        description: 'Real exam simulation with detailed analytics',
                        color: const Color(0xFF10B981),
                        isDesktop: isDesktop,
                      ),
                      _buildFeatureCard(
                        icon: Icons.menu_book,
                        title: 'Interactive Lessons',
                        description: 'High-quality content with expert explanations',
                        color: const Color(0xFF8B5CF6),
                        isDesktop: isDesktop,
                      ),
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'Community Support',
                        description: 'Connect with fellow students and experts',
                        color: const Color(0xFFF59E0B),
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 24),
                  
                  // Stats Section
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 24 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Our Impact',
                          style: TextStyle(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 20 : 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('1000+', 'Practice Questions', isDesktop),
                            _buildStatItem('50+', 'Video Lessons', isDesktop),
                            _buildStatItem('95%', 'Success Rate', isDesktop),
                            _buildStatItem('24/7', 'AI Support', isDesktop),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 60 : 50,
            height: isDesktop ? 60 : 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 30 : 24,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            description,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 10,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, bool isDesktop) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B82F6),
          ),
        ),
        SizedBox(height: isDesktop ? 4 : 2),
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 12 : 10,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showLoginDialog() {
    Navigator.pushNamed(context, '/login');
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) => RegisterDialog(),
    );
  }
}

class RegisterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng ký'),
      content: const Text('Tính năng đăng ký sẽ có sớm!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
