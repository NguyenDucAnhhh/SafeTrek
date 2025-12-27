class Guardian {
  final String? id; // Đây là ID từ Firestore
  final String name;
  final String phone;
  final String? email;
  final bool isAccepted;

  Guardian({
    this.id, 
    required this.name, 
    required this.phone, 
    this.email, 
    this.isAccepted = false
  });
}
