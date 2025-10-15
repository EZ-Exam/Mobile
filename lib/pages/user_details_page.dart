import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _UserDetailsPageState extends State<UserDetailsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_error',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_userDetails == null) {
      return const Center(
        child: Text(
          'Không tìm thấy thông tin người dùng',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          _buildProfileCard(),
          
          const SizedBox(height: 20),
          
          // User Information
          _buildUserInfo(),
          
          const SizedBox(height: 20),
          
          // Statistics
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = _userDetails!;
    final avatarUrl = user['avatarUrl'] ?? user['profilePicture'];
    final fullName = user['fullName'] ?? user['name'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';
    final role = user['role'] ?? 'Student';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF667eea),
              backgroundImage: avatarUrl != null 
                  ? NetworkImage(avatarUrl) 
                  : null,
              child: avatarUrl == null
                  ? Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: 16),
            
            // Name
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _userDetails!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('ID', user['id']?.toString() ?? 'N/A'),
            _buildInfoRow('Tên đầy đủ', user['fullName'] ?? user['name'] ?? 'N/A'),
            _buildInfoRow('Email', user['email'] ?? 'N/A'),
            _buildInfoRow('Số điện thoại', user['phoneNumber'] ?? user['phone'] ?? 'N/A'),
            _buildInfoRow('Ngày sinh', user['dateOfBirth'] ?? 'N/A'),
            _buildInfoRow('Giới tính', user['gender'] ?? 'N/A'),
            _buildInfoRow('Địa chỉ', user['address'] ?? 'N/A'),
            _buildInfoRow('Trạng thái', user['isActive'] == true ? 'Hoạt động' : 'Không hoạt động'),
            _buildInfoRow('Ngày tạo', user['createdAt'] ?? 'N/A'),
            _buildInfoRow('Cập nhật lần cuối', user['updatedAt'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final user = _userDetails!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê học tập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Bài học đã học',
                    user['lessonsCompleted']?.toString() ?? '0',
                    Icons.book,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Điểm trung bình',
                    user['averageScore']?.toString() ?? '0',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Bài kiểm tra',
                    user['testsCompleted']?.toString() ?? '0',
                    Icons.quiz,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Thời gian học',
                    user['studyTime']?.toString() ?? '0h',
                    Icons.timer,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
