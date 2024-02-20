import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// As of now this is involved in storing uid of the user only
class UserIdCubit extends Cubit<String> {
  UserIdCubit() : super("");

  void setUserId(String uid) {
    debugPrint("Uid cubit: $uid");
    emit(uid); // setting the state
  }

  String getUserId() => state; // getting the state
}
