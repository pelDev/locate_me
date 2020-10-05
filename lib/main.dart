import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'notifications.dart' as notif;

const fetchBackground = 'fetchBackground';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        Position userLocation = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        //print(userLocation.toString());
        notif.Notification notification = notif.Notification();
        Coordinates coordinates = Coordinates(
          userLocation.latitude,
          userLocation.longitude,
        );
        var address =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        await notification
            .showNotificationWithoutSound(address.first.addressLine);
        break;
    }
    return Future.value(true);
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position _position;
  String place;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeBackgroundTask();
  }

  void initializeBackgroundTask() async {
    await requestPermission();
    Workmanager.initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager.registerPeriodicTask(
      '1',
      fetchBackground,
      frequency: Duration(seconds: 15),
    );
  }

  // void _getUserPosition() async {
  //   Position userLocation = await GeolocatorPlatform().getCurrentPosition()
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Me'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              place != null ? place : 'Track Your Position now!',
              style: TextStyle(
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30.0,
            ),
            RaisedButton(
              onPressed: () {
                print('object');
                getLocation();
              },
              child: Text(
                'Track',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void getLocation() async {
    // LocationPermission permission = await requestPermission();
    // Position userLocation =
    //     await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Coordinates coordinates =
    //     Coordinates(userLocation.latitude, userLocation.longitude);

    // getAddressFromLatLng(coordinates);
    // setState(() {
    //   position = userLocation;
    // });

    // ignore: cancel_subscriptions
    StreamSubscription<Position> positionStream = getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 1,
      timeInterval: 1,
      forceAndroidLocationManager: true,
    ).listen((Position position) {
      print(position == null ? 'Unknown' : position.toString());
      Coordinates coordinates =
          Coordinates(position.latitude, position.longitude);
      getAddressFromLatLng(coordinates);

      //_position = position;
    });
  }

  void getAddressFromLatLng(Coordinates coordinates) async {
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      place = address.first.addressLine;
    });
  }
}
