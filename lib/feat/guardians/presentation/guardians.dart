import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:share_plus/share_plus.dart';

// Import các lớp Clean Architecture
import 'package:safetrek_project/feat/guardians/data/data_source/guardian_remote_data_source.dart';
import 'package:safetrek_project/feat/guardians/data/repository/guardian_repository_impl.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';

// Import BLoC
import 'package:safetrek_project/feat/guardians/presentation/bloc/guardian_bloc.dart';
import 'package:safetrek_project/feat/guardians/presentation/bloc/guardian_event.dart';
import 'package:safetrek_project/feat/guardians/presentation/bloc/guardian_state.dart';

// Import Widgets
import 'package:safetrek_project/core/widgets/show_success_snack_bar.dart';
import 'guardiancard.dart';

//Import quyen
import 'package:permission_handler/permission_handler.dart';

class GuardiansScreen extends StatelessWidget {
  const GuardiansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GuardianBloc(
        GuardianRepositoryImpl(
          GuardianRemoteDataSource(FirebaseFirestore.instance),
        ),
      )..add(LoadGuardiansEvent()),
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

    // Hàm chọn người từ danh bạ
    Future<void> _pickContact() async {
      // Kiểm tra trạng thái thực tế từ hệ điều hành
      var status = await Permission.contacts.status;
      print("Trạng thái thực tế: $status");

      if (status.isDenied) {
        // Nếu bị từ chối, hãy xin lại một lần nữa bằng permission_handler
        status = await Permission.contacts.request();
      }

      if (status.isGranted) {
        final contact = await FlutterContacts.openExternalPick();

        if (contact != null) {
          nameController.text = contact.displayName;
          if (contact.phones.isNotEmpty) {
            // Lấy SĐT đầu tiên và xóa các ký tự thừa
            phoneController.text = contact.phones.first.number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
          }
          if (contact.emails.isNotEmpty) {
            emailController.text = contact.emails.first.address;
          }
        }
      } else if (status.isPermanentlyDenied) {
        // Nếu bị từ chối vĩnh viễn (do bấm "Don't ask again")
        print("Bị từ chối vĩnh viễn, mở cài đặt...");
        openAppSettings();
      }
    }

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
                const Text('Chọn từ danh bạ hoặc nhập thông tin thủ công.'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickContact,
                    icon: const Icon(Icons.contact_phone, size: 18),
                    label: const Text('Chọn từ Danh bạ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("HOẶC"),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 15),
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
                // SỬA GIAO DIỆN: Đánh dấu Email là trường bắt buộc
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Email '),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // SỬA LOGIC: Thêm kiểm tra email và thông báo lỗi
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        emailController.text.isNotEmpty) {
                      // Kiểm tra định dạng email cơ bản
                      if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập một địa chỉ email hợp lệ.')),
                        );
                        return; // Dừng lại nếu email không hợp lệ
                      }

                      final newGuardian = Guardian(
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                      );
                      context.read<GuardianBloc>().add(AddGuardianEvent(newGuardian));
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng điền đầy đủ các trường bắt buộc (*).')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
        }

        // THÊM ĐOẠN NÀY: Khi BLoC báo đã sẵn sàng gửi lời mời
        else if (state is GuardianInviteReady) {
          // Mở bảng chia sẻ của điện thoại
          Share.share(
              state.message,
              subject: 'Lời mời làm người bảo vệ SafeTrek'
          );
        }

        else if (state is GuardianError) {
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
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<GuardianBloc>().add(LoadGuardiansEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                                  Expanded( // SỬA TẠI ĐÂY: Thêm Expanded để tiêu đề không chiếm hết chỗ
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Danh bạ Khẩn cấp',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Quản lý người bảo vệ',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddGuardianDialog(context),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Thêm'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1877F2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                        if (state.guardians[index].id != null) {
                                          context.read<GuardianBloc>().add(
                                            RemoveGuardianEvent(state.guardians[index].id!), // Truyền id thật
                                          );
                                        } else {
                                          // Nếu id null (do chưa load kịp), báo lỗi
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Không tìm thấy ID để xóa")),
                                          );
                                        }
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
