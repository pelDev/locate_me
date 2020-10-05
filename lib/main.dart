import 'package:flutter/material.dart';
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
        await notification.showNotificationWithoutSound(userLocation);
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
  Position position;

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
      frequency: Duration(minutes: 15),
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
              position != null
                  ? position.toString()
                  : 'Track Your Position now!',
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
    LocationPermission permission = await requestPermission();
    Position userLocation =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = userLocation;
    });
  }
}
