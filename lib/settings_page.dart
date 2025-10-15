import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  String _selectedLanguage = 'vi';
  double _fontSize = 16.0;

  final List<Map<String, String>> _languages = [
    {'code': 'vi', 'name': 'Tiếng Việt'},
    {'code': 'en', 'name': 'English'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
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
                          Icons.settings,
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
                              'Settings',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Cài đặt ứng dụng',
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                color: Colors.white.withOpacity(0.9),
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
            
            // General Settings
            _buildSettingsSection(
              'Cài đặt chung',
              [
                _buildSwitchTile(
                  'Thông báo',
                  'Nhận thông báo về bài học và bài thi mới',
                  Icons.notifications,
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                  isDesktop,
                ),
                _buildSwitchTile(
                  'Chế độ tối',
                  'Sử dụng giao diện tối',
                  Icons.dark_mode,
                  _darkModeEnabled,
                  (value) => setState(() => _darkModeEnabled = value),
                  isDesktop,
                ),
                _buildSwitchTile(
                  'Tự động lưu',
                  'Tự động lưu tiến độ học tập',
                  Icons.save,
                  _autoSaveEnabled,
                  (value) => setState(() => _autoSaveEnabled = value),
                  isDesktop,
                ),
              ],
              isDesktop,
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            // Language Settings
            _buildSettingsSection(
              'Ngôn ngữ',
              [
                _buildDropdownTile(
                  'Ngôn ngữ',
                  'Chọn ngôn ngữ hiển thị',
                  Icons.language,
                  _selectedLanguage,
                  _languages,
                  (value) => setState(() => _selectedLanguage = value!),
                  isDesktop,
                ),
              ],
              isDesktop,
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            // Display Settings
            _buildSettingsSection(
              'Hiển thị',
              [
                _buildSliderTile(
                  'Kích thước chữ',
                  'Điều chỉnh kích thước chữ',
                  Icons.text_fields,
                  _fontSize,
                  12.0,
                  20.0,
                  (value) => setState(() => _fontSize = value),
                  isDesktop,
                ),
              ],
              isDesktop,
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            // Account Settings
            _buildSettingsSection(
              'Tài khoản',
              [
                _buildActionTile(
                  'Đổi mật khẩu',
                  'Thay đổi mật khẩu tài khoản',
                  Icons.lock,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng đổi mật khẩu sẽ có sớm!')),
                    );
                  },
                  isDesktop,
                ),
                _buildActionTile(
                  'Xóa tài khoản',
                  'Xóa vĩnh viễn tài khoản',
                  Icons.delete_forever,
                  () {
                    _showDeleteAccountDialog(context, isDesktop);
                  },
                  isDesktop,
                ),
              ],
              isDesktop,
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            // App Info
            _buildSettingsSection(
              'Thông tin ứng dụng',
              [
                _buildInfoTile(
                  'Phiên bản',
                  '1.0.0',
                  Icons.info,
                  isDesktop,
                ),
                _buildInfoTile(
                  'Nhà phát triển',
                  'EZEXAM Team',
                  Icons.developer_mode,
                  isDesktop,
                ),
                _buildInfoTile(
                  'Liên hệ',
                  'support@ezexam.com',
                  Icons.contact_mail,
                  isDesktop,
                ),
              ],
              isDesktop,
            ),
            
            SizedBox(height: isDesktop ? 24 : 20),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context, isDesktop);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 20),
                    SizedBox(width: isDesktop ? 8 : 4),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children, bool isDesktop) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      child: Row(
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
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<Map<String, String>> items,
    ValueChanged<String?> onChanged,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      child: Row(
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
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['code'],
                child: Text(item['name']!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      child: Column(
        children: [
          Row(
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
                      title,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.toInt()}px',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 8 : 6),
          child: Row(
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
                      title,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: isDesktop ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      child: Row(
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
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDesktop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đăng xuất!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDesktop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng xóa tài khoản sẽ có sớm!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
