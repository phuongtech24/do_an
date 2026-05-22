import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Chào Cáo Nhỏ. Hôm nay bạn cảm thấy thế nào? Hãy chia sẻ với mình nhé.',
      'time': '09:00 AM',
    },
    {
      'isUser': true,
      'text': 'Hôm nay mình cảm thấy hơi mệt mỏi và không muốn làm gì cả.',
      'time': '09:05 AM',
    },
    {
      'isUser': false,
      'text': 'Mình hiểu. Cảm giác mệt mỏi đôi khi ghé thăm là chuyện rất bình thường. Bạn có muốn thử nhắm mắt lại vài phút và hít thở sâu cùng mình không?',
      'time': '09:05 AM',
    },
  ];

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'isUser': true,
        'text': _textController.text,
        'time': 'Now',
      });
    });
    
    String userText = _textController.text;
    _textController.clear();

    // Mock AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': 'Mình đang lắng nghe bạn đây. Bạn có thể kể thêm về điều đó không?',
            'time': 'Now',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhật ký AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Xem biểu đồ tâm lý',
            onPressed: () {
              context.push('/chat/chart');
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.psychology, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: isUser ? Colors.white : AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Text('🦊', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Chat Input Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.primary),
                    onPressed: () {
                      // Mock Voice Recording
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đang thu âm... Hãy nói gì đó.')),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Nhắn gửi tâm sự...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
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
