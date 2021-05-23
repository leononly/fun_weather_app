import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class Helper {
  static persistData(List<Map<dynamic, dynamic>> locations, int selectedIndex,
      List locationListToAdd) async {
    // persist locations data into local storage/ cache

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var locationCopy = [...locations];

    if (locations[selectedIndex]['currentLocationFlag'] != null)
      locationCopy.removeAt(0);

    prefs.setString("locationList", json.encode(locationCopy));

    prefs.setString('locationListToAdd', json.encode(locationListToAdd));

    return;
  }

  static getFromCache() async {
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

  static fetchLocationService() async {
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

  static processDataHelper(inputData) async {
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

  static bool isYesterdayCheckHelper(DateTime date) {
    // to check if is yesterday
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);

    if (date.isBefore(today)) {
      return true;
    } else {
      return false;
    }
  }

  static double convertKelvinToCelciusHelper(kelvinInput) {
    //formula for convert kelvin to celcius
    return kelvinInput - 273.15;
  }

  static String todayOrTomorrowHelper(date) {
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

  static Map identifyWeatherIcon(String iconId) {
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
