import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(LocationMaps());

class LocationMaps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  double height, width;
  String _homeloc = "Searching...";
  Position _currentPosition;
  CameraPosition _home;
  CameraPosition _userpos;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> _markers = Set();
  MapType _currentMapType = MapType.normal;
  GoogleMapController gmcontroller;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0XFF004D40),
          title: Text('Maps'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Stack(children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 300),
                  height: 400,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: _markers.toSet(),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 17.0,
                    ),
                    onTap: (newLatLng) {
                      _onAddMarkerButtonPressed(newLatLng, setState);
                    },
                    mapType: _currentMapType,
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(16.0),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Column(children: <Widget>[
                          FloatingActionButton(
                            onPressed: _onMapTypeButtonPressed,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.map, size: 36.0),
                          ),
                        ]))),
                SizedBox(height: 8),
                Container(
                    margin: EdgeInsets.fromLTRB(25, 440, 25, 0),
                    width: 400,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        border: Border.all(width: 1)),
                    child: Column(children: [
                      SizedBox(height: 5),
                      Text(
                        "ADDRESS",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(_homeloc,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      Text('Latitude :' + latitude.toString(),
                          style: TextStyle(fontSize: 15)),
                      Text('Longtitude :' + longitude.toString(),
                          style: TextStyle(fontSize: 15)),
                    ])),
              ]),
            ),
          ),
        ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed(LatLng loc, setState) async {
    setState(() {
      print("Marker");
      _markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, setState);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      _markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: _homeloc,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
      //zoom: 14.4746,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, setState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        return;
      }
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  Future<void> _getLocation() async {
    try {
      setState(() {
        _markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: _homeloc,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });

      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(latitude, longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = latitude;
              longitude = longitude;
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}
