import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MockTestsPage extends StatefulWidget {
  const MockTestsPage({super.key});

  @override
  State<MockTestsPage> createState() => _MockTestsPageState();
}

class _MockTestsPageState extends State<MockTestsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tests = [];
  String _searchQuery = '';
  String _selectedSubject = 'all';
  String _selectedDifficulty = 'all';

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

  final List<Map<String, String>> _difficulties = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': 'Easy', 'name': 'Dễ'},
    {'id': 'Medium', 'name': 'Trung bình'},
    {'id': 'Hard', 'name': 'Khó'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMockTests();
  }

  Future<void> _loadMockTests() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _tests = [
          {
            'id': '1',
            'name': 'Kiểm tra Toán học tuần 1',
            'description': 'Bài kiểm tra tổng hợp kiến thức đại số và hình học',
            'subjectId': '1',
            'subjectName': 'Toán học',
            'difficultyLevel': 'Medium',
            'duration': 90,
            'questionCount': 25,
            'totalQuestions': 25,
            'timeLimit': 90,
          },
          {
            'id': '2',
            'name': 'Mock test Vật lý',
            'description': 'Mô phỏng đề thi đại học môn Vật lý',
            'subjectId': '2',
            'subjectName': 'Vật lý',
            'difficultyLevel': 'Hard',
            'duration': 60,
            'questionCount': 20,
            'totalQuestions': 20,
            'timeLimit': 60,
          },
          {
            'id': '3',
            'name': 'Bài thi Hóa học cơ bản',
            'description': 'Kiểm tra kiến thức hóa học cơ bản',
            'subjectId': '3',
            'subjectName': 'Hóa học',
            'difficultyLevel': 'Easy',
            'duration': 45,
            'questionCount': 15,
            'totalQuestions': 15,
            'timeLimit': 45,
          },
          {
            'id': '4',
            'name': 'Đề thi thử Sinh học',
            'description': 'Đề thi thử môn Sinh học theo cấu trúc mới',
            'subjectId': '4',
            'subjectName': 'Sinh học',
            'difficultyLevel': 'Medium',
            'duration': 50,
            'questionCount': 18,
            'totalQuestions': 18,
            'timeLimit': 50,
          },
          {
            'id': '5',
            'name': 'Kiểm tra Ngữ văn',
            'description': 'Bài kiểm tra đọc hiểu và nghị luận',
            'subjectId': '5',
            'subjectName': 'Ngữ văn',
            'difficultyLevel': 'Medium',
            'duration': 120,
            'questionCount': 12,
            'totalQuestions': 12,
            'timeLimit': 120,
          },
          {
            'id': '6',
            'name': 'English Test Advanced',
            'description': 'Advanced English test with reading and grammar',
            'subjectId': '6',
            'subjectName': 'Tiếng Anh',
            'difficultyLevel': 'Hard',
            'duration': 75,
            'questionCount': 30,
            'totalQuestions': 30,
            'timeLimit': 75,
          },
        ];
      });
    } catch (e) {
      print('Error loading mock tests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTests {
    return _tests.where((test) {
      final matchesSearch = _searchQuery.isEmpty ||
          test['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          test['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSubject = _selectedSubject == 'all' ||
          test['subjectId'] == _selectedSubject;
      
      final matchesDifficulty = _selectedDifficulty == 'all' ||
          test['difficultyLevel'] == _selectedDifficulty;
      
      return matchesSearch && matchesSubject && matchesDifficulty;
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
                                Icons.quiz,
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
                                    'Mock Tests',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 28 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Luyện tập với các đề thi thử',
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
                          'Tìm kiếm bài thi',
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
                  
                  // Filters
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
                          'Bộ lọc',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        
                        // Subject Filter
                        Text(
                          'Môn học:',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 8 : 6),
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
                        
                        SizedBox(height: isDesktop ? 16 : 12),
                        
                        // Difficulty Filter
                        Text(
                          'Độ khó:',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 8 : 6),
                        Wrap(
                          spacing: isDesktop ? 12 : 8,
                          runSpacing: isDesktop ? 12 : 8,
                          children: _difficulties.map((difficulty) {
                            final isSelected = _selectedDifficulty == difficulty['id'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDifficulty = difficulty['id']!;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 16 : 12,
                                  vertical: isDesktop ? 8 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF8B5CF6) 
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF8B5CF6) 
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  difficulty['name']!,
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
                  
                  // Tests Grid
                  Text(
                    'Danh sách bài thi (${_filteredTests.length})',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),
                  
                  if (_filteredTests.isEmpty)
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
                            Icons.quiz,
                            size: isDesktop ? 64 : 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            'Không tìm thấy bài thi nào',
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
                      itemCount: _filteredTests.length,
                      itemBuilder: (context, index) {
                        final test = _filteredTests[index];
                        return _buildTestCard(test, isDesktop);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, bool isDesktop) {
    return Container(
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
              color: _getSubjectColor(test['subjectId']).withOpacity(0.1),
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
                    color: _getSubjectColor(test['subjectId']),
                    borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                  ),
                  child: Icon(
                    Icons.quiz,
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
                        test['subjectName'],
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: _getSubjectColor(test['subjectId']),
                        ),
                      ),
                      Text(
                        '${test['timeLimit']} phút',
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
                    color: _getDifficultyColor(test['difficultyLevel']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                  ),
                  child: Text(
                    test['difficultyLevel'],
                    style: TextStyle(
                      fontSize: isDesktop ? 10 : 8,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(test['difficultyLevel']),
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
                    test['name'],
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
                    test['description'],
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu hỏi',
                              style: TextStyle(
                                fontSize: isDesktop ? 12 : 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${test['questionCount']}',
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thời gian',
                              style: TextStyle(
                                fontSize: isDesktop ? 12 : 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${test['timeLimit']}p',
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
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
          ),
          
          // Action button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to test detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bắt đầu bài thi: ${test['name']}')),
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
                    'Bắt đầu thi',
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
    );
  }
}
