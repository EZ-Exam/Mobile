
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../utils/subscription_utils.dart';

class SupportChat extends StatefulWidget {
  final Map<String, dynamic>? user;

  const SupportChat({super.key, this.user});

  @override
  State<SupportChat> createState() => _SupportChatState();
}

class _SupportChatState extends State<SupportChat> {
  bool _isOpen = false;
  bool _isMinimized = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              if (!_isOpen)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () => setState(() => _isOpen = true),
                    child: const Icon(Icons.message),
                  ),
                ),
              if (_isOpen)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 400,
                      height: _isMinimized ? 60 : 500,
                      child: Column(
                        children: [
                          _buildChatHeader(provider),
                          if (!_isMinimized)
                            Expanded(
                              child: _buildChatContent(provider),
                            ),
                          if (!_isMinimized)
                            _buildMessageInput(provider),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatHeader(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            child: Icon(Icons.support_agent),
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Assistant',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_isMinimized ? Icons.unfold_more : Icons.unfold_less),
            color: Colors.white,
            onPressed: () => setState(() => _isMinimized = !_isMinimized),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () => setState(() => _isOpen = false),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent(ChatProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        final isUser = message.sender == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.deepPurple[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.text),
                const SizedBox(height: 4),
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ChatProvider provider) {
    final isFree = SubscriptionUtils.isFreeUser(widget.user);
    final messageCount = provider.messages.where((m) => m.sender == 'user').length;
    final hasReachedLimit = isFree && messageCount >= 5;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (hasReachedLimit)
            const Text(
              'Bạn đã dùng hết 5 tin nhắn của gói FREE. Nâng cấp để tiếp tục chat không giới hạn.',
              style: TextStyle(color: Colors.red),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: !hasReachedLimit,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: hasReachedLimit
                    ? null
                    : () {
                        final text = _messageController.text.trim();
                        if (text.isNotEmpty) {
                          provider.sendMessage(text, user: widget.user);
                          _messageController.clear();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
