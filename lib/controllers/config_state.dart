import 'package:bloc/bloc.dart';

class UserConfigCache extends Cubit<int> {
  UserConfigCache() : super(1);

  void setState(int input) {
    emit(input);
  }
}
