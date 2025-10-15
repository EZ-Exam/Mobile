import 'package:flutter/material.dart';

class MyExam extends StatelessWidget {
  MyExam({super.key});

  final List<String> samplePreviews = [
    "https://i.imgur.com/0y8Ftya.png",
    "https://i.imgur.com/0y8Ftya.png",
    "https://i.imgur.com/0y8Ftya.png",
    "https://i.imgur.com/0y8Ftya.png",
    "https://i.imgur.com/0y8Ftya.png",
    "https://i.imgur.com/0y8Ftya.png",
  ];

  final List<String> sampleTitles = [
    "Xác suất thống kê",
    "Giải tích 1",
    "Vật lý đại cương",
    "Hóa học cơ bản",
    "Lập trình Python",
    "Kinh tế lượng",
  ];

  final List<IconData> sampleIcons = [
    Icons.picture_as_pdf,
    Icons.description, // word
    Icons.picture_as_pdf,
    Icons.picture_as_pdf,
    Icons.description,
    Icons.picture_as_pdf,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: samplePreviews.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // mobile-friendly grid (2 columns)
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // TODO: handle card tap
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    samplePreviews[index],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(sampleIcons[index], size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sampleTitles[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // TODO: open menu
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
