import 'package:flutter/material.dart';
import 'package:safetrek_project/core/utils/emergency_utils.dart';
import 'emergency_dialog.dart';

class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  // Tránh spam nút
  bool _isProcessing = false;

  Future<void> _handleEmergency(BuildContext context) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Gọi logic chung từ EmergencyUtils
      final data = await EmergencyUtils.triggerEmergency(context);

      if (!mounted) return;

      // Hiển thị dialog (sử dụng context hiện tại vì đây là nút bấm bình thường)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EmergencyDialog(
            time: data.time,
            // location: data.location,
            battery: data.battery,
            isOverlay: false, // Dialog thường, không phải overlay
          );
        },
      );
    } catch (e) {
      debugPrint("Lỗi EmergencyButton: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleEmergency(context),
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
