import 'package:flutter/material.dart';
import 'question_practice_page.dart';

class QuestionPracticeDemo extends StatelessWidget {
  const QuestionPracticeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Question Practice'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz,
              size: 64,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Question Practice Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Trang làm bài với tính năng thảo luận',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPracticePage(
                      questionId: '1',
                      questionData: {
                        'id': '1',
                        'content': 'Câu hỏi mẫu: Đây là một câu hỏi trắc nghiệm để demo tính năng làm bài và thảo luận. Bạn có thể chọn đáp án và tham gia thảo luận với các học viên khác.',
                        'options': [
                          'Đáp án A: Lựa chọn đầu tiên',
                          'Đáp án B: Lựa chọn thứ hai',
                          'Đáp án C: Lựa chọn thứ ba',
                          'Đáp án D: Lựa chọn thứ tư',
                        ],
                        'correctAnswer': 'Đáp án B: Lựa chọn thứ hai',
                        'explanation': 'Giải thích: Đây là giải thích mẫu cho câu hỏi. Đáp án B là đúng vì...',
                        'difficultyLevelId': 2,
                        'lessonName': 'Bài học mẫu',
                        'subjectName': 'Toán học',
                        'chapterName': 'Chương 1',
                        'questionSource': 'Sách giáo khoa',
                        'type': 'Trắc nghiệm',
                        'createdByUserName': 'Giáo viên',
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bắt đầu làm bài',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đăng nhập để thảo luận',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
