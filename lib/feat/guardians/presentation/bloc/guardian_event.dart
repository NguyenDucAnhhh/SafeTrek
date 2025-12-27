import 'package:equatable/equatable.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';

abstract class GuardianEvent extends Equatable {
  const GuardianEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện yêu cầu tải danh sách người bảo vệ
class LoadGuardiansEvent extends GuardianEvent {}

/// Sự kiện thêm một người bảo vệ mới
class AddGuardianEvent extends GuardianEvent {
  final Guardian guardian;

  const AddGuardianEvent(this.guardian);

  @override
  List<Object?> get props => [guardian];
}

/// Sự kiện xóa một người bảo vệ
class RemoveGuardianEvent extends GuardianEvent {
  final String docId;

  const RemoveGuardianEvent(this.docId);

  @override
  List<Object?> get props => [docId];
}
