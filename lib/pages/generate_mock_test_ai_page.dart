
import 'package:flutter/material.dart';

class GenerateMockTestAiPage extends StatelessWidget {
  const GenerateMockTestAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đề bằng AI'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.web, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Tính năng này hiện chỉ có trên phiên bản web.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Vui lòng truy cập trang web của chúng tôi để sử dụng các tính năng nâng cao như tạo đề thi tùy chỉnh và sử dụng AI.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
