import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExamPage extends StatefulWidget {
  final String examId;
  final int? durationSeconds; // optional; fallback to server-provided

  const ExamPage({super.key, required this.examId, this.durationSeconds});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  String? _sessionId;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, String> _answers = {}; // questionId -> selected option

  int _timeLeft = 0; // seconds
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startExam() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _apiService.startQuiz(sourceId: widget.examId, sourceType: 'exam');
      final data = res['data'] ?? res;
      _sessionId = (data['sessionId'] ?? data['id'])?.toString();

      // questions array can be in data['questions'] or res['questions']
      final List questionsList = (data['questions'] ?? res['questions'] ?? []) as List;
      _questions = questionsList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // duration from server (seconds) or fallback to provided duration
      final int duration = (data['durationSeconds'] ?? widget.durationSeconds ?? 0) as int;
      _timeLeft = duration > 0 ? duration : 0;
      if (_timeLeft > 0) _startTimer();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_timeLeft <= 0) {
        t.cancel();
        await _submitExam(auto: true);
      } else {
        setState(() => _timeLeft -= 1);
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _submitExam({bool auto = false}) async {
    if (_sessionId == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final answersPayload = _answers.entries.map((e) => {
            'questionId': e.key,
            'answer': e.value,
          }).toList();
      final submit = await _apiService.submitQuiz(sessionId: _sessionId!, answers: answersPayload);
      final result = submit['data'] ?? submit;
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(auto ? 'Hết giờ' : 'Nộp bài'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kết quả: ${result['score'] ?? '-'}'),
                const SizedBox(height: 8),
                Text('Đúng: ${result['correctCount'] ?? '-'} | Sai: ${result['wrongCount'] ?? '-'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              )
            ],
          ),
        );
      }
      if (mounted) Navigator.pop(context); // exit exam page
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi nộp bài: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _selectAnswer(String questionId, String option) {
    setState(() {
      _answers[questionId] = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Làm bài thi'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          if (_timeLeft > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  _formatTime(_timeLeft),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          TextButton(
            onPressed: _isSubmitting ? null : () => _submitExam(auto: false),
            child: const Text('Nộp bài', style: TextStyle(color: Colors.white)),
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
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 24 : 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _startExam,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : _questions.isEmpty
                  ? const Center(child: Text('Không có câu hỏi trong đề thi'))
                  : ListView.builder(
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        final qId = (q['id'] ?? q['questionId'] ?? '$index').toString();
                        final content = q['content']?.toString() ?? q['question']?.toString() ?? 'Câu hỏi';
                        final List options = (q['options'] ?? q['choices'] ?? []) as List;
                        final selected = _answers[qId];
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
                              Text('Câu ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(content),
                              const SizedBox(height: 12),
                              ...options.map((opt) {
                                final optText = opt.toString();
                                final isSelected = selected == optText;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<String>(
                                    value: optText,
                                    groupValue: selected,
                                    onChanged: (v) => _selectAnswer(qId, optText),
                                  ),
                                  title: Text(optText),
                                  tileColor: isSelected ? const Color(0xFFF0F7FF) : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              })
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}


