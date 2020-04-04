import 'package:equatable/equatable.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object> get props => [];
}

class InitialWeatherState extends WeatherState {
  @override
  String toString() => 'Weather app initiate';
}

class WeatherLoading extends WeatherState {
  @override
  String toString() => 'Weather is Loading';
}

class WeatherLoaded extends WeatherState {
  @override
  String toString() => 'Weather is Loaded';
}

class WeatherError extends WeatherState {
  WeatherError({this.error});

  final String error;

  @override
  String toString() => 'Weather is Error :$error';
}

class WeatherNetworkError extends WeatherState {
  @override
  String toString() => 'Caught Network Error.';
}
