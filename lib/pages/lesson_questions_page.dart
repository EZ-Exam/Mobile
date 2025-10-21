import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class LessonQuestionsPage extends StatefulWidget {
  final String lessonId;
  final String lessonName;
  
  const LessonQuestionsPage({
    super.key,
    required this.lessonId,
    required this.lessonName,
  });

  @override
  State<LessonQuestionsPage> createState() => _LessonQuestionsPageState();
}

class _LessonQuestionsPageState extends State<LessonQuestionsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

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
      });
    }

    if (!_hasMoreData) return;

    setState(() => _isLoading = true);

    try {
      print('🔍 Loading questions for lesson ${widget.lessonId} - Page: $_currentPage');

      final response = await _apiService.getLessonQuestions(widget.lessonId);
      
      print('🔍 Questions Response: $response');

      if (response['items'] != null && response['items'] is List) {
        final List<dynamic> questionsData = response['items'];
        final List<Map<String, dynamic>> newQuestions = questionsData
            .map((question) => Map<String, dynamic>.from(question))
            .toList();

        setState(() {
          if (isRefresh) {
            _questions = newQuestions;
          } else {
            _questions.addAll(newQuestions);
          }

          // Check if there's more data based on pagination
          final totalPages = response['totalPages'] ?? 1;
          final currentPage = response['pageNumber'] ?? 1;
          _hasMoreData = currentPage < totalPages;
          _currentPage++;
        });

        print('🔍 Loaded ${newQuestions.length} questions. Total: ${_questions.length}');
      } else {
        print('❌ No questions data in response');
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print('❌ Error loading questions: $e');
      setState(() {
        _error = e.toString();
        _hasMoreData = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải câu hỏi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadQuestions(isRefresh: true);
  }

  void _loadMore() {
    if (!_isLoading && _hasMoreData) {
      _loadQuestions();
    }
  }

  Map<String, dynamic> _getDifficultyInfo(int? difficultyLevelId) {
    switch (difficultyLevelId) {
      case 1: return {'text': 'Nhận biết', 'color': const Color(0xFF10B981)};
      case 2: return {'text': 'Thông hiểu', 'color': const Color(0xFFF59E0B)};
      case 3: return {'text': 'Vận dụng', 'color': const Color(0xFFEF4444)};
      case 4: return {'text': 'Vận dụng cao', 'color': const Color(0xFF8B5CF6)};
      default: return {'text': 'Không xác định', 'color': const Color(0xFF6B7280)};
    }
  }

  Color _getSubjectColor(String? subjectId) {
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

  String _getSubjectName(String? subjectId) {
    switch (subjectId) {
      case '1': return 'Toán học';
      case '2': return 'Vật lý';
      case '3': return 'Hóa học';
      case '4': return 'Sinh học';
      case '5': return 'Ngữ văn';
      case '6': return 'Tiếng Anh';
      case '7': return 'Lịch sử';
      case '8': return 'Địa lý';
      default: return 'Khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Câu hỏi - ${widget.lessonName}'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isLoading && _questions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
        ),
      );
    }

    if (_error != null && _questions.isEmpty) {
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
              onPressed: _onRefresh,
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

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: isDesktop ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            Text(
              'Chưa có câu hỏi nào',
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isDesktop ? 8 : 4),
            Text(
              'Bài học này chưa có câu hỏi để luyện tập',
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF667eea),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 24 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isDesktop ? 12 : 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
                        ),
                        child: Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: isDesktop ? 24 : 20,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu hỏi bài học',
                              style: TextStyle(
                                fontSize: isDesktop ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${_questions.length} câu hỏi có sẵn',
                              style: TextStyle(
                                fontSize: isDesktop ? 14 : 12,
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

            // Questions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return _buildQuestionCard(question, isDesktop);
              },
            ),

            SizedBox(height: isDesktop ? 16 : 12),

            // Load More Button
            if (_hasMoreData)
              _buildLoadMoreButton(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: _loadMore,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                )
              else
                Icon(
                  Icons.add,
                  size: isDesktop ? 28 : 24,
                  color: Colors.grey[600],
                ),
              SizedBox(height: isDesktop ? 8 : 4),
              Text(
                _isLoading ? 'Đang tải...' : 'Tải thêm câu hỏi',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, bool isDesktop) {
    final difficultyInfo = _getDifficultyInfo(question['difficultyLevelId']);
    final subjectColor = _getSubjectColor(question['subjectId']);
    final subjectName = _getSubjectName(question['subjectId']);

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
                  color: subjectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                ),
                child: Icon(
                  Icons.quiz,
                  color: subjectColor,
                  size: isDesktop ? 20 : 16,
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectName,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                    ),
                    Text(
                      'Câu hỏi #${question['id'] ?? 'N/A'}',
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
            question['content']?.toString() ?? 'Không có nội dung câu hỏi',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),

          SizedBox(height: isDesktop ? 16 : 12),

          // Question Type and Source
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
            child: Column(
              children: [
                if (question['questionType'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: isDesktop ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isDesktop ? 8 : 6),
                      Expanded(
                        child: Text(
                          'Loại: ${question['questionType']}',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 8 : 6),
                ],
                if (question['questionSource'] != null) ...[
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
              ],
            ),
          ),

          SizedBox(height: isDesktop ? 16 : 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to question detail or start quiz
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bắt đầu làm câu hỏi #${question['id'] ?? 'N/A'}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
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
                    'Làm bài',
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
