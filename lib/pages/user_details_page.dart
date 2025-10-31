import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;
  
  const UserDetailsPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _error;
  bool _isAuthenticated = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    
    _checkAuthentication();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _apiService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });

    if (isAuth) {
      _loadUserDetails();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.getUserDetails(widget.userId);
      
      if (mounted) {
        setState(() {
          _userDetails = response;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar(isDesktop),
              
              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isDesktop ? 32 : 24),
                      topRight: Radius.circular(isDesktop ? 32 : 24),
                    ),
                  ),
                  child: _buildBody(isDesktop),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: isDesktop ? 24 : 20,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Text(
              'Chi tiết người dùng',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: IconButton(
              onPressed: _loadUserDetails,
              icon: const Icon(Icons.refresh, color: Colors.white),
              iconSize: isDesktop ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              strokeWidth: isDesktop ? 4 : 3,
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            Text(
              'Đang tải thông tin...',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (!_isAuthenticated) {
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
                'Để xem thông tin chi tiết người dùng, bạn cần đăng nhập vào tài khoản.',
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

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isDesktop ? 120 : 80,
                height: isDesktop ? 120 : 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 60 : 40),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: isDesktop ? 60 : 40,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 32 : 24),
              ElevatedButton.icon(
                onPressed: _loadUserDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 24,
                    vertical: isDesktop ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_userDetails == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isDesktop ? 120 : 80,
                height: isDesktop ? 120 : 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 60 : 40),
                ),
                child: Icon(
                  Icons.person_off,
                  size: isDesktop ? 60 : 40,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Text(
                'Không tìm thấy thông tin',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                'Không tìm thấy thông tin người dùng',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              _buildProfileCard(isDesktop),
              
              SizedBox(height: isDesktop ? 24 : 20),
              
              // User Information
              _buildUserInfo(isDesktop),
              
              SizedBox(height: isDesktop ? 24 : 20),
              
              // Statistics
              _buildStatistics(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDesktop) {
    final user = _userDetails!;
    final avatarUrl = user['avatarUrl'] ?? user['profilePicture'];
    final fullName = user['fullName'] ?? user['name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';
    final role = user['role'] ?? 'Student';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        child: Column(
          children: [
            // Avatar with animated border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isDesktop ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isDesktop ? 60 : 50,
                backgroundColor: Colors.white,
                backgroundImage: avatarUrl != null 
                    ? NetworkImage(avatarUrl) 
                    : null,
                child: avatarUrl == null
                    ? Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: isDesktop ? 36 : 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF667eea),
                        ),
                      )
                    : null,
              ),
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            // Name
            Text(
              fullName,
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: isDesktop ? 8 : 6),
            
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            SizedBox(height: isDesktop ? 16 : 12),
            
            // Role Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: isDesktop ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isDesktop) {
    final user = _userDetails!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF667eea),
                    size: isDesktop ? 24 : 20,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            _buildInfoRow('ID', user['id']?.toString() ?? 'N/A', isDesktop),
            _buildInfoRow('Tên đầy đủ', user['fullName'] ?? user['name'] ?? 'N/A', isDesktop),
            _buildInfoRow('Email', user['email'] ?? 'N/A', isDesktop),
            _buildInfoRow('Số điện thoại', user['phoneNumber'] ?? user['phone'] ?? 'N/A', isDesktop),
            _buildInfoRow('Ngày sinh', user['dateOfBirth'] ?? 'N/A', isDesktop),
            _buildInfoRow('Giới tính', user['gender'] ?? 'N/A', isDesktop),
            _buildInfoRow('Địa chỉ', user['address'] ?? 'N/A', isDesktop),
            _buildInfoRow('Trạng thái', user['isActive'] == true ? 'Hoạt động' : 'Không hoạt động', isDesktop),
            _buildInfoRow('Ngày tạo', user['createdAt'] ?? 'N/A', isDesktop),
            _buildInfoRow('Cập nhật lần cuối', user['updatedAt'] ?? 'N/A', isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isDesktop ? 140 : 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A5568),
                fontSize: isDesktop ? 14 : 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF1F2937),
                fontSize: isDesktop ? 14 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isDesktop) {
    final user = _userDetails!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: const Color(0xFF667eea),
                    size: isDesktop ? 24 : 20,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Text(
                  'Thống kê học tập',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Bài học đã học',
                    user['lessonsCompleted']?.toString() ?? '0',
                    Icons.book,
                    Colors.blue,
                    isDesktop,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  child: _buildStatCard(
                    'Điểm trung bình',
                    user['averageScore']?.toString() ?? '0',
                    Icons.star,
                    Colors.orange,
                    isDesktop,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isDesktop ? 16 : 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Bài kiểm tra',
                    user['testsCompleted']?.toString() ?? '0',
                    Icons.quiz,
                    Colors.green,
                    isDesktop,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  child: _buildStatCard(
                    'Thời gian học',
                    user['studyTime']?.toString() ?? '0h',
                    Icons.timer,
                    Colors.purple,
                    isDesktop,
                  ),
                ),
              ],
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 28 : 24,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isDesktop ? 6 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
