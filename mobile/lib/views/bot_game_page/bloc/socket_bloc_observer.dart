import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocketBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    debugPrint("SocketBlocObserver: ${bloc.runtimeType} is created");
    super.onCreate(bloc);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    debugPrint(
        "SocketBlocObserver: ${bloc.runtimeType} is emitting ${event.toString()}");
    super.onEvent(bloc, event);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint("SocketBlocObserver: ${bloc.runtimeType} has error $error");
    super.onError(bloc, error, stackTrace);
  }
}
