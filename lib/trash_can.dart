import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class TrashCan extends StatelessWidget {
  const TrashCan({Key? key}) : super(key: key);

  // Danh sách file đã xóa (hiện đang để rỗng để hiển thị trạng thái empty)
  final List<Map<String, dynamic>> trashFiles = const [
    // {
    //   'title': 'File đã xóa 1',
    //   'icon': 'assets/icons/pdf-icon.png',
    //   'previewUrl': 'https://i.imgur.com/0y8Ftya.png',
    // },
    // {
    //   'title': 'File đã xóa 2',
    //   'icon': 'assets/icons/word-icon.png',
    //   'previewUrl': 'https://i.imgur.com/0y8Ftya.png',
    // },
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (trashFiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/empty_trash_icon.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                t.empty_trash_can,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.empty_trash_can_description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.trash_can),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: trashFiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final file = trashFiles[index];
            return TrashFileCard(
              title: file['title'],
              iconPath: file['icon'],
              previewUrl: file['previewUrl'],
              onTap: () {},
              onMenuTap: () {},
            );
          },
        ),
      ),
    );
  }
}

class TrashFileCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final String previewUrl;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const TrashFileCard({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.previewUrl,
    required this.onTap,
    required this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  previewUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
