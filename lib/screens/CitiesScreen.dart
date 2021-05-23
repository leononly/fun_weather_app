import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/bloc/weatherCubit/weather_cubit.dart';

class CitiesScreen extends StatefulWidget {
  @override
  _CitiesScreenState createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  // WeatherBloc weatherBloc;
  WeatherCubit weatherCubit;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // weatherBloc = BlocProvider.of<WeatherBloc>(context);

    weatherCubit = BlocProvider.of<WeatherCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Add City"),
      ),
      body: Container(
          child: ListView(
        children: <Widget>[
          ...weatherCubit.locationListToAdd
              .asMap()
              .map((index, data) => MapEntry(
                  index,
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      weatherCubit.addNewLocation(index);
                    },
                    title: Text(data['city']),
                    subtitle: Text('${data['admin']}, ${data['country']}'),
                    trailing: Icon(Icons.add),
                  )))
              .values
              .toList()
        ],
      )),
    );
  }
}
