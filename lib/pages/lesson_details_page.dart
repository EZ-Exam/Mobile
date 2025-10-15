import 'package:flutter/material.dart';
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
    return Scaffold(
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Image
          _buildHeroImage(),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Meta
                _buildTitleAndMeta(),
                
                const SizedBox(height: 20),
                
                // Description
                _buildDescription(),
                
                const SizedBox(height: 20),
                
                // Content
                _buildContent(),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
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
    final title = lesson['title'] ?? 'N/A';
    final subject = lesson['subject'] ?? lesson['subjectName'] ?? 'N/A';
    final duration = lesson['duration'] ?? lesson['estimatedTime'] ?? 'N/A';
    final difficulty = lesson['difficulty'] ?? 'N/A';

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
        
        Row(
          children: [
            _buildMetaChip(Icons.subject, subject, Colors.blue),
            const SizedBox(width: 8),
            _buildMetaChip(Icons.timer, duration, Colors.orange),
            const SizedBox(width: 8),
            _buildMetaChip(Icons.trending_up, difficulty, Colors.green),
          ],
        ),
      ],
    );
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
    final description = lesson['description'] ?? lesson['summary'] ?? 'Không có mô tả';

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
              'Mô tả',
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
    final content = lesson['content'] ?? lesson['lessonContent'] ?? 'N/A';

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
              'Nội dung bài học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bắt đầu học bài')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu học'),
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
    );
  }
}
