class Guardian {
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final String status; // Thay đổi từ bool isAccepted sang String status

  Guardian({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.status = 'Pending', // Mặc định là Pending
  });
}
