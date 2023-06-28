import 'package:http/http.dart';

abstract class RemoteDataService {
  Future<Response> getWeatherData(String location);
}
