import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/bloc/weatherCubit/weather_cubit.dart';
import 'package:weather/services/helper.dart';
import 'package:weather_icons/weather_icons.dart';

// import '../bloc/weather/bloc.dart';
import 'CitiesScreen.dart';

class HomeScren extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScren>
    with SingleTickerProviderStateMixin {
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  // weatherCubit weatherCubit;
  WeatherCubit weatherCubit;

  TabController _tabController;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // weatherCubit = BlocProvider.of<weatherCubit>(context);
    weatherCubit = BlocProvider.of<WeatherCubit>(context);

//    weatherCubit.add(FetchLocation());

    weatherCubit.appStart();
    // weatherCubit.add(AppStart());

    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: weatherCubit,
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
                  '${weatherCubit.locations[weatherCubit.selectedIndex]['city']}'),
              if (weatherCubit.locations[weatherCubit.selectedIndex]
                      ['currentLocationFlag'] !=
                  null)
                Text(
                  weatherCubit.locations[weatherCubit.selectedIndex]['admin'],
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
          leading: TextButton(
              child: Icon(
                Icons.refresh,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                _tabController.animateTo(0);
                weatherCubit.refreshData();
              }),
          actions: <Widget>[
            TextButton(
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                _tabController.animateTo(0);
                Future.delayed(Duration(milliseconds: 300), () {
                  weatherCubit.fetchCurrentLocation();
                });
              },
            ),
          ],
        ),
        body: BlocListener(
          bloc: weatherCubit,
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
              ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
              ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
            }
          },
          child: TabBarView(
              controller: _tabController,
              children: [firstTab(state, scrollController), secondTab(state)]),
        ),
      ),
    );
  }

  Widget firstTab(WeatherState state, ScrollController scrollController) {
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
                                              child: weatherCubit.locations[
                                                              weatherCubit
                                                                  .selectedIndex]
                                                          ['weatherData'] !=
                                                      null
                                                  ? BoxedIcon(
                                                      Helper.identifyWeatherIcon(
                                                          weatherCubit
                                                              .locations[
                                                                  weatherCubit
                                                                      .selectedIndex]
                                                                  [
                                                                  'weatherData']
                                                                  ['weather']
                                                              .values
                                                              .toList()[0][
                                                                  'weatherList']
                                                                  [0]['weather']
                                                                  ['icon']
                                                              .toString())['icon'],
                                                      color: Helper.identifyWeatherIcon(
                                                          weatherCubit
                                                              .locations[
                                                                  weatherCubit
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
                                              weatherCubit.locations[weatherCubit
                                                              .selectedIndex]
                                                          ['weatherData'] !=
                                                      null
                                                  ? '${weatherCubit.locations[weatherCubit.selectedIndex]['weatherData']['weather'].values.toList()[0]['weatherList'][0]['celcius'].toStringAsFixed(1)}\u02DAC'
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
                                        weatherCubit.locations[weatherCubit
                                                        .selectedIndex]
                                                    ['weatherData'] !=
                                                null
                                            ? '${weatherCubit.locations[weatherCubit.selectedIndex]['weatherData']['weather'].values.toList()[0]['weatherList'][0]['weather']['main']}'
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
                              if (weatherCubit
                                          .locations[weatherCubit.selectedIndex]
                                      ['weatherData'] !=
                                  null)
                                ...weatherCubit
                                    .locations[weatherCubit.selectedIndex]
                                        ['weatherData']['weather']
                                    .map((key, data) => MapEntry(
                                        key,
                                        TextButton(
                                          onPressed: () {
                                            scrollController.animateTo(
                                                scrollController
                                                    .position.minScrollExtent,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.fastOutSlowIn);

                                            weatherCubit.selectForecastDay(key);
                                          },
                                          style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.only(
                                                          bottom: 10))),
                                          child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              data['day'],
                                              style: TextStyle(
                                                  color: weatherCubit
                                                                  .forecastDaySelected !=
                                                              null &&
                                                          weatherCubit
                                                              .forecastDaySelected
                                                              .containsKey(key)
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Color(0xFF2353a1),
                                                  fontSize: weatherCubit
                                                                  .forecastDaySelected !=
                                                              null &&
                                                          weatherCubit
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
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (weatherCubit.forecastDaySelected != null)
                                  ...weatherCubit.forecastDaySelected.values
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
                                                  Helper.identifyWeatherIcon(
                                                      data['weather']['icon']
                                                          .toString())['icon'],
                                                  color: Helper
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
                ...weatherCubit.locations
                    .asMap()
                    .map((i, data) => MapEntry(
                        i,
                        ListTile(
                          onTap: () {
                            _tabController.animateTo(0);
                            weatherCubit.selectAndFetchWeather(i);
                          },
                          selected:
                              i == weatherCubit.selectedIndex ? true : false,
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CitiesScreen()));
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    )),
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
