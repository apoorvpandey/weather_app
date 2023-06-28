import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/bloc/weather_event.dart';
import 'package:weather_app/bloc/weather_state.dart';
import 'package:weather_app/utils/utils.dart';

class WeatherUI extends StatefulWidget {
  const WeatherUI({super.key});

  @override
  State<WeatherUI> createState() => _WeatherUIState();
}

class _WeatherUIState extends State<WeatherUI> {
  final TextEditingController _locationController = TextEditingController();
  final WeatherBloc _weatherBloc = WeatherBloc();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _locationController,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Please enter a location'),
                ]),
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_locationController.text.trim().isNotEmpty) {
                      _weatherBloc.add(FetchWeatherEvent(
                          location: _locationController.text.trim()));
                      unFocusKeyBoard();
                    }
                  }
                },
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 16.0),
              BlocBuilder<WeatherBloc, WeatherState>(
                bloc: _weatherBloc,
                builder: (context, state) {
                  if (state is WeatherLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is WeatherLoadedState) {
                    final weatherData = state.weatherData;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temperature: ${weatherData.main?.temp}'),
                        Text('Feels like: ${weatherData.main?.feelsLike}'),
                        Text('Low: ${weatherData.main?.tempMin}'),
                        Text('High: ${weatherData.main?.tempMax}'),
                        Text(
                            'Description: ${weatherData.weather?.first.description.toString().toNameFormat()}'),
                        Text('Humidity: ${weatherData.main?.humidity}'),
                        Text('Wind Speed: ${weatherData.wind?.speed}'),
                        const SizedBox(height: 8.0),
                        Image.network(
                            'https://openweathermap.org/img/wn/${weatherData.weather?.first.icon}@4x.png')
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
      ),
    );
  }
}
