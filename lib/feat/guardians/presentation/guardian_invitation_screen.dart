import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/home/presentation/main_screen.dart';

class GuardianInvitationScreen extends StatefulWidget {
  final String guardianId;

  const GuardianInvitationScreen({
    super.key,
    required this.guardianId,
  });

  @override
  State<GuardianInvitationScreen> createState() =>
      _GuardianInvitationScreenState();
}

class _GuardianInvitationScreenState extends State<GuardianInvitationScreen> {
  late Future<Map<String, dynamic>?> _guardianData;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _guardianData = _fetchGuardianData();
  }

  Future<Map<String, dynamic>?> _fetchGuardianData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('guardians')
          .doc(widget.guardianId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return {
        'id': doc.id,
        'name': doc.data()?['name'] ?? 'Người bảo vệ',
        'phone': doc.data()?['phone'],
        'email': doc.data()?['email'],
        'status': doc.data()?['status'],
        'userID': doc.data()?['userID'],
      };
    } catch (e) {
      print('Lỗi lấy dữ liệu: $e');
      return null;
    }
  }

  Future<void> _acceptInvitation() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập trước'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isAccepting = true);

      // Cập nhật status guardian từ Pending → Accepted
      await FirebaseFirestore.instance
          .collection('guardians')
          .doc(widget.guardianId)
          .update({'status': 'Accepted'});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã trở thành người bảo vệ!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate về MainScreen sau 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      });
    } catch (e) {
      setState(() => _isAccepting = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F4FF), Color(0xFFE2E9FF)],
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _guardianData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      'Không tìm thấy lời mời',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Lời mời có thể đã hết hạn hoặc không hợp lệ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Quay lại',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade100,
                      ),
                      child: const Icon(Icons.person_add,
                          size: 60, color: Colors.blue),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Lời mời làm người bảo vệ',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 15),
                          _buildInfoRow('Tên:', data['name'] ?? 'N/A'),
                          const SizedBox(height: 10),
                          _buildInfoRow('Số điện thoại:', data['phone'] ?? 'N/A'),
                          const SizedBox(height: 10),
                          _buildInfoRow('Email:', data['email'] ?? 'N/A'),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            'Trạng thái:',
                            data['status'] ?? 'N/A',
                            statusColor:
                                data['status'] == 'Pending'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Bạn có chấp nhận trở thành người bảo vệ cho họ không?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Từ chối',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isAccepting ? null : _acceptInvitation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isAccepting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Chấp nhận',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: statusColor,
                fontWeight:
                    statusColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
