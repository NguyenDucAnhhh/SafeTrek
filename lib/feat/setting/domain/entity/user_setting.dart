import 'package:equatable/equatable.dart';

class UserSetting extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String safePIN;
  final String duressPIN;

  const UserSetting({
    required this.name,
    required this.email,
    required this.phone,
    required this.safePIN,
    required this.duressPIN,
  });

  UserSetting copyWith({
    String? name,
    String? email,
    String? phone,
    String? safePIN,
    String? duressPIN,
  }) {
    return UserSetting(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      safePIN: safePIN ?? this.safePIN,
      duressPIN: duressPIN ?? this.duressPIN,
    );
  }

  @override
  List<Object?> get props => [name, email, phone, safePIN, duressPIN];
}
