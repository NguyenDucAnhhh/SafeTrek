import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../core/widgets/show_success_snack_bar.dart';
import '../../home/presentation/bloc/guardian_bloc.dart';
import '../../home/presentation/bloc/guardian_event.dart';
import '../../home/presentation/bloc/guardian_state.dart';
import '../domain/entity/Guardian.dart';
import 'guardiancard.dart';

class GuardiansScreen extends StatelessWidget {
  const GuardiansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo và cung cấp Bloc cho màn hình này
    return BlocProvider(
      create: (context) => GuardianBloc()..add(LoadGuardiansEvent()),
      child: const GuardiansView(),
    );
  }
}

class GuardiansView extends StatelessWidget {
  const GuardiansView({super.key});

  void _showAddGuardianDialog(BuildContext context) {
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
                    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                      final newGuardian = Guardian(
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text.isNotEmpty ? emailController.text : null,
                      );

                      // Gửi sự kiện Add vào Bloc
                      context.read<GuardianBloc>().add(AddGuardianEvent(newGuardian));

                      Navigator.of(dialogContext).pop();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuardianBloc, GuardianState>(
      listener: (context, state) {
        if (state is GuardianAddedSuccess) {
          showSuccessSnackBar(context, state.message);
        } else if (state is GuardianError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.00, 0.30),
              end: Alignment(1.00, 0.70),
              colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
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
                    child: BlocBuilder<GuardianBloc, GuardianState>(
                      builder: (context, state) {
                        int count = 0;
                        if (state is GuardianLoaded) {
                          count = state.guardians.length;
                        }

                        return Column(
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
                                    Text('Quản lý người bảo vệ ($count/5)'),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddGuardianDialog(context),
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
                            if (state is GuardianLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (state is GuardianLoaded)
                              state.guardians.isEmpty
                                  ? _buildEmptyState(context)
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: state.guardians.length,
                                      itemBuilder: (context, index) {
                                        return GuardianCard(
                                          guardian: state.guardians[index],
                                          onRemove: () {
                                            context.read<GuardianBloc>().add(
                                                  RemoveGuardianEvent(state.guardians[index].phone),
                                                );
                                          },
                                        );
                                      },
                                    )
                            else if (state is GuardianError)
                              Text(state.message, style: const TextStyle(color: Colors.red))
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildHowItWorksCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 45,
          backgroundColor: Color(0xFFD6EAF8),
          child: Icon(
            Icons.groups_outlined,
            size: 50,
            color: Color(0xFF1877F2),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Chưa có người bảo vệ nào'),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showAddGuardianDialog(context),
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
      ],
    );
  }

  Widget _buildHowItWorksCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
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
    );
  }
}
