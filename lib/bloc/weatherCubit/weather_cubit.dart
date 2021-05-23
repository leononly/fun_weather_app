import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:weather/services/helper.dart';

import '../../services/api.dart';
import '../../services/config.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherInitial());

  List<Map<dynamic, dynamic>> locations = [
    {
      "city": "Kuala Lumpur",
      "admin": "Kuala Lumpur ",
      "country": "Malaysia",
      "population_proper": "1448000",
      "iso2": "MY",
      "capital": "primary",
      "lat": "3.166667",
      "lng": "101.7",
      "population": "1448000",
    },
    {
      "city": "George Town",
      "admin": "Pulau Pinang",
      "country": "Malaysia",
      "population_proper": "720202",
      "iso2": "MY",
      "capital": "admin",
      "lat": "5.411229",
      "lng": "100.335426",
      "population": "2500000",
    },
    {
      "city": "Johor Bahru",
      "admin": "Johor",
      "country": "Malaysia",
      "population_proper": "802489",
      "iso2": "MY",
      "capital": "admin",
      "lat": "1.4655",
      "lng": "103.7578",
      "population": "875000",
    },
  ];

  List locationListToAdd;

  Map<String, dynamic> currentLocationData;
  int selectedIndex = 0;
  Map forecastDaySelected;
  LogsConfig config = FLog.getDefaultConfigurations();

  void appStart() async {
    var cache = await Helper.getFromCache();

    if (cache != null) {
      locations = [...cache['locationList']];

      locationListToAdd = [...cache['locationListToAdd']];
    } else {
      locationListToAdd = Config.allLocationList;
    }

    FLog.applyConfigurations(config);

    fetchLocation();
  }

  void fetchLocation() async {
    var locationData = locations[selectedIndex];
    try {
      emit(WeatherLoading());

      var response = await API().getWeather(locationData);

      var weatherData = await Helper.processDataHelper(response);

      if (locations[0]['currentLocationFlag'] != null) {
        locations.removeAt(0);
        selectedIndex -= 1;
      }

      locations[selectedIndex] = {
        ...locations[selectedIndex],
        'weatherData': weatherData
      };

      selectForecastDay(weatherData['weather'].keys.toList()[0]);

      emit(WeatherLoaded());
    } catch (error) {
      print(error.toString());
      if (error == 'NetworkError') {
        emit(WeatherNetworkError());
      } else {
        emit(WeatherError(error: error.toString()));
      }
    }
  }

  void fetchCurrentLocation() async {
    emit(WeatherLoading());

    currentLocationData = await Helper.fetchLocationService();
    if (currentLocationData['success']) {
      print(currentLocationData);
      var latitude = currentLocationData['data'].latitude;
      var longitude = currentLocationData['data'].longitude;

      var locationData = {
        'lat': latitude.toString(),
        'lng': longitude.toString()
      };
      try {
        var response = await API().getWeather(locationData);

        var weatherData = await Helper.processDataHelper(response);

        if (locations[0]['currentLocationFlag'] != null) {
          locations.removeAt(0);
        }
        locations.insert(0, {
          'city': 'Current Location',
          'admin': weatherData['city']['name'],
          'country': weatherData['city']['country'],
          'currentLocationFlag': true,
          'weatherData': weatherData
        });

        selectedIndex = 0;
        selectForecastDay(weatherData['weather'].keys.toList()[0]);

        emit(WeatherLoaded());
      } catch (error) {
        print(error.toString());

        if (error == 'NetworkError') {
          emit(WeatherNetworkError());
        } else {
          emit(WeatherError(error: error.toString()));
        }
      }
    } else {
      emit(WeatherLoading());
      emit(WeatherError(
          error: "Please enable Location Permission to get current location."));
    }
  }

  void selectForecastDay(String keyDate) async {
    emit(WeatherLoading());

    forecastDaySelected = {
      keyDate: locations[selectedIndex]['weatherData']['weather'][keyDate]
    };

    emit(WeatherLoaded());
  }

  void selectAndFetchWeather(int index) async {
    selectedIndex = index;

    Future.delayed(Duration(milliseconds: 300), () {
      fetchLocation();
    });
  }

  void addNewLocation(int index) async {
    var locationCopy = locationListToAdd[index];

    emit(WeatherLoading());

    locations.add(locationCopy);
    locationListToAdd.removeAt(index);

    Helper.persistData(locations, selectedIndex, locationListToAdd);

    emit(WeatherLoaded());
  }

  void refreshData() async {
    if (locations[0]['currentLocationFlag'] != null) {
      fetchCurrentLocation();
    } else {
      fetchLocation();
    }
  }
}
