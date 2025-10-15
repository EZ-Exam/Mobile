import 'package:flutter/material.dart';

class Recently extends StatelessWidget {
  Recently({super.key});

  final List<Map<String, dynamic>> groupData = [
    {
      'label': 'Hôm nay',
      'icon': Icons.picture_as_pdf,
    },
    {
      'label': 'Hôm qua',
      'icon': Icons.description,
    },
    {
      'label': 'Đầu tháng này',
      'icon': Icons.picture_as_pdf,
    },
    {
      'label': 'Tháng trước',
      'icon': Icons.description,
    },
    {
      'label': 'Đầu năm nay',
      'icon': Icons.picture_as_pdf,
    },
    {
      'label': 'Cũ hơn',
      'icon': Icons.description,
    },
  ];

  final String previewUrl = "https://i.imgur.com/0y8Ftya.png";

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupData.length,
      itemBuilder: (context, groupIndex) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label (e.g., "Today", "Yesterday")
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    groupData[groupIndex]['label'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider()),
                ],
              ),
            ),

            // Cards in a grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // TODO: Handle tap
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            previewUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(groupData[groupIndex]['icon'], size: 20),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  "KT 1 tiết 10a2",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // TODO: Show menu
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
