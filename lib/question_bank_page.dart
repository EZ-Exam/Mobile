import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  String _searchQuery = '';
  String _selectedDifficulty = 'all';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _currentPage = 1;
  bool _hasMoreData = true;
  String? _error;

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

  Future<void> _loadQuestions({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _questions.clear();
        _error = null;
      });
    }

    if (!_hasMoreData) return;

    setState(() => _isLoading = true);
    
    try {
      print('🔍 Loading questions - Page: $_currentPage, Difficulty: $_selectedDifficulty, Sort: $_sortBy:$_sortOrder');
      
      final response = await _apiService.getQuestions(
        pageNumber: _currentPage,
        pageSize: 10,
        difficultyLevelId: _selectedDifficulty == 'all' ? null : _selectedDifficulty,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      print('🔍 Questions Response: $response');
      
      // Debug: Print first question structure if available
      if (response['items'] != null && response['items'].isNotEmpty) {
        print('🔍 First Question Structure: ${response['items'][0]}');
        print('🔍 Question Fields: ${response['items'][0].keys.toList()}');
      }
      
      if (response['items'] != null) {
        final newQuestions = List<Map<String, dynamic>>.from(response['items']);
        
        setState(() {
          if (isRefresh) {
            _questions = newQuestions;
          } else {
            _questions.addAll(newQuestions);
          }
          
          _hasMoreData = response['pageNumber'] < response['totalPages'];
          _currentPage++;
        });
        
        print('🔍 Loaded ${newQuestions.length} questions. Total: ${_questions.length}');
        print('🔍 Pagination: Page ${response['pageNumber']} of ${response['totalPages']}');
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print('❌ Error loading questions: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadQuestions(isRefresh: true);
  }

  Future<void> _loadMore() async {
    await _loadQuestions();
  }

  void _onDifficultyChanged(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _loadQuestions(isRefresh: true);
  }


  List<Map<String, dynamic>> get _filteredQuestions {
    return _questions.where((question) {
      // Safe null handling for all fields
      final content = question['content']?.toString() ?? '';
      final lessonName = question['lessonName']?.toString() ?? '';
      final subjectName = question['subjectName']?.toString() ?? '';
      final chapterName = question['chapterName']?.toString() ?? '';
      
      final matchesSearch = _searchQuery.isEmpty ||
          content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lessonName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subjectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chapterName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesDifficulty = _selectedDifficulty == 'all' ||
          question['difficultyLevelId']?.toString() == _selectedDifficulty;
      
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  Map<String, dynamic> _getDifficultyInfo(dynamic difficultyLevelId) {
    final level = difficultyLevelId?.toString() ?? '1';
    switch (level) {
      case '1': return {'text': 'Nhận biết', 'color': const Color(0xFF10B981)};
      case '2': return {'text': 'Thông hiểu', 'color': const Color(0xFFF59E0B)};
      case '3': return {'text': 'Vận dụng', 'color': const Color(0xFFEF4444)};
      case '4': return {'text': 'Vận dụng cao', 'color': const Color(0xFF8B5CF6)};
      default: return {'text': 'Unknown', 'color': const Color(0xFF6B7280)};
    }
  }

  Color _getSubjectColor(String? subjectName) {
    final subject = subjectName?.toString() ?? '';
    switch (subject) {
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
      body: _isLoading && _questions.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            )
          : _error != null && _questions.isEmpty
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
                      ElevatedButton(
                        onPressed: () => _loadQuestions(isRefresh: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                              onTap: () => _onDifficultyChanged(difficulty['id']!),
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
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final question = _filteredQuestions[index];
                            return _buildQuestionCard(question, isDesktop);
                          },
                        ),
                        if (_hasMoreData) _buildLoadMoreButton(isDesktop),
                      ],
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLoadMoreButton(bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(top: isDesktop ? 20 : 16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loadMore,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 24,
            vertical: isDesktop ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: isDesktop ? 20 : 16,
                width: isDesktop ? 20 : 16,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.expand_more),
                  SizedBox(width: isDesktop ? 8 : 4),
                  Text(
                    'Tải thêm',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.bold,
                    ),
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
    
    return InkWell(
      onTap: () {
        // Navigate to question detail when tapped
        Navigator.pushNamed(
          context,
          '/question-detail',
          arguments: {
            'questionId': question['id']?.toString() ?? 'N/A',
            'questionData': question,
          },
        );
      },
      borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      child: Container(
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
                      question['subjectName']?.toString() ?? 'Không xác định',
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: _getSubjectColor(question['subjectName']?.toString() ?? ''),
                      ),
                    ),
                    Text(
                      'Question #${question['id']?.toString() ?? 'N/A'}',
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
            question['content']?.toString() ?? 'Không có nội dung',
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
                        'Bài học: ${question['lessonName']?.toString() ?? 'Không xác định'}',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (question['chapterName']?.toString().isNotEmpty == true) ...[
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
                          'Chương: ${question['chapterName']?.toString() ?? 'Không xác định'}',
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
                        'Nguồn: ${question['questionSource']?.toString() ?? 'Không xác định'}',
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
          
        ],
      ),
    ),
    );
  }
}
