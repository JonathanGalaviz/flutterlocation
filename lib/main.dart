import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  int cont = 0;
  bool state = false;
  bool _enabled;
  bool _isMoving;
  double lat = 0;
  double lon = 0;
  void initState() {
    // TODO: implement initState
    super.initState();
    cont = 0;
    ////
    // 1.  Listen to events (See docs for all 12 available events).
    //

    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      //print('[location] - $location');
      sendCoordinates(location.coords.latitude, location.coords.longitude);
      setState(() {
        lat = location.coords.latitude;
        lon = location.coords.longitude;
        cont = cont + 1;
      });
      print("COORDENADAS de mi celular");
      print("${location.coords.latitude} ${location.coords.longitude}");
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      //print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      //print('[providerchange] - $event');
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
            distanceFilter: 5.0,
            stopOnTerminate: false,
            startOnBoot: true,
            debug: false,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE,
            allowIdenticalLocations: false,
            stopTimeout: 10,
            stopOnStationary: false,
            disableStopDetection: true))
        .then((bg.State state) {
      if (!state.enabled) {
        print("[ready] ${state.toMap()}");
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
        bg.BackgroundGeolocation.start();
      }
    }).catchError((error) {
      print('[ready] ERROR: $error');
    });
  }

  sendCoordinates(lat, lng) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get("http://cceo.io:8019/api/coords",
        queryParameters: {"lat": lat, "lng": lng});

    print("RESPONSE");
    print(response.data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubicación"),
        centerTitle: true,
        actions: <Widget>[
          /*    Switch(
              value: state,
              onChanged: _onClickEnable
          ),*/
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: state
                    ? () {
                        setState(() {
                          state = false;
                        });
                        _onClickEnable(state);
                      }
                    : () {
                        setState(() {
                          state = true;
                        });
                        _onClickEnable(state);
                      },
                child: Container(
                  decoration: BoxDecoration(
                      color: state ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(5)),
                  height: 40,
                  width: MediaQuery.of(context).size.width * .9,
                  child: Center(
                      child: Text(
                    state ? 'Apagar' : 'Encender',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  )),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
                width: MediaQuery.of(context).size.width * .9,
                child: Center(
                    child: Text(
                  "Coordenadas\nLatitud: $lat\nLongitud: $lon\nTotal de cambios: $cont",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onClickEnable(enabled) {
    if (enabled) {
      // Reset odometer.
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('iniciando [start] success $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      }).catchError((error) {
        print('[start] ERROR: $error');
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('detenido [stop] success: $state');

        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    }
  }
}
