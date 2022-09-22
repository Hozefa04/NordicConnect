part of 'landing_bloc.dart';

abstract class LandingState extends Equatable {
  const LandingState();

  @override
  List<Object> get props => [];
}

class LandingInitial extends LandingState {
  const LandingInitial();
}

class LinkClickState extends LandingState {
  final DocumentSnapshot doc;
  const LinkClickState(this.doc);

  @override
  List<Object> get props => [doc];
}
