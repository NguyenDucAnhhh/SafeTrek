import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';

class GuardianModel extends Guardian {
  final DocumentReference? userReference;

  GuardianModel({
    super.id,
    required super.name,
    required super.phone,
    super.email,
    required super.status,
    this.userReference,
  });

  factory GuardianModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuardianModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      status: data['status'] ?? 'Pending',
      userReference: data['userID'] is DocumentReference 
          ? data['userID'] as DocumentReference 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'userID': userReference,
    };
  }
}
