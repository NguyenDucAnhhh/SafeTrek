import 'package:flutter/material.dart';
import 'guardians.dart';

class GuardianCard extends StatelessWidget {
  final Guardian guardian;
  final VoidCallback onRemove;

  const GuardianCard({
    super.key,
    required this.guardian,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAccepted = guardian.isAccepted;
    final Color cardColor = isAccepted ? const Color(0xFFE8F5E9) : Colors.white;
    final Color tagColor = isAccepted ? Colors.green : Colors.orange;
    final String tagText = isAccepted ? 'Chấp nhận' : 'Chờ';
    final IconData tagIcon = isAccepted ? Icons.check_circle : Icons.hourglass_empty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    guardian.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(tagIcon, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          tagText,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(guardian.phone),
            ],
          ),
          if (guardian.email != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(guardian.email!),
              ],
            ),
          ],
          if (!isAccepted) ...[
            const SizedBox(height: 8),
            const Text(
              'Đang chờ chấp nhận',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
          ]
        ],
      ),
    );
  }
}
