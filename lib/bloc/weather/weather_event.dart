import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class AppStart extends WeatherEvent {
  @override
  String toString() {
    return 'App Start';
  }
}

class RefreshData extends WeatherEvent {
  @override
  String toString() {
    return 'Refresh Weather Data';
  }
}

class FetchLocation extends WeatherEvent {
  @override
  String toString() {
    return 'Fetching Location';
  }
}

class FetchCurrentLocation extends WeatherEvent {
  @override
  String toString() {
    return 'Fetching Current Location';
  }
}

class AddNewLocation extends WeatherEvent {
  int index;
  AddNewLocation({this.index});
  @override
  String toString() {
    return 'Adding Location';
  }
}

class SelectAndFetchWeather extends WeatherEvent {
  final int index;
  SelectAndFetchWeather({this.index});
  @override
  String toString() {
    return 'Select and Fetch Location';
  }
}

class SelectForecastDay extends WeatherEvent {
  final String keyDate;
  SelectForecastDay({this.keyDate});
  @override
  String toString() {
    return 'Select Forecast Day';
  }
}
