import 'package:flutter/material.dart';
import 'package:safetrek_project/screens/guardians/guardiancard.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';
import 'package:safetrek_project/widgets/show_success_snack_bar.dart';

// Data model for a Guardian
class Guardian {
  final String name;
  final String phone;
  final String? email;
  final bool isAccepted;

  Guardian({required this.name, required this.phone, this.email, this.isAccepted = false});
}

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({super.key});

  @override
  State<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends State<GuardiansScreen> {
  int _selectedIndex = 1;
  final List<Guardian> _guardians = [
    Guardian(name: 'Nguyễn Đức Anh', phone: '0987654321', email: 'a@gmail.com', isAccepted: true),
    Guardian(name: 'Trần Thị B', phone: '0123456789', email: 'b@gmail.com', isAccepted: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here based on index
  }

  void _showAddGuardianDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Thêm Người Bảo vệ',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nhập thông tin người bạn muốn thêm làm người bảo vệ'),
                const SizedBox(height: 20),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Tên người bảo vệ '),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Nguyễn Văn A',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Số điện thoại '),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    hintText: '0912345678',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                const Text('Email (Tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'email@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                      setState(() {
                        _guardians.add(Guardian(
                          name: nameController.text,
                          phone: phoneController.text,
                          email: emailController.text.isNotEmpty ? emailController.text : null,
                        ));
                      });

                      showSuccessSnackBar(context, 'Thêm người bảo vệ thành công !');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  void _removeGuardian(int index) {
    setState(() {
      _guardians.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.00, 0.30),
            end: const Alignment(1.00, 0.70),
            colors: [const Color(0xFFEFF6FF), const Color(0xFFE0E7FF)],
          ),
        ),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Danh bạ Khẩn cấp',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Quản lý người bảo vệ (${_guardians.length}/5)'),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddGuardianDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _guardians.isEmpty
                          ? Column(
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xFFD6EAF8),
                            child: Icon(
                              Icons.groups_outlined,
                              size: 50,
                              color: const Color(0xFF1877F2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Chưa có người bảo vệ nào'),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _showAddGuardianDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm Người Bảo vệ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _guardians.length,
                        itemBuilder: (context, index) {
                          return GuardianCard(
                            guardian: _guardians[index],
                            onRemove: () => _removeGuardian(index),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Cách thức hoạt động',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('• Thêm 3-5 người thân làm người bảo vệ'),
                      SizedBox(height: 5),
                      Text('• Họ sẽ nhận được lời mời qua SMS/Email'),
                      SizedBox(height: 5),
                      Text('• Sau khi chấp nhận, họ sẽ nhận cảnh báo khẩn cấp'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
