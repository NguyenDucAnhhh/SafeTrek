import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_event.dart';
import 'trip_state.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository repository;

  TripBloc(this.repository) : super(TripInitial()) {
    on<LoadTripsEvent>((event, emit) async {
      emit(TripLoading());
      try {
        final trips = await repository.getTrips();
        emit(TripLoaded(trips));
      } catch (e) {
        emit(TripError('Không thể tải chuyến đi: ${e.toString()}'));
      }
    });

    on<AddTripEvent>((event, emit) async {
      try {
        final tripId = await repository.addTrip(event.trip);
        emit(TripAddedSuccess(message: 'Đã tạo chuyến đi', tripId: tripId));

      } catch (e) {
        emit(TripError('Lỗi khi thêm chuyến đi: ${e.toString()}'));
      }
    });
  }
}
