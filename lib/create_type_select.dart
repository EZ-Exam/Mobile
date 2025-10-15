import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class CreateTypeSelect extends StatelessWidget {
  final Function(String) onSelect;

  const CreateTypeSelect({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.what_to_create,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildSelectCard(
                    context: context,
                    iconPath: 'assets/icons/person-question-mark.png',
                    label: t.question,
                    onTap: () => onSelect("question"),
                  ),
                  _buildSelectCard(
                    context: context,
                    iconPath: 'assets/icons/exam.png',
                    label: t.exam,
                    onTap: () => onSelect("exam"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectCard({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 64, height: 64),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
