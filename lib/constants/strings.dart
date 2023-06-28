import 'package:weather_app/environment/env.dart';

class Strings {
  static String openWeatherApiKey = Env.openWeatherKey;
  static String locationNotFound = 'Location not found';
  static String limitExceeded = 'Limits exceeded: 60 API calls per minute';
  static String serverError = 'Server Error';
}
