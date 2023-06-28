import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPEN_WEATHER_KEY')
  static const String openWeatherKey = _Env.openWeatherKey;
}
