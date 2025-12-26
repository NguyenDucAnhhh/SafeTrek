import 'package:flutter/material.dart';
import '../domain/entity/Guardian.dart';

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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        guardian.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
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
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {
                  buildShowDialog(context);
                },
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

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFEF2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Color(0xFFFCA5A5)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text(
                'Xác nhận xóa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text('Bạn có chắc chắn muốn xóa bảo vệ ${guardian.name}?'),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
              ),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                onRemove(); // Call the original remove function
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }
}
