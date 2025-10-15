import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/lesson_details_page.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _lessons = [];
  String _searchQuery = '';
  String _selectedSubject = 'all';
  String _sortBy = 'title';
  String _sortOrder = 'asc';

  final List<Map<String, String>> _subjects = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': '1', 'name': 'Toán học'},
    {'id': '2', 'name': 'Vật lý'},
    {'id': '3', 'name': 'Hóa học'},
    {'id': '4', 'name': 'Sinh học'},
    {'id': '5', 'name': 'Ngữ văn'},
    {'id': '6', 'name': 'Tiếng Anh'},
    {'id': '7', 'name': 'Lịch sử'},
    {'id': '8', 'name': 'Địa lý'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _lessons = [
          {
            'id': '1',
            'title': 'Đại số tuyến tính cơ bản',
            'description': 'Học về ma trận, định thức và hệ phương trình tuyến tính',
            'subjectId': '1',
            'subjectName': 'Toán học',
            'duration': '45 phút',
            'difficulty': 'Medium',
            'progress': 0.75,
            'pdfUrl': 'https://example.com/lesson1.pdf',
          },
          {
            'id': '2',
            'title': 'Cơ học Newton',
            'description': 'Các định luật Newton và ứng dụng trong thực tế',
            'subjectId': '2',
            'subjectName': 'Vật lý',
            'duration': '30 phút',
            'difficulty': 'Easy',
            'progress': 0.60,
            'pdfUrl': 'https://example.com/lesson2.pdf',
          },
          {
            'id': '3',
            'title': 'Hóa học hữu cơ',
            'description': 'Các hợp chất hữu cơ cơ bản và phản ứng',
            'subjectId': '3',
            'subjectName': 'Hóa học',
            'duration': '60 phút',
            'difficulty': 'Hard',
            'progress': 0.90,
            'pdfUrl': 'https://example.com/lesson3.pdf',
          },
          {
            'id': '4',
            'title': 'Sinh học tế bào',
            'description': 'Cấu trúc và chức năng của tế bào',
            'subjectId': '4',
            'subjectName': 'Sinh học',
            'duration': '40 phút',
            'difficulty': 'Medium',
            'progress': 0.30,
            'pdfUrl': 'https://example.com/lesson4.pdf',
          },
          {
            'id': '5',
            'title': 'Văn học hiện đại',
            'description': 'Các tác phẩm văn học Việt Nam thế kỷ XX',
            'subjectId': '5',
            'subjectName': 'Ngữ văn',
            'duration': '50 phút',
            'difficulty': 'Medium',
            'progress': 0.45,
            'pdfUrl': 'https://example.com/lesson5.pdf',
          },
          {
            'id': '6',
            'title': 'Grammar Advanced',
            'description': 'Advanced English grammar and usage',
            'subjectId': '6',
            'subjectName': 'Tiếng Anh',
            'duration': '35 phút',
            'difficulty': 'Hard',
            'progress': 0.20,
            'pdfUrl': 'https://example.com/lesson6.pdf',
          },
        ];
      });
    } catch (e) {
      print('Error loading lessons: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredLessons {
    return _lessons.where((lesson) {
      final matchesSearch = _searchQuery.isEmpty ||
          lesson['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lesson['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSubject = _selectedSubject == 'all' ||
          lesson['subjectId'] == _selectedSubject;
      
      return matchesSearch && matchesSubject;
    }).toList();
  }

  Color _getSubjectColor(String subjectId) {
    switch (subjectId) {
      case '1': return const Color(0xFF3B82F6); // Toán học
      case '2': return const Color(0xFF8B5CF6); // Vật lý
      case '3': return const Color(0xFF10B981); // Hóa học
      case '4': return const Color(0xFF059669); // Sinh học
      case '5': return const Color(0xFFF59E0B); // Ngữ văn
      case '6': return const Color(0xFFEC4899); // Tiếng Anh
      case '7': return const Color(0xFFEF4444); // Lịch sử
      case '8': return const Color(0xFF14B8A6); // Địa lý
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy': return const Color(0xFF10B981);
      case 'Medium': return const Color(0xFFF59E0B);
      case 'Hard': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
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
                                Icons.menu_book,
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
                                    'Lessons',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 28 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Khám phá các bài học thú vị',
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
                  
                  // Search Bar
                  Container(
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
                          'Tìm kiếm bài học',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm theo tên hoặc mô tả...',
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 24 : 20),
                  
                  // Subject Filter
                  Container(
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
                          'Lọc theo môn học',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        Wrap(
                          spacing: isDesktop ? 12 : 8,
                          runSpacing: isDesktop ? 12 : 8,
                          children: _subjects.map((subject) {
                            final isSelected = _selectedSubject == subject['id'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSubject = subject['id']!;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 16 : 12,
                                  vertical: isDesktop ? 8 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF3B82F6) 
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF3B82F6) 
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  subject['name']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: isDesktop ? 14 : 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 24 : 20),
                  
                  // Lessons Grid
                  Text(
                    'Danh sách bài học (${_filteredLessons.length})',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),
                  
                  if (_filteredLessons.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isDesktop ? 40 : 32),
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
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: isDesktop ? 64 : 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            'Không tìm thấy bài học nào',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 8 : 4),
                          Text(
                            'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: isDesktop ? 16 : 12,
                        mainAxisSpacing: isDesktop ? 16 : 12,
                        childAspectRatio: isDesktop ? 0.8 : 0.9,
                      ),
                      itemCount: _filteredLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _filteredLessons[index];
                        return _buildLessonCard(lesson, isDesktop);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonDetailsPage(
              lessonId: lesson['id']?.toString() ?? '1',
            ),
          ),
        );
      },
      child: Container(
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
          // Header with subject badge
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            decoration: BoxDecoration(
              color: _getSubjectColor(lesson['subjectId']).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 16 : 12),
                topRight: Radius.circular(isDesktop ? 16 : 12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 8 : 6),
                  decoration: BoxDecoration(
                    color: _getSubjectColor(lesson['subjectId']),
                    borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: isDesktop ? 20 : 16,
                  ),
                ),
                SizedBox(width: isDesktop ? 12 : 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['subjectName'],
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: _getSubjectColor(lesson['subjectId']),
                        ),
                      ),
                      Text(
                        lesson['duration'],
                        style: TextStyle(
                          fontSize: isDesktop ? 12 : 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 8 : 6,
                    vertical: isDesktop ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(lesson['difficulty']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                  ),
                  child: Text(
                    lesson['difficulty'],
                    style: TextStyle(
                      fontSize: isDesktop ? 10 : 8,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(lesson['difficulty']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 16 : 12),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isDesktop ? 8 : 6),
                  Text(
                    lesson['description'],
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ',
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 10,
                              color: Colors.grey[600],
                            ),
                          ),
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
                      SizedBox(height: isDesktop ? 8 : 6),
                      LinearProgressIndicator(
                        value: lesson['progress'],
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Action button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to lesson detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mở bài học: ${lesson['title']}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 20),
                  SizedBox(width: isDesktop ? 8 : 4),
                  Text(
                    'Bắt đầu học',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
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
}
