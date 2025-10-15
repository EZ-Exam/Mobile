import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  String _searchQuery = '';
  String _selectedDifficulty = 'all';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  final List<Map<String, String>> _difficulties = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': '1', 'name': 'Nhận biết'},
    {'id': '2', 'name': 'Thông hiểu'},
    {'id': '3', 'name': 'Vận dụng'},
    {'id': '4', 'name': 'Vận dụng cao'},
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _questions = [
          {
            'id': '1',
            'content': 'Tìm nghiệm của phương trình: 2x + 3 = 7',
            'lessonName': 'Đại số cơ bản',
            'chapterName': 'Phương trình bậc nhất',
            'difficultyLevelId': 1,
            'questionSource': 'SGK Toán 10',
            'subjectName': 'Toán học',
          },
          {
            'id': '2',
            'content': 'Một vật có khối lượng 2kg chuyển động với vận tốc 5m/s. Tính động năng của vật.',
            'lessonName': 'Cơ học Newton',
            'chapterName': 'Động năng',
            'difficultyLevelId': 2,
            'questionSource': 'SGK Vật lý 10',
            'subjectName': 'Vật lý',
          },
          {
            'id': '3',
            'content': 'Viết phương trình phản ứng khi cho Na tác dụng với H2O',
            'lessonName': 'Hóa học vô cơ',
            'chapterName': 'Kim loại kiềm',
            'difficultyLevelId': 2,
            'questionSource': 'SGK Hóa học 10',
            'subjectName': 'Hóa học',
          },
          {
            'id': '4',
            'content': 'Tế bào nhân thực có những đặc điểm nào sau đây?',
            'lessonName': 'Sinh học tế bào',
            'chapterName': 'Cấu trúc tế bào',
            'difficultyLevelId': 1,
            'questionSource': 'SGK Sinh học 10',
            'subjectName': 'Sinh học',
          },
          {
            'id': '5',
            'content': 'Phân tích nghệ thuật sử dụng từ ngữ trong đoạn thơ sau...',
            'lessonName': 'Văn học hiện đại',
            'chapterName': 'Thơ ca Việt Nam',
            'difficultyLevelId': 3,
            'questionSource': 'SGK Ngữ văn 12',
            'subjectName': 'Ngữ văn',
          },
          {
            'id': '6',
            'content': 'Choose the correct form: "If I _____ you, I would study harder."',
            'lessonName': 'Grammar Advanced',
            'chapterName': 'Conditional Sentences',
            'difficultyLevelId': 3,
            'questionSource': 'Cambridge English',
            'subjectName': 'Tiếng Anh',
          },
        ];
      });
    } catch (e) {
      print('Error loading questions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredQuestions {
    return _questions.where((question) {
      final matchesSearch = _searchQuery.isEmpty ||
          question['content'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          question['lessonName'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesDifficulty = _selectedDifficulty == 'all' ||
          question['difficultyLevelId'].toString() == _selectedDifficulty;
      
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  Map<String, dynamic> _getDifficultyInfo(int difficultyLevelId) {
    switch (difficultyLevelId) {
      case 1: return {'text': 'Nhận biết', 'color': const Color(0xFF10B981)};
      case 2: return {'text': 'Thông hiểu', 'color': const Color(0xFFF59E0B)};
      case 3: return {'text': 'Vận dụng', 'color': const Color(0xFFEF4444)};
      case 4: return {'text': 'Vận dụng cao', 'color': const Color(0xFF8B5CF6)};
      default: return {'text': 'Unknown', 'color': const Color(0xFF6B7280)};
    }
  }

  Color _getSubjectColor(String subjectName) {
    switch (subjectName) {
      case 'Toán học': return const Color(0xFF3B82F6);
      case 'Vật lý': return const Color(0xFF8B5CF6);
      case 'Hóa học': return const Color(0xFF10B981);
      case 'Sinh học': return const Color(0xFF059669);
      case 'Ngữ văn': return const Color(0xFFF59E0B);
      case 'Tiếng Anh': return const Color(0xFFEC4899);
      case 'Lịch sử': return const Color(0xFFEF4444);
      case 'Địa lý': return const Color(0xFF14B8A6);
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
                                Icons.psychology,
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
                                    'Question Bank',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 28 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Ngân hàng câu hỏi phong phú',
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
                  
                  // Stats Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 5 : 3,
                    crossAxisSpacing: isDesktop ? 16 : 12,
                    mainAxisSpacing: isDesktop ? 16 : 12,
                    childAspectRatio: isDesktop ? 1.2 : 1.1,
                    children: [
                      _buildStatCard(
                        'Tổng câu hỏi',
                        '${_questions.length}',
                        Icons.quiz,
                        const Color(0xFF3B82F6),
                        isDesktop,
                      ),
                      _buildStatCard(
                        'Nhận biết',
                        '${_questions.where((q) => q['difficultyLevelId'] == 1).length}',
                        Icons.lightbulb,
                        const Color(0xFF10B981),
                        isDesktop,
                      ),
                      _buildStatCard(
                        'Thông hiểu',
                        '${_questions.where((q) => q['difficultyLevelId'] == 2).length}',
                        Icons.trending_up,
                        const Color(0xFFF59E0B),
                        isDesktop,
                      ),
                      _buildStatCard(
                        'Vận dụng',
                        '${_questions.where((q) => q['difficultyLevelId'] == 3).length}',
                        Icons.flash_on,
                        const Color(0xFFEF4444),
                        isDesktop,
                      ),
                      _buildStatCard(
                        'Vận dụng cao',
                        '${_questions.where((q) => q['difficultyLevelId'] == 4).length}',
                        Icons.psychology,
                        const Color(0xFF8B5CF6),
                        isDesktop,
                      ),
                    ],
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
                          'Tìm kiếm câu hỏi',
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
                            hintText: 'Tìm kiếm theo nội dung hoặc bài học...',
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
                  
                  // Difficulty Filter
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
                          'Lọc theo độ khó',
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
                  
                  // Questions List
                  Text(
                    'Danh sách câu hỏi (${_filteredQuestions.length})',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),
                  
                  if (_filteredQuestions.isEmpty)
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
                            'Không tìm thấy câu hỏi nào',
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredQuestions.length,
                      itemBuilder: (context, index) {
                        final question = _filteredQuestions[index];
                        return _buildQuestionCard(question, isDesktop);
                      },
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, bool isDesktop) {
    final difficultyInfo = _getDifficultyInfo(question['difficultyLevelId']);
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 8 : 6),
                decoration: BoxDecoration(
                  color: _getSubjectColor(question['subjectName']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                ),
                child: Icon(
                  Icons.quiz,
                  color: _getSubjectColor(question['subjectName']),
                  size: isDesktop ? 20 : 16,
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['subjectName'],
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: _getSubjectColor(question['subjectName']),
                      ),
                    ),
                    Text(
                      'Question #${question['id']}',
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
                  horizontal: isDesktop ? 12 : 8,
                  vertical: isDesktop ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: difficultyInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                ),
                child: Text(
                  difficultyInfo['text'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: difficultyInfo['color'],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Question Content
          Text(
            question['content'],
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Lesson Info
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: isDesktop ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isDesktop ? 8 : 6),
                    Expanded(
                      child: Text(
                        'Bài học: ${question['lessonName']}',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (question['chapterName'] != null) ...[
                  SizedBox(height: isDesktop ? 8 : 6),
                  Row(
                    children: [
                      Icon(
                        Icons.folder,
                        size: isDesktop ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isDesktop ? 8 : 6),
                      Expanded(
                        child: Text(
                          'Chương: ${question['chapterName']}',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: isDesktop ? 8 : 6),
                Row(
                  children: [
                    Icon(
                      Icons.source,
                      size: isDesktop ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isDesktop ? 8 : 6),
                    Expanded(
                      child: Text(
                        'Nguồn: ${question['questionSource']}',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to question detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xem chi tiết câu hỏi #${question['id']}')),
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
                  const Icon(Icons.visibility, size: 20),
                  SizedBox(width: isDesktop ? 8 : 4),
                  Text(
                    'Xem chi tiết',
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
