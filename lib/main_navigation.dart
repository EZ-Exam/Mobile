import 'package:flutter/material.dart';
import 'ezexam_home.dart';
import 'dashboard.dart';
import 'lessons_page.dart';
import 'mock_tests_page.dart';
import 'question_bank_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isAuthenticated = false;

  final List<Widget> _pages = [
    const EZEXAMHomePage(),
    const DashboardPage(),
    const LessonsPage(),
    const MockTestsPage(),
    const QuestionBankPage(),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    'EZEXAM',
    'Dashboard',
    'Lessons',
    'Mock Tests',
    'Question Bank',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
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
        child: SafeArea(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
