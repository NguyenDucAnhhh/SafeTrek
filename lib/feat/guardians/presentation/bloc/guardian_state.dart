import 'package:equatable/equatable.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';

abstract class GuardianState extends Equatable {
  const GuardianState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu khi chưa có dữ liệu và chưa làm gì
class GuardianInitial extends GuardianState {}

/// Trạng thái khi đang thực hiện một hành động (như đang tải danh sách)
class GuardianLoading extends GuardianState {}

/// Trạng thái khi đã lấy danh sách người bảo vệ thành công
class GuardianLoaded extends GuardianState {
  final List<Guardian> guardians;

  const GuardianLoaded(this.guardians);

  @override
  List<Object?> get props => [guardians];
}

/// Trạng thái khi có lỗi xảy ra (lỗi mạng, lỗi Firebase, v.v.)
class GuardianError extends GuardianState {
  final String message;

  const GuardianError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Trạng thái thông báo thêm người bảo vệ thành công (dùng để hiện SnackBar)
class GuardianAddedSuccess extends GuardianState {
  final String message;

  const GuardianAddedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
