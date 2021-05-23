part of 'weather_cubit.dart';

abstract class WeatherState extends Equatable {
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {
  @override
  String toString() {
    // TODO: implement toString
    return "Weather initiate";
  }
}

class WeatherLoading extends WeatherState {
  @override
  String toString() {
    // TODO: implement toString
    return "Weather Loading";
  }
}

class WeatherLoaded extends WeatherState {
  @override
  String toString() {
    // TODO: implement toString
    return "Weather Loaded";
  }
}

class WeatherNetworkError extends WeatherState {
  @override
  String toString() {
    // TODO: implement toString
    return "Weather Network Error";
  }
}

class WeatherError extends WeatherState {
  final String error;
  WeatherError({this.error});
  @override
  String toString() {
    // TODO: implement toString
    return "Weather Network Error: $error";
  }
}
