import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/weather_event.dart';
import 'package:weather_app/bloc/weather_state.dart';
import 'package:weather_app/constants/strings.dart';
import 'package:weather_app/data/abstract_service/remote_data_service.dart';
import 'package:weather_app/data/api_service/api_service.dart';
import 'package:weather_app/data/models/weather_data_response_model.dart';
import 'package:weather_app/utils/utils.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final RemoteDataService _service = ApiService();

  WeatherBloc() : super(WeatherInitialState()) {
    on<FetchWeatherEvent>((event, emit) => _fetchWeatherData(event, emit));
  }

  Future<void> _fetchWeatherData(
      FetchWeatherEvent event, Emitter<WeatherState> emit) async {
    try {
      emit(WeatherLoadingState());
      final response = await _service.getWeatherData(event.location);
      if (response.statusCode == 200) {
        WeatherDataResponseModel weatherData =
            WeatherDataResponseModel.fromJson(jsonDecode(response.body));
        emit(WeatherLoadedState(weatherData: weatherData));
      } else if (response.statusCode == 404) {
        emit(WeatherErrorState(errorMessage: Strings.locationNotFound));
      } else if (response.statusCode == 429) {
        emit(WeatherErrorState(errorMessage: Strings.limitExceeded));
      } else if (isServerError(response.statusCode)) {
        emit(WeatherErrorState(errorMessage: Strings.serverError));
      } else {
        emit(WeatherErrorState(
            errorMessage:
                'Something went wrong status code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(WeatherErrorState(errorMessage: 'Failed to fetch weather data'));
      debugPrint('error: $e');
    }
  }
}
