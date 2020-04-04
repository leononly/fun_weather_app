import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:weather/bloc/weather/constants.dart';

class API {
  Dio dio = Dio();
  String apiKey = Constants.apiKey;

  Future<dynamic> getWeather(locationData) async {
    String latitude = locationData['lat'];
    String longitude = locationData['lng'];
    try {
      var response = await dio.get(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey');

      print(response);

      if (response.data['cod'] != null && response.data['cod'] == '200')
        return response.data;
      else
        throw 'Something went wrong.';
    } catch (error) {
      debugPrint(error.toString());

//      if (error.error != null &&
//          error.error.osError != null &&
//          error.error.osError.errorCode == 60) {
//        // network operation time our
//        throw 'Connection time out';
//      }
//
//      if (error.error.message != '') {
//        throw error.error.message;
//      }
      throw 'NetworkError';
    }
  }
}
