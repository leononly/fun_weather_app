import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:weather/services/config.dart';

class API {
  Dio dio = Dio();
  String apiKey = Config.apiKey;

  Future<dynamic> getWeather(locationData) async {
    String latitude = locationData['lat'];
    String longitude = locationData['lng'];
    try {
      FLog.logThis(
          text:
              "Attempt API call,${'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey'}",
          methodName: 'getWeather',
          type: LogLevel.WARNING);

      var response = await dio.get(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey');

      print(response);
      FLog.logThis(
          text: "API call success",
          methodName: 'getWeather',
          type: LogLevel.WARNING);
      FLog.exportLogs();

      if (response.data['cod'] != null && response.data['cod'] == '200')
        return response.data;
      else
        throw 'Something went wrong.';
    } catch (error) {
      FLog.logThis(
          text: "API call error, ${error.toString()}",
          methodName: 'getWeather',
          type: LogLevel.ERROR);
      FLog.exportLogs();

      debugPrint(error.toString());

      throw 'NetworkError';
    }
  }
}
