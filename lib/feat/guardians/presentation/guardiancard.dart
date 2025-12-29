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
    // Xác định các thuộc tính hiển thị dựa trên status
    final bool isPending = guardian.status == 'Pending';
    final bool isAccepted = guardian.status == 'Accepted';
    
    Color cardBgColor = isAccepted ? const Color(0xFFF0FDF4) : Colors.white;
    Color borderColor = isAccepted ? const Color(0xFFBBF7D0) : Colors.grey.shade200;
    Color tagColor = isAccepted ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);
    String tagText = isAccepted ? 'Chấp nhận' : 'Chờ';
    IconData tagIcon = isAccepted ? Icons.check_circle : Icons.hourglass_empty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tên và Tag trạng thái
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        guardian.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tagIcon, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            tagText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Nút xóa
              InkWell(
                onTap: () => _showDeleteDialog(context),
                child: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Số điện thoại
          Row(
            children: [
              Icon(Icons.phone_android, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                guardian.phone,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Email
          if (guardian.email != null && guardian.email!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  guardian.email!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          // Dòng chữ đỏ khi đang chờ
          if (isPending) ...[
            const SizedBox(height: 8),
            const Text(
              'Đang chờ chấp nhận',
              style: TextStyle(
                color: Color(0xFFF87171),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Bạn có chắc chắn muốn xóa người bảo vệ ${guardian.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRemove();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
