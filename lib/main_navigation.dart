
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ezexam_home.dart';
import 'dashboard.dart';
import 'lessons_page.dart';
import 'mock_tests_page.dart';
import 'question_bank_page.dart';
import 'profile_page.dart';
import 'providers/user_provider.dart';
import 'widgets/support_chat.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EZEXAMHomePage(),
    const DashboardPage(),
    const LessonsPage(),
    const MockTestsPage(),
    const QuestionBankPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    Provider.of<UserProvider>(context, listen: false).fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    const navBarHeight = 64.0;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: navBarHeight + bottomInset),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            Positioned(
              right: 16,
              bottom: navBarHeight + bottomInset + 16,
              child: SupportChat(user: user),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.dashboard, 'Dashboard'),
                _buildNavItem(2, Icons.menu_book, 'Lessons'),
                _buildNavItem(3, Icons.quiz, 'Tests'),
                _buildNavItem(4, Icons.psychology, 'Questions'),
                _buildNavItem(5, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

