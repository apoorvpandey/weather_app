import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/constants/strings.dart';
import 'package:weather_app/data/abstract_service/remote_data_service.dart';
import 'package:weather_app/data/remote_urls/remote_urls.dart';

class ApiService extends RemoteDataService {
  @override
  Future<Response> getWeatherData(String location) async {
    final response = await http.get(Uri.https(
        RemoteUrls.apiUrl, RemoteUrls.endPoint, {
      'q': location,
      'appid': Strings.openWeatherApiKey,
      'units': 'metric'
    }));
    return response;
  }
}
