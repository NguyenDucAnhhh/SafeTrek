import 'package:flutter/material.dart';

class EmergencyDialog extends StatelessWidget {
  final VoidCallback? onDismiss;
  final String? time;
  final String? location;
  final String? battery;

  // Add a boolean parameter to indicate if it's shown as an overlay
  final bool isOverlay;

  const EmergencyDialog({
    super.key,
    this.onDismiss,
    this.time,
    this.location,
    this.battery,
    this.isOverlay = false, // Default is false (standard dialog)
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: const Color(0xFFD32F2F), // A deep red color
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "CẢNH BÁO KHẨN CẤP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  onDismiss?.call();
                  // Only pop if NOT an overlay (or handle it differently)
                  if (!isOverlay) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Nút hoảng loạn đã được kích hoạt!\n\nCảnh báo đã được gửi đến người bảo vệ.\n\nThời gian: ${time ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Vị trí cuối cùng:",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location ?? 'Không xác định',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.battery_full, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "Mức pin: ${battery ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  onDismiss?.call();
                  if (!isOverlay) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Xem Vị trí"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  onDismiss?.call();
                  if (!isOverlay) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
