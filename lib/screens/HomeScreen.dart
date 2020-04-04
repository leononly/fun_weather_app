import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_icons/weather_icons.dart';

import '../bloc/weather/bloc.dart';
import 'CitiesScreen.dart';

class HomeScren extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScren>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  WeatherBloc weatherBloc;

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    weatherBloc = BlocProvider.of<WeatherBloc>(context);

//    weatherBloc.add(FetchLocation());

    weatherBloc.add(AppStart());

    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return BlocBuilder(
      bloc: weatherBloc,
      builder: (context, state) => Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: "Forecast",
              ),
              Tab(
                text: "Cities",
              ),
            ],
          ),
          elevation: 0,
          title: Column(
            children: <Widget>[
              Text(
                  '${weatherBloc.locations[weatherBloc.selectedIndex]['city']}'),
              if (weatherBloc.locations[weatherBloc.selectedIndex]
                      ['currentLocationFlag'] !=
                  null)
                Text(
                  weatherBloc.locations[weatherBloc.selectedIndex]['admin'],
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
          leading: FlatButton(
              child: Icon(
                Icons.refresh,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                _tabController.animateTo(0);
                weatherBloc.add(RefreshData());
              }),
          actions: <Widget>[
            FlatButton(
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                _tabController.animateTo(0);
                weatherBloc.add(FetchCurrentLocation());
              },
            ),
          ],
        ),
        body: BlocListener(
          bloc: weatherBloc,
          listener: (ctx, state) {
            if (state is WeatherError) {
              final snackBar = SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
              );

              Scaffold.of(ctx).hideCurrentSnackBar();
              Scaffold.of(ctx).showSnackBar(snackBar);
            }
          },
          child: TabBarView(
              controller: _tabController,
              children: [firstTab(state), secondTab(state)]),
        ),
      ),
    );
  }

  Widget firstTab(WeatherState state) {
    Size media = MediaQuery.of(context).size;

    return Container(
//        height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Colors.blueAccent,
            Colors.blue,
            Colors.lightBlue,
            Colors.lightBlue,
//                  Colors.white
          ])),
      child: state is WeatherLoading
          ? Center(child: CircularProgressIndicator())
          : state is WeatherNetworkError
              ? Container(
                  width: media.width,
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Ooopss...Network Error,\n Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).accentColor, fontSize: 18),
                  ))
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 30, right: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: media.width * 0.1, bottom: 100),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    Container(
                                      width: 140,
                                      padding: EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              child: weatherBloc.locations[
                                                              weatherBloc
                                                                  .selectedIndex]
                                                          ['weatherData'] !=
                                                      null
                                                  ? BoxedIcon(
                                                      weatherBloc.identifyWeatherIcon(
                                                          weatherBloc
                                                              .locations[
                                                                  weatherBloc
                                                                      .selectedIndex]
                                                                  [
                                                                  'weatherData']
                                                                  ['weather']
                                                              .values
                                                              .toList()[0]
                                                                  [
                                                                  'weatherList']
                                                                  [0]['weather']
                                                                  ['icon']
                                                              .toString())['icon'],
                                                      color: weatherBloc
                                                          .identifyWeatherIcon(weatherBloc
                                                              .locations[
                                                                  weatherBloc
                                                                      .selectedIndex]
                                                                  ['weatherData']
                                                                  ['weather']
                                                              .values
                                                              .toList()[0][
                                                                  'weatherList']
                                                                  [0]['weather']
                                                                  ['icon']
                                                              .toString())['color'],
                                                      size: 30,
                                                    )
                                                  : Text(
                                                      '-',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                          fontSize: 30),
                                                    )),
                                          Container(
                                            child: Text(
                                              weatherBloc.locations[weatherBloc
                                                              .selectedIndex]
                                                          ['weatherData'] !=
                                                      null
                                                  ? '${weatherBloc.locations[weatherBloc.selectedIndex]['weatherData']['weather'].values.toList()[0]['weatherList'][0]['celcius'].toStringAsFixed(1)}\u02DAC'
                                                  : '--\u02DAC',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text(
                                        weatherBloc.locations[weatherBloc
                                                        .selectedIndex]
                                                    ['weatherData'] !=
                                                null
                                            ? '${weatherBloc.locations[weatherBloc.selectedIndex]['weatherData']['weather'].values.toList()[0]['weatherList'][0]['weather']['main']}'
                                            : '--',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            itemExtent: 100,
                            children: <Widget>[
                              if (weatherBloc
                                          .locations[weatherBloc.selectedIndex]
                                      ['weatherData'] !=
                                  null)
                                ...weatherBloc
                                    .locations[weatherBloc.selectedIndex]
                                        ['weatherData']['weather']
                                    .map((key, data) => MapEntry(
                                        key,
                                        GestureDetector(
                                          onTap: () {
                                            weatherBloc.add(SelectForecastDay(
                                                keyDate: key));
                                          },
                                          child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              data['day'],
                                              style: TextStyle(
                                                  color: weatherBloc
                                                                  .forecastDaySelected !=
                                                              null &&
                                                          weatherBloc
                                                              .forecastDaySelected
                                                              .containsKey(key)
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Color(0xFF2353a1),
                                                  fontSize: weatherBloc
                                                                  .forecastDaySelected !=
                                                              null &&
                                                          weatherBloc
                                                              .forecastDaySelected
                                                              .containsKey(key)
                                                      ? 20
                                                      : 15),
                                            ),
                                          ),
                                        )))
                                    .values
                                    .toList(),
                            ],
                          ),
                        ),
                        Container(
                          height: 200,
                          margin: EdgeInsets.only(
                            left: 30,
                          ),
                          width: media.width,
                          padding:
                              EdgeInsets.only(left: 20, top: 20, bottom: 20),
                          decoration: BoxDecoration(
                              color: Color(0xFF57aeff),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4f84ff).withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                                BoxShadow(
                                  color: Color(0xFF4f84ff).withOpacity(0.2),
//                                    blurRadius: 10,
                                )
                              ]),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListView(
                              itemExtent: 90,
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (weatherBloc.forecastDaySelected != null)
                                  ...weatherBloc.forecastDaySelected.values
                                      .toList()[0]['weatherList']
                                      .map((data) => Container(
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.blueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  data['time'],
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                                BoxedIcon(
                                                  weatherBloc
                                                      .identifyWeatherIcon(data[
                                                              'weather']['icon']
                                                          .toString())['icon'],
                                                  color: weatherBloc
                                                      .identifyWeatherIcon(data[
                                                              'weather']['icon']
                                                          .toString())['color'],
                                                  size: 25,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${data['celcius'].toStringAsFixed(1)}\u02DAC',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
    );
  }

  Widget secondTab(WeatherState state) {
    Size media = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: ListView(
              children: <Widget>[
                ...weatherBloc.locations
                    .asMap()
                    .map((i, data) => MapEntry(
                        i,
                        ListTile(
                          onTap: () {
                            _tabController.animateTo(0);
                            weatherBloc.add(SelectAndFetchWeather(index: i));
                          },
                          selected:
                              i == weatherBloc.selectedIndex ? true : false,
                          title: Text(data['city']),
                          subtitle: Text(data['admin'] != null
                              ? '${data['admin']}, ${data['country']}'
                              : '${data['country']}'),
                          trailing: data['currentLocationFlag'] != null
                              ? Icon(Icons.pin_drop)
                              : null,
                        )))
                    .values
                    .toList()
              ],
            )),
            Container(
              width: media.width,
              margin: EdgeInsets.all(5),
              child: RaisedButton(
                color: Colors.blueAccent,
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CitiesScreen()));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Add City',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
