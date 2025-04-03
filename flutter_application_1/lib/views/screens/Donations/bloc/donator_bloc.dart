import 'package:flutter_bloc/flutter_bloc.dart';
import 'donator_event.dart';
import 'donator_state.dart';

class DonatorBloc extends Bloc<DonatorEvent, DonatorState> {
  DonatorBloc() : super(DonatorInitial()) {
    on<AddDonator>((event, emit) async {
      emit(DonatorLoading());
      try {
        // TODO: Implement API call to add donator
        await Future.delayed(const Duration(seconds: 1));
        emit(DonatorSuccess());
      } catch (e) {
        emit(DonatorError(e.toString()));
      }
    });
  }
}
