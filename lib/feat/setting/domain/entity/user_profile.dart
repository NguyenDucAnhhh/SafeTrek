import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String safePIN;
  final String duressPIN;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.safePIN,
    required this.duressPIN,
  });

  @override
  List<Object?> get props => [name, email, phone, safePIN, duressPIN];
}
