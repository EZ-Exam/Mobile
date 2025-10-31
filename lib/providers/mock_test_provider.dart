
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MockTest {
  final String id;
  final String name;
  final String subjectName;
  final String examTypeName;
  final int duration;
  final int totalQuestions;

  MockTest({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.examTypeName,
    required this.duration,
    required this.totalQuestions,
  });

  factory MockTest.fromJson(Map<String, dynamic> json) {
    return MockTest(
      id: json['id'],
      name: json['name'],
      subjectName: json['subjectName'] ?? '',
      examTypeName: json['examTypeName'] ?? '',
      duration: json['duration'] ?? json['timeLimit'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? json['questionCount'] ?? 0,
    );
  }
}

class MockTestProvider with ChangeNotifier {
  List<MockTest> _tests = [];
  bool _isLoading = false;
  String? _error;
  int _pageNumber = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _subjectFilter = 'all';
  String _difficultyFilter = 'all';
  String _sortBy = 'createdAt:desc';

  List<MockTest> get tests => _tests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pageNumber => _pageNumber;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get subjectFilter => _subjectFilter;
  String get difficultyFilter => _difficultyFilter;
  String get sortBy => _sortBy;

  MockTestProvider() {
    fetchMockTests();
  }

  Future<void> fetchMockTests({bool refresh = false}) async {
    if (refresh) {
      _pageNumber = 1;
      _tests = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = {
        'page': _pageNumber.toString(),
        'pageSize': '6',
        'search': _searchQuery,
        'sortBy': _sortBy.split(':')[0],
        'sortOrder': _sortBy.split(':')[1],
        if (_subjectFilter != 'all') 'subjectName': _subjectFilter,
        if (_difficultyFilter != 'all') 'examTypeName': _difficultyFilter,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/exams/optimized/feed').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        _tests = items.map((item) => MockTest.fromJson(item)).toList();
        _totalPages = data['totalPages'] ?? 1;
      } else {
        _error = 'Failed to load mock tests';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchMockTests(refresh: true);
  }

  void setSubjectFilter(String subject) {
    _subjectFilter = subject;
    fetchMockTests(refresh: true);
  }

  void setDifficultyFilter(String difficulty) {
    _difficultyFilter = difficulty;
    fetchMockTests(refresh: true);
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    fetchMockTests(refresh: true);
  }

  void setPageNumber(int page) {
    _pageNumber = page;
    fetchMockTests();
  }
}
