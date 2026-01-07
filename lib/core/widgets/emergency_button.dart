import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EmergencyButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // Sử dụng callback được truyền vào
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE60000),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red,
              blurRadius: 5,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          children: const [
            Icon(Icons.warning_amber_rounded, size: 60, color: Colors.white),
            SizedBox(height: 10),
            Text(
              "NÚT KHẨN CẤP",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Bấm để gửi cảnh báo ngay lập tức",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
