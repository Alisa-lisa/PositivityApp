// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'AUTH')
  static const String auth = _Env.auth;
  @EnviedField(varName: 'BASE_URL')
  static const String base_url = _Env.base_url;
}
