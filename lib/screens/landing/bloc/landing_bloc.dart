import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'landing_event.dart';
part 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  LandingBloc() : super(const LandingInitial()) {
    on<LandingEvent>((event, emit) {
      if (event is LinkClickEvent) {
        emit(LinkClickState(event.doc));
      }
    });
  }
}
