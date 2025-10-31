
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class Message {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _sessionId;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get sessionId => _sessionId;

  ChatProvider() {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('chatSessionId');

    if (_sessionId != null) {
      await _loadChatHistory(_sessionId!);
    } else {
      _messages = [
        Message(
          id: 'welcome',
          text: 'Hello! I\'m your AI assistant. How can I help you today?',
          sender: 'support',
          timestamp: DateTime.now(),
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> _loadChatHistory(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ChatGPTChat/history/$sessionId'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final history = json.decode(response.body) as List;
        _messages = history.map((item) => Message(
          id: item['id']?.toString() ?? DateTime.now().toString(),
          text: item['message'] ?? item['text'] ?? '',
          sender: item['sender'] ?? 'support',
          timestamp: DateTime.parse(item['timestamp'] ?? DateTime.now().toString()),
        )).toList();
      } else {
        _error = 'Failed to load chat history';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, {Map<String, dynamic>? user}) async {
    final userMessage = Message(
      id: DateTime.now().toString(),
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final requestData = {
        'message': text,
        if (_sessionId != null) 'sessionId': _sessionId,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ChatGPTChat/chat'),
        headers: {...ApiConfig.defaultHeaders, 'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final chatResponse = json.decode(response.body);
        final aiMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: chatResponse['message'],
          sender: 'support',
          timestamp: DateTime.parse(chatResponse['timestamp']),
        );
        _messages.add(aiMessage);

        if (_sessionId == null) {
          _sessionId = chatResponse['sessionId'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('chatSessionId', _sessionId!);
        }
      } else {
        _error = 'Failed to send message';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
