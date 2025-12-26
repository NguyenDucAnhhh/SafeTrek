class Guardian {
  final String name;
  final String phone;
  final String? email;
  final bool isAccepted;

  Guardian({required this.name, required this.phone, this.email, this.isAccepted = false});
}