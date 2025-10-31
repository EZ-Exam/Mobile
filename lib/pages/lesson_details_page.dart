import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class LessonDetailsPage extends StatefulWidget {
  final String lessonId;
  
  const LessonDetailsPage({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailsPage> createState() => _LessonDetailsPageState();
}

class _LessonDetailsPageState extends State<LessonDetailsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _lessonDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLessonDetails();
  }

  Future<void> _loadLessonDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.getLessonDetails(widget.lessonId);
      
      if (mounted) {
        setState(() {
          _lessonDetails = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết bài học'),
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu bài học')),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'PDF'),
              Tab(text: 'Quiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBody(showPdfOnly: true),
            _buildBody(showPdfOnly: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({bool showPdfOnly = false}) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
        ),
      );
    }

    if (_error != null) {
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
              onPressed: _loadLessonDetails,
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

    if (_lessonDetails == null) {
      return const Center(
        child: Text(
          'Không tìm thấy bài học',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // If only PDF tab requested, show simplified view focused on document
    if (showPdfOnly) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndMeta(),
                  const SizedBox(height: 20),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildContent(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Quiz tab: show lesson + questions
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroImage(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndMeta(),
                const SizedBox(height: 20),
                _buildDescription(),
                const SizedBox(height: 20),
                _buildQuizSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở liên kết')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Quiz state
  List<Map<String, dynamic>> _questions = [];
  bool _questionsLoading = false;
  final Map<String, String> _selectedAnswers = {};
  bool _quizSubmitted = false;
  Map<String, Map<String, dynamic>> _quizResults = {};

  Future<void> _loadQuestionsForLesson() async {
    if (_questionsLoading || _questions.isNotEmpty) return;
    setState(() {
      _questionsLoading = true;
    });

    try {
      // Try to get questions from lesson detail
      final lesson = _lessonDetails!;
      List<dynamic>? ids;
      if (lesson.containsKey('questions') && lesson['questions'] is List) {
        ids = List<dynamic>.from(lesson['questions']);
      }

      if (ids == null || ids.isEmpty) {
        // fallback to lesson questions endpoint
        final resp = await ApiService().getLessonQuestions(widget.lessonId);
        ids = resp['questions'] ?? resp['items'] ?? [];
      }

      final List<Map<String, dynamic>> loaded = [];
      for (final id in (ids ?? const <dynamic>[])) {
        try {
          final q = await ApiService().getQuestionDetails(id.toString());
          loaded.add(q);
        } catch (e) {
          // ignore individual failures
        }
      }

      setState(() {
        _questions = loaded;
      });
    } catch (e) {
      // ignore top-level errors for now
    } finally {
      setState(() {
        _questionsLoading = false;
      });
    }
  }

  Widget _buildQuizSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quiz Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Test your understanding of the lesson.'),
                const SizedBox(height: 12),
                if (_questionsLoading) const Center(child: CircularProgressIndicator()),
                if (!_questionsLoading && _questions.isEmpty) ...[
                  ElevatedButton(
                    onPressed: _loadQuestionsForLesson,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)),
                    child: const Text('Load Questions'),
                  ),
                ],
                if (_questions.isNotEmpty)
                  ..._questions.map((question) => _buildQuizQuestionCard(question)),
                const SizedBox(height: 12),
                if (_questions.isNotEmpty && !_quizSubmitted)
                  ElevatedButton(
                    onPressed: _submitQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)),
                    child: const Text('Submit Quiz'),
                  ),
                if (_quizSubmitted) _buildQuizResultSummary(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizQuestionCard(Map<String, dynamic> question) {
    final qid = question['id']?.toString() ?? question['_id']?.toString() ?? UniqueKey().toString();
    final options = (question['options'] is List) ? List<String>.from(question['options'].map((e) => e.toString())) : <String>[];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question['content']?.toString() ?? 'No content', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...options.map((opt) => RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _selectedAnswers[qid],
                onChanged: (val) {
                  if (_quizSubmitted) return;
                  setState(() {
                    if (val != null) _selectedAnswers[qid] = val;
                  });
                },
              )),
        ],
      ),
    );
  }

  void _submitQuiz() {
    final results = <String, Map<String, dynamic>>{};
    for (final q in _questions) {
      final qid = q['id']?.toString() ?? q['_id']?.toString() ?? '';
      final selected = _selectedAnswers[qid];
      final correct = q['correctAnswer']?.toString() ?? q['answer']?.toString() ?? '';
      final isCorrect = selected != null && correct.isNotEmpty && selected == correct;
      results[qid] = {'isCorrect': isCorrect, 'selected': selected ?? '' , 'correct': correct};
    }

    setState(() {
      _quizResults = results;
      _quizSubmitted = true;
    });
  }

  Widget _buildQuizResultSummary() {
    final total = _questions.length;
    final correctCount = _quizResults.values.where((r) => r['isCorrect'] == true).length;
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Text('Quiz Complete! You got $correctCount out of $total'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedAnswers.clear();
                    _quizResults.clear();
                    _quizSubmitted = false;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                child: const Text('Reset Quiz'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final lesson = _lessonDetails!;
    final imageUrl = lesson['imageUrl'] ?? lesson['thumbnail'];
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: imageUrl == null
          ? const Center(
              child: Icon(
                Icons.school,
                size: 80,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildTitleAndMeta() {
    final lesson = _lessonDetails!;
    final title = lesson['name'] ?? lesson['title'] ?? 'N/A';
    final chapterId = lesson['chapterId']?.toString() ?? 'N/A';
    final gradeId = lesson['gradeId']?.toString() ?? 'N/A';
    final createdAt = lesson['createdAt'] ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMetaChip(Icons.book, 'Chương $chapterId', Colors.blue),
            if (gradeId != 'N/A') _buildMetaChip(Icons.grade, 'Lớp $gradeId', Colors.orange),
            _buildMetaChip(Icons.calendar_today, _formatDate(createdAt), Colors.green),
          ],
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString == 'N/A') return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildMetaChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final lesson = _lessonDetails!;
    final description = lesson['description'] ?? 'Không có mô tả chi tiết';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mô tả bài học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final lesson = _lessonDetails!;
    final document = lesson['document'];
    final documentType = lesson['documentType'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tài liệu bài học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            if (document != null && documentType != null)
              _buildDocumentInfo(document, documentType)
            else
              const Text(
                'Chưa có tài liệu',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfo(String document, String documentType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getDocumentIcon(documentType),
              color: const Color(0xFF667eea),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Loại tài liệu: $documentType',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tài liệu: $document',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A5568),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_library;
      case 'image':
        return Icons.image;
      case 'text':
        return Icons.text_snippet;
      default:
        return Icons.description;
    }
  }

  Widget _buildActionButtons() {
    final lesson = _lessonDetails!;
    final lessonId = lesson['id']?.toString() ?? widget.lessonId;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to questions
                  Navigator.pushNamed(
                    context,
                    '/questions',
                    arguments: {
                      'lessonId': lessonId,
                      'lessonName': lesson['name'] ?? lesson['title'] ?? 'Bài học',
                    },
                  );
                },
                icon: const Icon(Icons.quiz),
                label: const Text('Làm bài tập'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu bài học')),
                  );
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Lưu bài'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF667eea),
                  side: const BorderSide(color: Color(0xFF667eea)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Start learning
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bắt đầu học bài')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu học'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
