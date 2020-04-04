import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/bloc/weather/bloc.dart';
import 'package:weather/screens/CitiesScreen.dart';
import 'package:weather/screens/HomeScreen.dart';

class SimpleBlocDelegate extends BlocDelegate {
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
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  BlocSupervisor.delegate = SimpleBlocDelegate();
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
  WeatherBloc weatherBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    weatherBloc = WeatherBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => weatherBloc,
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
