import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'home_box.dart';
import 'my_exam.dart';
import 'recently.dart';
import 'trash_can.dart';
import 'create_type_select.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _createType;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // Danh sách màn hình
    final List<Widget> screens = [
      const HomeBox(),
      CreateTypeSelect(
        onSelect: (type) {
          setState(() {
            _createType = type;
            // Bạn có thể chuyển sang trang tạo câu hỏi/đề tại đây nếu muốn
            // Navigator.push(...);
          });
        },
      ),
      MyExam(),
      Recently(),
      TrashCan(),
    ];

    // Danh sách tiêu đề
    final List<String> titles = [
      t.home,
      t.create_new,
      t.my_exam_title,
      t.recently,
      t.trash_can,
    ];

    void onItemTapped(int index) {
      if (index >= 0 && index < screens.length) {
        setState(() {
          _selectedIndex = index;
        });
      }
    }

    Widget buildPlaceholder(
        String title, IconData icon, String description, Widget child) {
      return Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 30,
                child: Icon(icon, size: 30, color: Colors.blue),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens.map((screen) {
          if (screen is MyExam) {
            return buildPlaceholder(
              t.my_exam_title,
              Icons.book,
              t.my_exam_description,
              screen,
            );
          }
          if (screen is Recently) {
            return buildPlaceholder(
              t.recently,
              Icons.history,
              t.recently_description,
              screen,
            );
          }
          if (screen is TrashCan) {
            return buildPlaceholder(
              t.trash_can,
              Icons.delete,
              t.trash_can_description,
              screen,
            );
          }
          if (screen is HomeBox) {
            return buildPlaceholder(
              t.home,
              Icons.home,
              "Welcome to EZEXAM!",
              screen,
            );
          }
          return screen;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(icon: const Icon(Icons.add), label: t.create_new),
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: t.my_exam),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: t.recently),
          BottomNavigationBarItem(icon: const Icon(Icons.delete), label: t.trash_can),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
