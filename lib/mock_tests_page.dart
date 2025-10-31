
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mock_test_provider.dart';

class MockTestsPage extends StatelessWidget {
  const MockTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MockTestProvider(),
      child: Consumer<MockTestProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MockTestProvider provider) {
    if (provider.isLoading && provider.tests.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${provider.error}'),
            ),
            ElevatedButton(
              onPressed: () => provider.fetchMockTests(refresh: true),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSearchAndFilter(context, provider),
          const SizedBox(height: 20),
          _buildTestGrid(context, provider),
          const SizedBox(height: 20),
          _buildPagination(context, provider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return Container(
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
      child: Row(
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
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, MockTestProvider provider) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => provider.setSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo tên hoặc mô tả...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: provider.subjectFilter,
                onChanged: (value) => provider.setSubjectFilter(value!),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả môn học')),
                  DropdownMenuItem(value: 'Toán học', child: Text('Toán học')),
                  DropdownMenuItem(value: 'Vật lý', child: Text('Vật lý')),
                  DropdownMenuItem(value: 'Hóa học', child: Text('Hóa học')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: provider.difficultyFilter,
                onChanged: (value) => provider.setDifficultyFilter(value!),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả độ khó')),
                  DropdownMenuItem(value: 'Easy', child: Text('Dễ')),
                  DropdownMenuItem(value: 'Medium', child: Text('Trung bình')),
                  DropdownMenuItem(value: 'Hard', child: Text('Khó')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: provider.sortBy,
          onChanged: (value) => provider.setSortBy(value!),
          items: const [
            DropdownMenuItem(value: 'createdAt:desc', child: Text('Mới nhất')),
            DropdownMenuItem(value: 'createdAt:asc', child: Text('Cũ nhất')),
            DropdownMenuItem(value: 'name:asc', child: Text('Tên A-Z')),
            DropdownMenuItem(value: 'name:desc', child: Text('Tên Z-A')),
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTestGrid(BuildContext context, MockTestProvider provider) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    if (provider.tests.isEmpty) {
      return const Center(child: Text('Không tìm thấy bài thi nào.'));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: isDesktop ? 16 : 12,
        mainAxisSpacing: isDesktop ? 16 : 12,
        childAspectRatio: isDesktop ? 0.8 : 0.9,
      ),
      itemCount: provider.tests.length,
      itemBuilder: (context, index) {
        final test = provider.tests[index];
        return _buildTestCard(context, test, isDesktop);
      },
    );
  }

  Widget _buildTestCard(BuildContext context, MockTest test, bool isDesktop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSubjectColor(test.subjectName).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.book, color: _getSubjectColor(test.subjectName), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    test.subjectName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getSubjectColor(test.subjectName),
                    ),
                  ),
                ),
                Text(
                  test.examTypeName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text('${test.duration} phút'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.question_answer_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text('${test.totalQuestions} câu'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to test detail page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Center(
                child: Text(
                  'Bắt đầu thi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, MockTestProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: provider.pageNumber > 1
              ? () => provider.setPageNumber(provider.pageNumber - 1)
              : null,
        ),
        Text('Trang ${provider.pageNumber} của ${provider.totalPages}'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: provider.pageNumber < provider.totalPages
              ? () => provider.setPageNumber(provider.pageNumber + 1)
              : null,
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Toán học':
        return Colors.blue;
      case 'Vật lý':
        return Colors.purple;
      case 'Hóa học':
        return Colors.green;
      case 'Sinh học':
        return Colors.lightGreen;
      case 'Ngữ văn':
        return Colors.orange;
      case 'Tiếng Anh':
        return Colors.pink;
      case 'Lịch sử':
        return Colors.yellow;
      case 'Địa lý':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

