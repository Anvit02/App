import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dementia Patient Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrackingPage(),
    );
  }
}

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  Position? _currentPosition;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _getLocationUpdates();

    // Enable WebView if the platform is not null
    if (WebView.platform == null) {
      WebView.platform = SurfaceAndroidWebView(); // Ensure the webview platform is set
    }
  }

  void _initializeNotifications() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _getLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Location services are not enabled
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Handle permission denied
      }
    }

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _sendLocationToFamily(position);
      _updateMap(position.latitude, position.longitude);
    }, onError: (e) {
      print("Error fetching location: $e");
    });
  }

  void _sendLocationToFamily(Position position) {
    _showNotification("New Location", "Lat: ${position.latitude}, Lon: ${position.longitude}");
  }

  void _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _updateMap(double latitude, double longitude) {
    String mapUrl = '''
      <html>
      <head>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
      </head>
      <body>
        <div id="map" style="width: 100%; height: 100%;"></div>
        <script>
          var map = L.map('map').setView([$latitude, $longitude], 13);
          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: 'Map data © OpenStreetMap contributors',
          }).addTo(map);
          L.marker([$latitude, $longitude]).addTo(map)
              .bindPopup('Current Location')
              .openPopup();
        </script>
      </body>
      </html>
    ''';

    _webViewController.loadUrl(Uri.dataFromString(mapUrl, mimeType: 'text/html').toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Dementia Patient'),
      ),
      body: Center(
        child: _currentPosition != null
            ? Column(
                children: [
                  Text('Location: \nLat: ${_currentPosition!.latitude}, \nLon: ${_currentPosition!.longitude}'),
                  Expanded(
                    child: WebView(
                      initialUrl: Uri.dataFromString(
                        '''
                        <html>
                        <head>
                          <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
                          <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
                        </head>
                        <body>
                          <div id="map" style="width: 100%; height: 100%;"></div>
                          <script>
                            var map = L.map('map').setView([${_currentPosition!.latitude}, ${_currentPosition!.longitude}], 13);
                            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                              attribution: 'Map data © OpenStreetMap contributors',
                            }).addTo(map);
                            L.marker([${_currentPosition!.latitude}, ${_currentPosition!.longitude}]).addTo(map)
                                .bindPopup('Current Location')
                                .openPopup();
                          </script>
                        </body>
                        </html>
                        ''',
                        mimeType: 'text/html',
                      ).toString(),
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController controller) {
                        _webViewController = controller;
                      },
                    ),
                  ),
                ],
              )
            : Text('Fetching location...'),
      ),
    );
  }
}













// The End 






// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dementia Patient Tracker',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: TrackingPage(),
//     );
//   }
// }

// class TrackingPage extends StatefulWidget {
//   const TrackingPage({super.key});

//   @override
//   _TrackingPageState createState() => _TrackingPageState();
// }

// class _TrackingPageState extends State<TrackingPage> {
//   Position? _currentPosition;
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     _getLocationUpdates();
//   }

//   void _initializeNotifications() {
//     var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   void _getLocationUpdates() async {
//     Geolocator.getPositionStream(
//       desiredAccuracy: LocationAccuracy.best,
//       intervalDuration: const Duration(minutes: 5),
//     ).listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//       });
//       _sendLocationToFamily(position);
//     });
//   }

//   void _sendLocationToFamily(Position position) {
//     // Here, you'd implement sending the location to the family (e.g., via API)
//     // For now, we'll simulate sending with a notification
//     _showNotification("New Location", "Lat: ${position.latitude}, Lon: ${position.longitude}");
//   }

//   void _showNotification(String title, String body) async {
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       'channel_description',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Track Dementia Patient'),
//       ),
//       body: Center(
//         child: _currentPosition != null
//             ? Text('Location: \nLat: ${_currentPosition!.latitude}, \nLon: ${_currentPosition!.longitude}')
//             : const Text('Fetching location...'),
//       ),
//     );
//   }
// }


