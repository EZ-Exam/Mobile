import 'package:flutter/material.dart';
import 'services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentLessons = [];
  List<Map<String, dynamic>> _recentTests = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _apiService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });

    if (isAuth) {
      _loadDashboardData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API calls
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _stats = {
          'totalLessons': 45,
          'completedLessons': 23,
          'totalTests': 12,
          'completedTests': 8,
          'totalQuestions': 156,
          'correctAnswers': 134,
          'streak': 7,
          'points': 2450,
        };
        
        _recentLessons = [
          {
            'id': '1',
            'title': 'Đại số tuyến tính cơ bản',
            'subject': 'Toán học',
            'progress': 0.75,
            'duration': '45 phút',
          },
          {
            'id': '2',
            'title': 'Cơ học Newton',
            'subject': 'Vật lý',
            'progress': 0.60,
            'duration': '30 phút',
          },
          {
            'id': '3',
            'title': 'Hóa học hữu cơ',
            'subject': 'Hóa học',
            'progress': 0.90,
            'duration': '60 phút',
          },
        ];
        
        _recentTests = [
          {
            'id': '1',
            'name': 'Kiểm tra Toán học tuần 1',
            'score': 85,
            'totalQuestions': 20,
            'completedAt': '2024-01-15',
          },
          {
            'id': '2',
            'name': 'Mock test Vật lý',
            'score': 92,
            'totalQuestions': 25,
            'completedAt': '2024-01-14',
          },
        ];
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            )
          : !_isAuthenticated
              ? _buildLoginPrompt(isDesktop)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isDesktop ? 32 : 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chào mừng trở lại!',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: isDesktop ? 8 : 4),
                            Text(
                              'Tiếp tục hành trình học tập của bạn',
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: isDesktop ? 16 : 12),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 16 : 12,
                                    vertical: isDesktop ? 8 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                                      SizedBox(width: isDesktop ? 8 : 4),
                                      Text(
                                        '${_stats['streak']} ngày liên tiếp',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 14 : 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: isDesktop ? 16 : 12),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 16 : 12,
                                    vertical: isDesktop ? 8 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.stars, color: Colors.white, size: 20),
                                      SizedBox(width: isDesktop ? 8 : 4),
                                      Text(
                                        '${_stats['points']} điểm',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 14 : 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isDesktop ? 24 : 20),
                      
                      // Stats Grid
                      Text(
                        'Thống kê học tập',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),
                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isDesktop ? 4 : 2,
                        crossAxisSpacing: isDesktop ? 16 : 12,
                        mainAxisSpacing: isDesktop ? 16 : 12,
                        childAspectRatio: isDesktop ? 1.2 : 1.1,
                        children: [
                          _buildStatCard(
                            'Bài học',
                            '${_stats['completedLessons']}/${_stats['totalLessons']}',
                            Icons.menu_book,
                            const Color(0xFF3B82F6),
                            isDesktop,
                          ),
                          _buildStatCard(
                            'Bài thi',
                            '${_stats['completedTests']}/${_stats['totalTests']}',
                            Icons.quiz,
                            const Color(0xFF10B981),
                            isDesktop,
                          ),
                          _buildStatCard(
                            'Câu hỏi',
                            '${_stats['correctAnswers']}/${_stats['totalQuestions']}',
                            Icons.psychology,
                            const Color(0xFF8B5CF6),
                            isDesktop,
                          ),
                          _buildStatCard(
                            'Điểm số',
                            '${_stats['points']}',
                            Icons.stars,
                            const Color(0xFFF59E0B),
                            isDesktop,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isDesktop ? 24 : 20),
                      
                      // Recent Lessons
                      Text(
                        'Bài học gần đây',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),
                      
                      ..._recentLessons.map((lesson) => _buildLessonCard(lesson, isDesktop)),
                      
                      SizedBox(height: isDesktop ? 24 : 20),
                      
                      // Recent Tests
                      Text(
                        'Bài thi gần đây',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),
                      
                      ..._recentTests.map((test) => _buildTestCard(test, isDesktop)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoginPrompt(bool isDesktop) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isDesktop ? 32 : 24),
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isDesktop ? 80 : 60,
              height: isDesktop ? 80 : 60,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
              ),
              child: Icon(
                Icons.lock_outline,
                size: isDesktop ? 40 : 30,
                color: const Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 20),
            Text(
              'Cần đăng nhập',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              'Để xem dashboard và thống kê học tập, bạn cần đăng nhập vào tài khoản.',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 32 : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                ),
                child: Text(
                  'Đăng nhập ngay',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                ),
                child: Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDesktop) {
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
            width: isDesktop ? 50 : 40,
            height: isDesktop ? 50 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 24 : 20,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isDesktop ? 4 : 2),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 10,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
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
      child: Row(
        children: [
          Container(
            width: isDesktop ? 60 : 50,
            height: isDesktop ? 60 : 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: const Icon(
              Icons.menu_book,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'],
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: isDesktop ? 4 : 2),
                Text(
                  lesson['subject'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 6),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: lesson['progress'],
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Text(
                      '${(lesson['progress'] * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
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
      child: Row(
        children: [
          Container(
            width: isDesktop ? 60 : 50,
            height: isDesktop ? 60 : 50,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: const Icon(
              Icons.quiz,
              color: Color(0xFF10B981),
              size: 24,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['name'],
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: isDesktop ? 4 : 2),
                Text(
                  '${test['correctAnswers']}/${test['totalQuestions']} câu đúng',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 6),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 12 : 8,
                        vertical: isDesktop ? 4 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(test['score']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                      ),
                      child: Text(
                        '${test['score']}%',
                        style: TextStyle(
                          fontSize: isDesktop ? 12 : 10,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(test['score']),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      test['completedAt'],
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
