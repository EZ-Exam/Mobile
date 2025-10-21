import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'pages/user_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _formData = {};
  Map<String, dynamic> _originalData = {};
  String? _error;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Clear token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng xuất thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login page
        Navigator.pushReplacementNamed(context, '/signin');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Check if user is authenticated first
      final isAuth = await _apiService.isAuthenticated();
      if (!isAuth) {
        setState(() {
          _error = 'Bạn cần đăng nhập để xem profile';
        });
        return;
      }
      
      print('🔍 Loading user profile...');
      final response = await _apiService.getUserProfile();
      print('🔍 Profile Response: $response');
      
      setState(() {
        _userProfile = response;
        _formData = Map.from(_userProfile);
        _originalData = Map.from(_userProfile);
        
        _fullNameController.text = _formData['name'] ?? _formData['fullName'] ?? '';
        _emailController.text = _formData['email'] ?? '';
        _phoneController.text = _formData['phoneNumber'] ?? _formData['phone'] ?? '';
      });
    } catch (e) {
      print('❌ Error loading user profile: $e');
      setState(() {
        _error = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải hồ sơ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔍 Saving profile...');
      final profileData = {
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      };
      
      print('🔍 Profile Data: $profileData');
      final response = await _apiService.updateProfile(profileData);
      print('🔍 Update Response: $response');
      
      setState(() {
        _formData['name'] = _fullNameController.text.trim();
        _formData['email'] = _emailController.text.trim();
        _formData['phoneNumber'] = _phoneController.text.trim();
        
        _userProfile = Map.from(_formData);
        _originalData = Map.from(_formData);
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật hồ sơ thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      _formData = Map.from(_originalData);
      _fullNameController.text = _formData['name'] ?? _formData['fullName'] ?? '';
      _emailController.text = _formData['email'] ?? '';
      _phoneController.text = _formData['phoneNumber'] ?? _formData['phone'] ?? '';
      _isEditing = false;
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _isLoading && _userProfile.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            )
          : _error != null && _userProfile.isEmpty
              ? Center(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _loadUserProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Thử lại'),
                          ),
                          if (_error!.contains('đăng nhập'))
                            ...[
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/signin');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Đăng nhập'),
                              ),
                            ],
                        ],
                      ),
                    ],
                  ),
                )
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
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isDesktop ? 16 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: isDesktop ? 32 : 24,
                              ),
                            ),
                            SizedBox(width: isDesktop ? 16 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profile',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 28 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Quản lý thông tin cá nhân',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 16 : 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isEditing)
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _loadUserProfile,
                                    icon: const Icon(Icons.refresh, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                    ),
                                    tooltip: 'Tải lại',
                                  ),
                                  SizedBox(width: isDesktop ? 8 : 4),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserDetailsPage(
                                            userId: _userProfile['id']?.toString() ?? '1',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.info_outline, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                    ),
                                    tooltip: 'Xem chi tiết',
                                  ),
                                  SizedBox(width: isDesktop ? 8 : 4),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                    ),
                                    tooltip: 'Chỉnh sửa',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 24 : 20),
                  
                  // Profile Info Card
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 20 : 16),
                        
                        // Avatar Section
                        Row(
                          children: [
                            Container(
                              width: isDesktop ? 80 : 60,
                              height: isDesktop ? 80 : 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(isDesktop ? 40 : 30),
                              ),
                              child: Center(
                              child: Text(
                                (_formData['name'] ?? _formData['fullName'] ?? 'U').substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: isDesktop ? 32 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isDesktop ? 20 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formData['name'] ?? _formData['fullName'] ?? 'User',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 20 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 4 : 2),
                                  Text(
                                    'Student',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 8 : 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 12 : 8,
                                      vertical: isDesktop ? 4 : 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                                    ),
                                    child: Text(
                                      _formData['subscriptionName'] ?? 'Free',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 12 : 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: isDesktop ? 24 : 20),
                        
                        // Form Fields
                        Column(
                          children: [
                            _buildFormField(
                              'Họ và tên',
                              _fullNameController,
                              Icons.person,
                              isDesktop,
                            ),
                            SizedBox(height: isDesktop ? 16 : 12),
                            _buildFormField(
                              'Email',
                              _emailController,
                              Icons.email,
                              isDesktop,
                            ),
                            SizedBox(height: isDesktop ? 16 : 12),
                            _buildFormField(
                              'Số điện thoại',
                              _phoneController,
                              Icons.phone,
                              isDesktop,
                            ),
                          ],
                        ),
                        
                        if (_isEditing) ...[
                          SizedBox(height: isDesktop ? 24 : 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _cancelEdit,
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                    ),
                                  ),
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: isDesktop ? 16 : 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                    ),
                                  ),
                                  child: Text(
                                    'Lưu',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 24 : 20),
                  
                  // Account Info Card
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin tài khoản',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 20 : 16),
                        
                        _buildInfoRow(
                          'Thành viên từ',
                          _formatDate(_formData['createdAt'] ?? ''),
                          Icons.calendar_today,
                          isDesktop,
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        _buildInfoRow(
                          'Email',
                          _formData['email'] ?? 'Chưa cập nhật',
                          Icons.email,
                          isDesktop,
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        _buildInfoRow(
                          'Số điện thoại',
                          _formData['phoneNumber'] ?? 'Chưa cập nhật',
                          Icons.phone,
                          isDesktop,
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        _buildInfoRow(
                          'Gói đăng ký',
                          _formData['subscriptionName'] ?? 'Free',
                          Icons.star,
                          isDesktop,
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        _buildInfoRow(
                          'Số dư',
                          '${_formData['balance'] ?? '0'} VNĐ',
                          Icons.account_balance_wallet,
                          isDesktop,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 24 : 20),
                  
                  // Quick Stats Card
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thống kê học tập',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 20 : 16),
                        
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isDesktop ? 4 : 2,
                          crossAxisSpacing: isDesktop ? 16 : 12,
                          mainAxisSpacing: isDesktop ? 16 : 12,
                          childAspectRatio: isDesktop ? 1.2 : 1.1,
                          children: [
                            _buildStatItem('Bài học', '23', Icons.menu_book, const Color(0xFF3B82F6), isDesktop),
                            _buildStatItem('Bài thi', '8', Icons.quiz, const Color(0xFF10B981), isDesktop),
                            _buildStatItem('Câu hỏi', '156', Icons.psychology, const Color(0xFF8B5CF6), isDesktop),
                            _buildStatItem('Điểm số', '2450', Icons.stars, const Color(0xFFF59E0B), isDesktop),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, IconData icon, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: isDesktop ? 8 : 6),
        TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDesktop) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 8 : 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: isDesktop ? 20 : 16,
          ),
        ),
        SizedBox(width: isDesktop ? 12 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: isDesktop ? 24 : 20,
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
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
}
