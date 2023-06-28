import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/constants/strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => WeatherBloc(),
        child: WeatherPage(),
      ),
    );
  }
}

// Define the weather event
abstract class WeatherEvent {}

class FetchWeatherEvent extends WeatherEvent {
  final String cityName;

  FetchWeatherEvent({required this.cityName});
}

// Define the weather state
abstract class WeatherState {}

class WeatherInitialState extends WeatherState {}

class WeatherLoadingState extends WeatherState {}

class WeatherLoadedState extends WeatherState {
  final dynamic weatherData;

  WeatherLoadedState({required this.weatherData});
}

class WeatherErrorState extends WeatherState {
  final String errorMessage;

  WeatherErrorState({required this.errorMessage});
}

// Define the weather BLoC
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitialState()) {
    on<FetchWeatherEvent>((event, emit) => _fetchWeatherData(event, emit));
  }

  Future<dynamic> fetchWeatherData(String cityName) async {
    const apiUrl = 'api.openweathermap.org', endPoint = 'data/2.5/weather';

    final response = await http.get(Uri.https(apiUrl, endPoint, {
      'q': cityName,
      'appid': Strings.openWeatherApiKey,
      'units': 'metric'
    }));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<void> _fetchWeatherData(
      FetchWeatherEvent event, Emitter<WeatherState> emit) async {
    try {
      emit(WeatherLoadingState());
      final weatherData = await fetchWeatherData(event.cityName);
      emit(WeatherLoadedState(weatherData: weatherData));
    } catch (e) {
      emit(WeatherErrorState(errorMessage: 'Failed to fetch weather data'));
      debugPrint('error: $e');
    }
  }
}

class WeatherPage extends StatelessWidget {
  final TextEditingController _cityController = TextEditingController();

  WeatherPage({super.key});

  void _fetchWeather(BuildContext context) {
    final cityName = _cityController.text;
    BlocProvider.of<WeatherBloc>(context)
        .add(FetchWeatherEvent(cityName: cityName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City Name'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _fetchWeather(context),
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 16.0),
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                if (state is WeatherLoadingState) {
                  return const CircularProgressIndicator();
                } else if (state is WeatherLoadedState) {
                  final weatherData = state.weatherData;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temperature: ${weatherData['main']['temp']}'),
                      Text(
                          'Description: ${weatherData['weather'][0]['description']}'),
                      Text('Humidity: ${weatherData['main']['humidity']}'),
                      Text('Wind Speed: ${weatherData['wind']['speed']}'),
                    ],
                  );
                } else if (state is WeatherErrorState) {
                  return Text('Error: ${state.errorMessage}');
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
