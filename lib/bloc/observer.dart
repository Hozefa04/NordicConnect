import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class AppObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print('OnEvent Fired--> Started');
      print(bloc.state);
      print('OnEvent Fired--> Ended');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print('OnChange Fired--> Started');
      print(change);
      print('OnChange Fired--> Ended');
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print('onCreate Fired--> Started');
      print(bloc);
      print('onCreate Fired--> Ended');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print('OnTransition Fired--> Started');
      print(transition);
      print('OnTransition Fired--> Ended');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('OnError Fired--> Started');
      print(error);
      print('OnError Fired--> Ended');
    }
    super.onError(bloc, error, stackTrace);
  }
}
