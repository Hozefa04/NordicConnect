part of 'landing_bloc.dart';

abstract class LandingEvent extends Equatable {
  const LandingEvent();

  @override
  List<Object> get props => [];
}

class LinkClickEvent extends LandingEvent {
  final DocumentSnapshot doc;

  const LinkClickEvent(this.doc);

  @override
  List<Object> get props => [doc];
}
