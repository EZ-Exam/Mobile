import 'package:flutter/material.dart';

class HomeBox extends StatelessWidget {
  const HomeBox({super.key});

  final List<Map<String, dynamic>> filterButtons = const [
    {'label': 'Type', 'icon': Icons.filter_list},
    {'label': 'Person', 'icon': Icons.person},
    {'label': 'Last Modified', 'icon': Icons.calendar_today},
    {'label': 'Location', 'icon': Icons.location_on},
  ];

  final List<Map<String, String>> suggestedExams = const [
    {'name': 'The Exam', 'reason': 'You have upload', 'location': 'My Exam'},
    {'name': 'The Exam', 'reason': 'You have opened often', 'location': 'Shared with me'},
    {'name': 'The Exam', 'reason': 'You opened', 'location': 'John'},
    {'name': 'The Exam', 'reason': "Don't opened", 'location': 'Relavant'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Card(
          color: const Color(0xffe0e7ff), // blue-50 to indigo-50 equivalent
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                Text(
                  'Welcome to PhyGen',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Your intelligent exam management platform',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Search & Filters
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search for exams, questions, or topics...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      onPressed: () {},
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: filterButtons
                      .map((btn) => OutlinedButton.icon(
                    icon: Icon(btn['icon'] as IconData),
                    label: Text(btn['label']),
                    onPressed: () {},
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Suggested Questions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggested Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xffdbeafe), // blue-100
                              child: Icon(Icons.help, color: Colors.blue),
                            ),
                            SizedBox(height: 10),
                            Text('The Question', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(
                              'On shared with me',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Suggested Exams
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggested Exams',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Column(
                  children: suggestedExams.map((exam) {
                    IconData? locationIcon;
                    Color iconColor = Colors.blue;

                    if (exam['location'] == 'My Exam') {
                      locationIcon = Icons.description;
                      iconColor = Colors.blue;
                    } else if (exam['location'] == 'Shared with me') {
                      locationIcon = Icons.share;
                      iconColor = Colors.green;
                    } else {
                      locationIcon = Icons.person;
                      iconColor = Colors.purple;
                    }

                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                      title: Text(exam['name']!),
                      subtitle: Text(exam['reason']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(locationIcon, color: iconColor, size: 20),
                          const SizedBox(width: 4),
                          Text(exam['location']!, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
