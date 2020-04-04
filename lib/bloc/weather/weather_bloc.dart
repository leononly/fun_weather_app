import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/bloc/weather/constants.dart';
import 'package:weather/services/api.dart';
import 'package:weather_icons/weather_icons.dart';

import './bloc.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  @override
  WeatherState get initialState => InitialWeatherState();

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

  @override
  Stream<WeatherState> mapEventToState(
    WeatherEvent event,
  ) async* {
    if (event is AppStart) {
      var cache = await getFromCache();

      if (cache != null) {
        locations = [...cache['locationList']];

        locationListToAdd = [...cache['locationListToAdd']];
      } else {
        locationListToAdd = Constants.allLocationList;
      }

      add(FetchLocation());
    }
    if (event is FetchCurrentLocation) {
      currentLocationData = await fetchLocation();
      if (currentLocationData['success']) {
        print(currentLocationData);
        var latitude = currentLocationData['data'].latitude;
        var longitude = currentLocationData['data'].longitude;

        var locationData = {
          'lat': latitude.toString(),
          'lng': longitude.toString()
        };
        try {
          yield WeatherLoading();
          var response = await API().getWeather(locationData);

          var weatherData = await processDataHelper(response);

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
//        print(locations[selectedIndex]);
          add(SelectForecastDay(
              keyDate: weatherData['weather'].keys.toList()[0]));
          yield WeatherLoaded();
        } catch (error) {
          print(error.toString());

          if (error == 'NetworkError') {
            yield WeatherNetworkError();
          } else {
            yield WeatherError(error: error.toString());
          }
        }
      } else {
        yield InitialWeatherState();
        yield WeatherError(
            error:
                "Please enable Location Permission to get current location.");
      }
    }

    if (event is FetchLocation) {
      var locationData = locations[selectedIndex];
      try {
        yield WeatherLoading();
        var response = await API().getWeather(locationData);

        var weatherData = await processDataHelper(response);

        if (locations[0]['currentLocationFlag'] != null) {
          locations.removeAt(0);
          selectedIndex -= 1;
        }

        locations[selectedIndex] = {
          ...locations[selectedIndex],
          'weatherData': weatherData
        };

//        print(locations[selectedIndex]);
        add(SelectForecastDay(
            keyDate: weatherData['weather'].keys.toList()[0]));
        yield WeatherLoaded();
      } catch (error) {
        print(error.toString());
        if (error == 'NetworkError') {
          yield WeatherNetworkError();
        } else {
          yield WeatherError(error: error.toString());
        }
      }
    }

    if (event is SelectAndFetchWeather) {
      int index = event.index;

      selectedIndex = index;

      add(FetchLocation());
    }

    if (event is SelectForecastDay) {
      String keyDate = event.keyDate;

      yield InitialWeatherState();

      forecastDaySelected = {
        keyDate: locations[selectedIndex]['weatherData']['weather'][keyDate]
      };

      yield WeatherLoaded();
    }

    if (event is AddNewLocation) {
      int index = event.index;
      var locationCopy = locationListToAdd[index];

      yield InitialWeatherState();

      locations.add(locationCopy);
      locationListToAdd.removeAt(index);

      persistData();

      yield WeatherLoaded();
    }

    if (event is RefreshData) {
      if (locations[0]['currentLocationFlag'] != null) {
        add(FetchCurrentLocation());
      } else {
        add(FetchLocation());
      }
    }
  }

  persistData() async {
    // persist locations data into local storage/ cache

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> storeLocationList =
        prefs.setString("locationList", json.encode(locations));

    Future<bool> storeLocationListToAdd =
        prefs.setString('locationListToAdd', json.encode(locationListToAdd));

    return;
  }

  getFromCache() async {
    // get cache
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String locationListString = prefs.getString("locationList");
    String locationListToAddString = prefs.getString("locationListToAdd");

    if (locationListString != null && locationListToAddString != null) {
      return {
        'locationList': json.decode(locationListString),
        'locationListToAdd': json.decode(locationListToAddString)
      };
    } else {
      return null;
    }
  }

  fetchLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return {
          'success': false,
        };
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied ||
        _permissionGranted == PermissionStatus.deniedForever) {
      // might come to this later since the permission plugin got bug on requestPermission()
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return {'success': false};
      }
    }
    try {
      var _locationData = await location.getLocation();
      print(_locationData.latitude);

      return {'success': true, 'data': _locationData};
    } catch (err) {
      print(err);

      return {'success': false};
    }
  }

  processDataHelper(inputData) async {
    Map<String, dynamic> finalData;
    DateTime datetime;
    List list = inputData['list'];

    for (var i = 0; i < list.length; i++) {
      if (datetime == null) {
        DateTime tempDate = DateTime.parse(list[i]['dt_txt']);
        if (!isYesterdayCheckHelper(
            DateTime(tempDate.year, tempDate.month, tempDate.day))) {
          // to avoid yesterday result

          datetime = DateTime.parse(list[i]['dt_txt']);

          var date = DateFormat('dd-MM-yyyy')
              .format(datetime); // shows the date : day / month / year

          var time = DateFormat('j').format(datetime); // shows time : ?? PM/AM
          finalData = {
            date: {
              'day': todayOrTomorrowHelper(list[i]['dt_txt']),
              'weatherList': [
                {
                  'weather': list[i]['weather'][0],
                  'celcius':
                      convertKelvinToCelciusHelper(list[i]['main']['temp']),
                  'time': time
                }
              ]
            }
          };
        }
      } else {
        var newDateTime = DateTime.parse(list[i]['dt_txt']);
        var newDate = DateFormat('dd-MM-yyyy').format(newDateTime);

        var newTime =
            DateFormat('j').format(newDateTime); // shows time : ?? PM/AM

        if (finalData[newDate] != null) {
          finalData[newDate]['weatherList'].add({
            'weather': list[i]['weather'][0],
            'celcius': convertKelvinToCelciusHelper(list[i]['main']['temp']),
            'time': newTime
          });
        } else {
          finalData[newDate] = {
            'day': todayOrTomorrowHelper(list[i]['dt_txt']),
            'weatherList': [
              {
                'weather': list[i]['weather'][0],
                'celcius':
                    convertKelvinToCelciusHelper(list[i]['main']['temp']),
                'time': newTime
              }
            ]
          };
        }
      }
    }

    return {'city': inputData['city'], 'weather': finalData};
  }

  bool isYesterdayCheckHelper(DateTime date) {
    // to check if is yesterday
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);

    if (date.isBefore(today)) {
      return true;
    } else {
      return false;
    }
  }

  double convertKelvinToCelciusHelper(kelvinInput) {
    //formula for convert kelvin to celcius
    return kelvinInput - 273.15;
  }

  String todayOrTomorrowHelper(date) {
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var tomorrow = DateTime(now.year, now.month, now.day + 1);

    var dateToCompareParse = DateTime.parse(date);
    var dateToCompare = DateTime(dateToCompareParse.year,
        dateToCompareParse.month, dateToCompareParse.day);

    if (dateToCompare == today) {
      return 'Today';
    } else if (dateToCompare == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yy').format(dateToCompare);
    }
  }

  Map identifyWeatherIcon(String iconId) {
//    var identifier = id.substring(0, 1);

    switch (iconId) {
      case '01d':
        {
          return {
            'icon': WeatherIcons.day_sunny,
            'color': Colors.yellow,
          };
        }
        break;
      case '01n':
        {
          return {
            'icon': WeatherIcons.night_clear,
            'color': Colors.white,
          };
        }
        break;
      case '02d':
        {
          return {
            'icon': WeatherIcons.day_cloudy,
            'color': Colors.yellow,
          };
        }
        break;
      case '02n':
        {
          return {
            'icon': WeatherIcons.night_cloudy,
            'color': Colors.white,
          };
        }
        break;

      case '04d':
      case '04n':
      case '03d':
      case '03n':
        {
          return {
            'icon': WeatherIcons.cloud,
            'color': Colors.white,
          };
        }
        break;

      case '09d':
      case '09n':
        {
          return {
            'icon': WeatherIcons.showers,
            'color': Colors.white,
          };
        }
        break;
      case '10d':
        {
          return {
            'icon': WeatherIcons.day_rain,
            'color': Colors.yellow,
          };
        }
        break;
      case '10n':
        {
          return {
            'icon': WeatherIcons.night_rain,
            'color': Colors.white,
          };
        }
        break;
      case '11d':
        {
          return {
            'icon': WeatherIcons.day_thunderstorm,
            'color': Colors.yellow,
          };
        }
        break;
      case '11n':
        {
          return {
            'icon': WeatherIcons.night_thunderstorm,
            'color': Colors.yellow,
          };
        }
        break;

      default:
        {
          return {
            'icon': WeatherIcons.cloud,
            'color': Colors.white,
          };
        }
        break;
    }
  }
}
