import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/bloc/weatherCubit/weather_cubit.dart';
import 'package:weather/screens/CitiesScreen.dart';
import 'package:weather/screens/HomeScreen.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // WeatherBloc weatherBloc;
  WeatherCubit weatherCubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // weatherBloc = WeatherBloc();
    weatherCubit = WeatherCubit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => weatherCubit,
      child: MaterialApp(
          title: 'Fun Weather App',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Roboto',
              accentColor: Colors.white),
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/CitiesScreen':
                {
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (BuildContext context) => CitiesScreen(),
                  );
                }
                break;
              default:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (BuildContext context) => HomeScren(),
                );
            }
          }),
    );
  }
}
