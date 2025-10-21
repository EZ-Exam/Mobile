import 'package:flutter/material.dart';

class AuthStatusWidget extends StatelessWidget {
  final bool isAuthenticated;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onLogoutPressed;
  final String? userName;

  const AuthStatusWidget({
    super.key,
    required this.isAuthenticated,
    this.onLoginPressed,
    this.onLogoutPressed,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    if (!isAuthenticated) {
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
              color: Colors.orange[700],
              size: isDesktop ? 20 : 18,
            ),
            SizedBox(width: isDesktop ? 12 : 8),
            Expanded(
              child: Text(
                'Đăng nhập để tham gia thảo luận và lưu tiến độ',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 8),
            ElevatedButton(
              onPressed: onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: isDesktop ? 8 : 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                ),
              ),
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isDesktop ? 16 : 14,
            backgroundColor: Colors.green[700],
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isDesktop ? 16 : 14,
            ),
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${userName ?? 'Người dùng'}!',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  'Bạn có thể tham gia thảo luận',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          IconButton(
            onPressed: onLogoutPressed,
            icon: Icon(
              Icons.logout,
              color: Colors.green[700],
              size: isDesktop ? 20 : 18,
            ),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
    );
  }
}
