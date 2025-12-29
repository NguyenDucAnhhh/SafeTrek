// import 'package:flutter/material.dart';
// import 'package:safetrek_project/core/widgets/secondary_header.dart';
// import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';
//
// class SettingProfile extends StatefulWidget {
//   const SettingProfile({super.key, required UserSetting userSetting});
//
//   @override
//   State<SettingProfile> createState() => _SettingProfileState();
// }
//
// class _SettingProfileState extends State<SettingProfile> {
//
//   InputDecoration _inputDecoration({required String hint, IconData? prefixIcon}) {
//     return InputDecoration(
//       hintText: hint,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: const Color(0xFF6A7282)) : null,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFDFE8F8)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFF3B82F6)),
//       ),
//       fillColor: Colors.white,
//       filled: true,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: SecondaryHeader(title: 'Thông tin cá nhân'),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment(-0.1, -0.5),
//             end: Alignment(1.0, 1.0),
//             colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
//           ),
//         ),
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//             children: [
//               Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 520),
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 6),
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.06),
//                           blurRadius: 18,
//                           spreadRadius: 2,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 46,
//                               height: 46,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFDBEAFE),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(Icons.person_outlined, color: Colors.blue, size: 26),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: const [
//                                   Text(
//                                     'Thông tin cá nhân',
//                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Cập nhật thông tin liên hệ',
//                                     style: TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 14),
//
//                         Form(
//                           child: Column(
//                             children: [
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Row(
//                                   children: const [
//                                     Icon(Icons.person_outline, size: 16, color: Colors.blue),
//                                     SizedBox(width: 8),
//                                     Text('Họ tên', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               TextFormField(
//                                 decoration: _inputDecoration(hint: 'Nguyễn Văn A', prefixIcon: null),
//                               ),
//                               const SizedBox(height: 12),
//
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Row(
//                                   children: const [
//                                     Icon(Icons.phone_outlined, size: 16, color: Colors.blue),
//                                     SizedBox(width: 8),
//                                     Text('Số điện thoại', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               TextFormField(
//                                 keyboardType: TextInputType.phone,
//                                 decoration: _inputDecoration(hint: '0912345678', prefixIcon: null),
//                               ),
//                               const SizedBox(height: 12),
//
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Row(
//                                   children: const [
//                                     Icon(Icons.email_outlined, size: 16, color: Colors.blue),
//                                     SizedBox(width: 8),
//                                     Text('Email', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               TextFormField(
//                                 keyboardType: TextInputType.emailAddress,
//                                 decoration: _inputDecoration(hint: 'example@gmail.com', prefixIcon: null),
//                               ),
//
//                               const SizedBox(height: 18),
//
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   onPressed: (){
//                                     Navigator.pop(context, true);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(vertical: 14),
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                     elevation: 0,
//                                     backgroundColor: Colors.transparent,
//                                     shadowColor: Colors.transparent,
//                                   ),
//                                   child: Ink(
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(colors: [Color(0xFF2F80ED), Color(0xFF2563EB)]),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       constraints: const BoxConstraints(minHeight: 44),
//                                       child: const Text(
//                                         'Lưu thông tin',
//                                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//     );
//   }
// }