import 'package:bloc/bloc.dart';

class UserConfigCache extends Cubit<Map<String, dynamic>> {
  UserConfigCache()
      : super({"topics": [], "numberAnswers": 3, "difficulty": []});

  void update(String key, dynamic value) {
    state[key] = value;
    emit(state);
  }

  void add(Map<String, dynamic> pair) {
    state.addAll(pair);
    emit(state);
  }

  void remove(String key) {
    state.remove(key);
    emit(state);
  }
}
