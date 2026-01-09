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

// Import quyen
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
    final formKey = GlobalKey<FormState>(); // Key để quản lý validation của Form

    // Hàm chọn người từ danh bạ
    Future<void> _pickContact() async {
      var status = await Permission.contacts.status;
      if (status.isDenied) {
        status = await Permission.contacts.request();
      }

      if (status.isGranted) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          nameController.text = contact.displayName;
          if (contact.phones.isNotEmpty) {
            phoneController.text = contact.phones.first.number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
          }
          if (contact.emails.isNotEmpty) {
            emailController.text = contact.emails.first.address;
          }
        }
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Text(
            'Thêm Người Bảo vệ',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey, // Gắn FormKey vào đây
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Row(children: <Widget>[
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("HOẶC")),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 15),

                  // TÊN
                  _buildLabel("Tên người bảo vệ", true),
                  TextFormField(
                    controller: nameController,
                    decoration: _buildInputDecoration('Ví dụ: Nguyễn Văn A'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 15),

                  // SỐ ĐIỆN THOẠI
                  _buildLabel("Số điện thoại", true),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('0912345678'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 15),

                  // EMAIL
                  _buildLabel("Email", true),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('email@example.com'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email không đúng định dạng';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Kiểm tra validation của Form
                    if (formKey.currentState!.validate()) {
                      final newGuardian = Guardian(
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                      );
                      context.read<GuardianBloc>().add(AddGuardianEvent(newGuardian));
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  // Hàm hỗ trợ tạo Label có dấu *
  Widget _buildLabel(String label, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          children: [
            TextSpan(text: '$label '),
            if (isRequired) const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ tạo Decoration cho TextField
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12), // Định dạng chữ báo lỗi
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuardianBloc, GuardianState>(
      listener: (context, state) {
        if (state is GuardianAddedSuccess) {
          showSuccessSnackBar(context, state.message);
        } else if (state is GuardianInviteReady) {
          Share.share(state.message, subject: 'Lời mời làm người bảo vệ SafeTrek');
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
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<GuardianBloc>().add(LoadGuardiansEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BlocBuilder<GuardianBloc, GuardianState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              _buildHeader(context),
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
                                    final guardian = state.guardians[index];
                                    return GuardianCard(
                                      guardian: guardian,
                                      onRemove: () {
                                        if (guardian.id != null) {
                                          context.read<GuardianBloc>().add(RemoveGuardianEvent(guardian.id!));
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Danh bạ Khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              Text('Quản lý người bảo vệ', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddGuardianDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 45,
          backgroundColor: Color(0xFFD6EAF8),
          child: Icon(Icons.groups_outlined, size: 50, color: Color(0xFF1877F2)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.lightbulb_outline, color: Colors.orange), SizedBox(width: 8), Text('Cách thức hoạt động', style: TextStyle(fontWeight: FontWeight.bold))]),
            SizedBox(height: 10),
            Text('• Thêm 3-5 người thân làm người bảo vệ'),
            Text('• Họ sẽ nhận được lời mời qua SMS/Email'),
            Text('• Sau khi chấp nhận, họ sẽ nhận cảnh báo khẩn cấp'),
          ],
        ),
      ),
    );
  }
}