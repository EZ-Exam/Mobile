import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/auth_status_widget.dart';

class QuestionPracticePage extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic>? questionData;
  
  const QuestionPracticePage({
    super.key,
    required this.questionId,
    this.questionData,
  });

  @override
  State<QuestionPracticePage> createState() => _QuestionPracticePageState();
}

class _QuestionPracticePageState extends State<QuestionPracticePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _question;
  bool _isLoading = true;
  String? _error;
  String? _selectedAnswer;
  bool _showAnswer = false;
  bool _isAnswered = false;
  bool _isAuthenticated = false;
  String? _userName;
  
  // Comments system
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    if (widget.questionData != null) {
      _question = widget.questionData;
      _isLoading = false;
      _loadComments();
    } else {
      _loadQuestionDetail();
    }
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _apiService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });
    
    if (isAuth) {
      try {
        final userProfile = await _apiService.getUserProfile();
        setState(() {
          _userName = userProfile['name']?.toString() ?? userProfile['email']?.toString();
        });
      } catch (e) {
        print('❌ Error getting user profile: $e');
      }
      _loadComments();
    }
  }

  Future<void> _loadQuestionDetail() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔍 Loading question detail for ID: ${widget.questionId}');
      
      if (widget.questionData != null) {
        setState(() {
          _question = widget.questionData;
          _isLoading = false;
        });
        _loadComments();
      } else {
        throw Exception('Question data not provided');
      }
    } catch (e) {
      print('❌ Error loading question detail: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    if (!_isAuthenticated) return;
    
    setState(() => _isLoadingComments = true);
    
    try {
      final response = await _apiService.getQuestionComments(widget.questionId);
      
      setState(() {
        _comments = List<Map<String, dynamic>>.from(response['items'] ?? []);
        _isLoadingComments = false;
      });
    } catch (e) {
      print('❌ Error loading comments: $e');
      setState(() {
        _comments = [];
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _submitComment() async {
    if (!_isAuthenticated) {
      _showLoginDialog();
      return;
    }
    
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    setState(() => _isSubmittingComment = true);
    
    try {
      final response = await _apiService.addQuestionComment(widget.questionId, content);
      
      // Add the new comment to the list
      final newComment = {
        'id': response['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'userName': response['userName']?.toString() ?? 'Bạn',
        'userAvatar': response['userAvatar'],
        'createdAt': response['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        'likes': 0,
        'isLiked': false,
      };
      
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
        _isSubmittingComment = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bình luận đã được thêm!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error submitting comment: $e');
      setState(() => _isSubmittingComment = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm bình luận: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleCommentLike(String commentId, int index) async {
    if (!_isAuthenticated) {
      _showLoginDialog();
      return;
    }

    try {
      await _apiService.toggleCommentLike(commentId);
      
      setState(() {
        final comment = _comments[index];
        final currentLikes = comment['likes'] ?? 0;
        final isLiked = comment['isLiked'] ?? false;
        
        _comments[index] = {
          ...comment,
          'likes': isLiked ? currentLikes - 1 : currentLikes + 1,
          'isLiked': !isLiked,
        };
      });
    } catch (e) {
      print('❌ Error toggling comment like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thích bình luận: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() async {
    try {
      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      setState(() {
        _isAuthenticated = false;
        _userName = null;
        _comments.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng xuất thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text('Bạn cần đăng nhập để tham gia thảo luận và tương tác với câu hỏi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/signin');
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một đáp án!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAnswered = true;
      _showAnswer = true;
    });

    // Check if answer is correct
    final correctAnswer = _question?['correctAnswer']?.toString() ?? '';
    final isCorrect = _selectedAnswer == correctAnswer;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? '🎉 Đáp án đúng!' : '❌ Đáp án sai!'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showExplanation() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _resetQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showAnswer = false;
      _isAnswered = false;
    });
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

  String _formatTimeAgo(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Làm bài tập'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _resetQuestion,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm lại',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            )
          : _error != null
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
                        onPressed: _loadQuestionDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _question == null
                  ? const Center(
                      child: Text('Không tìm thấy câu hỏi'),
                    )
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          // Tab Bar
                          Container(
                            color: Colors.white,
                            child: TabBar(
                              labelColor: const Color(0xFF3B82F6),
                              unselectedLabelColor: Colors.grey[600],
                              indicatorColor: const Color(0xFF3B82F6),
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.quiz),
                                  text: 'Câu hỏi',
                                ),
                                Tab(
                                  icon: Icon(Icons.comment),
                                  text: 'Thảo luận',
                                ),
                              ],
                            ),
                          ),
                          
                          // Tab Content
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Question Tab
                                SingleChildScrollView(
                                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Question Header
                                      _buildQuestionHeader(isDesktop),
                                      
                                      SizedBox(height: isDesktop ? 24 : 20),
                                      
                                      // Question Content
                                      _buildQuestionContent(isDesktop),
                                      
                                      SizedBox(height: isDesktop ? 24 : 20),
                                      
                                      // Answer Options
                                      _buildAnswerOptions(isDesktop),
                                      
                                      SizedBox(height: isDesktop ? 24 : 20),
                                      
                                      // Action Buttons
                                      _buildActionButtons(isDesktop),
                                      
                                      SizedBox(height: isDesktop ? 24 : 20),
                                      
                                      // Answer Explanation (if shown)
                                      if (_showAnswer) _buildAnswerExplanation(isDesktop),
                                      
                                      SizedBox(height: isDesktop ? 24 : 20),
                                      
                                      // Question Info
                                      _buildQuestionInfo(isDesktop),
                                    ],
                                  ),
                                ),
                                
                                // Comments Tab
                                _buildCommentsTab(isDesktop),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildQuestionHeader(bool isDesktop) {
    final difficultyInfo = _getDifficultyInfo(_question?['difficultyLevelId']);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
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
                      'Câu hỏi #${_question?['id']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _question?['lessonName']?.toString() ?? 'Không xác định',
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.white.withOpacity(0.9),
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
                  color: difficultyInfo['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                ),
                child: Text(
                  difficultyInfo['text'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
            'Nội dung câu hỏi',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            _question?['content']?.toString() ?? 'Không có nội dung',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: const Color(0xFF374151),
              height: 1.6,
            ),
          ),
          if (_question?['image'] != null) ...[
            SizedBox(height: isDesktop ? 16 : 12),
            Container(
              width: double.infinity,
              height: isDesktop ? 200 : 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                child: Image.network(
                  _question?['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(bool isDesktop) {
    final options = _question?['options'] as List<dynamic>? ?? [];
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
            'Các lựa chọn',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value.toString();
            final isSelected = _selectedAnswer == option;
            final isCorrect = _showAnswer && option == _question?['correctAnswer']?.toString();
            final isWrong = _showAnswer && isSelected && option != _question?['correctAnswer']?.toString();
            
            return Container(
              margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
              child: InkWell(
                onTap: _isAnswered ? null : () => _selectAnswer(option),
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : isWrong
                            ? Colors.red.withOpacity(0.1)
                            : isSelected
                                ? const Color(0xFF3B82F6).withOpacity(0.1)
                                : Colors.grey[50],
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green
                          : isWrong
                              ? Colors.red
                              : isSelected
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey[300]!,
                      width: isCorrect || isWrong || isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isDesktop ? 32 : 28,
                        height: isDesktop ? 32 : 28,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green
                              : isWrong
                                  ? Colors.red
                                  : isSelected
                                      ? const Color(0xFF3B82F6)
                                      : Colors.grey[300],
                          borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isCorrect || isWrong || isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: isDesktop ? 14 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16 : 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: const Color(0xFF374151),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      if (isWrong)
                        const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isAnswered ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              ),
            ),
            child: Text(
              _isAnswered ? 'Đã trả lời' : 'Nộp bài',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _showAnswer ? null : _showExplanation,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              ),
            ),
            child: Text(
              'Xem đáp án',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerExplanation(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Text(
                'Đáp án và giải thích',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: isDesktop ? 8 : 6),
                Text(
                  'Đáp án đúng: ${_question?['correctAnswer']?.toString() ?? 'Không có'}',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            'Giải thích:',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            _question?['explanation']?.toString() ?? 'Không có giải thích',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
            'Thông tin câu hỏi',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          _buildInfoRow(
            'Nguồn:',
            _question?['questionSource']?.toString() ?? 'Không xác định',
            Icons.source,
            isDesktop,
          ),
          _buildInfoRow(
            'Bài học:',
            _question?['lessonName']?.toString() ?? 'Không xác định',
            Icons.menu_book,
            isDesktop,
          ),
          _buildInfoRow(
            'Chương:',
            _question?['chapterName']?.toString() ?? 'Không xác định',
            Icons.folder,
            isDesktop,
          ),
          _buildInfoRow(
            'Loại:',
            _question?['type']?.toString() ?? 'Không xác định',
            Icons.category,
            isDesktop,
          ),
          _buildInfoRow(
            'Người tạo:',
            _question?['createdByUserName']?.toString() ?? 'Không xác định',
            Icons.person,
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: isDesktop ? 16 : 14,
            color: Colors.grey[600],
          ),
          SizedBox(width: isDesktop ? 8 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(width: isDesktop ? 8 : 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(bool isDesktop) {
    return Column(
      children: [
        // Auth Status Widget
        Padding(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          child: AuthStatusWidget(
            isAuthenticated: _isAuthenticated,
            userName: _userName,
            onLoginPressed: () => Navigator.pushNamed(context, '/signin'),
            onLogoutPressed: _logout,
          ),
        ),
        
        // Comment Input
        Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
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
                'Tham gia thảo luận',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: _isAuthenticated 
                      ? 'Chia sẻ suy nghĩ của bạn về câu hỏi này...'
                      : 'Đăng nhập để tham gia thảo luận',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                  ),
                  enabled: _isAuthenticated,
                ),
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isAuthenticated && !_isSubmittingComment ? _submitComment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : 20,
                        vertical: isDesktop ? 12 : 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                      ),
                    ),
                    child: _isSubmittingComment
                        ? SizedBox(
                            height: isDesktop ? 16 : 14,
                            width: isDesktop ? 16 : 14,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Gửi bình luận',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Comments List
        Expanded(
          child: _isLoadingComments
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                )
              : _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: isDesktop ? 64 : 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            'Chưa có bình luận nào',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 8 : 4),
                          Text(
                            'Hãy là người đầu tiên tham gia thảo luận!',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildCommentCard(comment, index, isDesktop);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment, int index, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
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
          // Comment Header
          Row(
            children: [
              CircleAvatar(
                radius: isDesktop ? 20 : 16,
                backgroundColor: const Color(0xFF3B82F6),
                child: Text(
                  comment['userName']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['userName']?.toString() ?? 'Người dùng',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment['createdAt']?.toString() ?? ''),
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Like Button
              IconButton(
                onPressed: () => _toggleCommentLike(comment['id']?.toString() ?? '', index),
                icon: Icon(
                  comment['isLiked'] == true ? Icons.favorite : Icons.favorite_border,
                  color: comment['isLiked'] == true ? Colors.red : Colors.grey[600],
                  size: isDesktop ? 20 : 18,
                ),
                tooltip: 'Thích',
              ),
            ],
          ),
          
          SizedBox(height: isDesktop ? 12 : 8),
          
          // Comment Content
          Text(
            comment['content']?.toString() ?? '',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          
          SizedBox(height: isDesktop ? 12 : 8),
          
          // Comment Actions
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement reply functionality
                },
                icon: Icon(
                  Icons.reply,
                  size: isDesktop ? 16 : 14,
                  color: Colors.grey[600],
                ),
                label: Text(
                  'Trả lời',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 12),
              Text(
                '${comment['likes'] ?? 0} lượt thích',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
