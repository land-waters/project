import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:project/direction.dart';
import 'package:project/foodList.dart';
import 'package:project/locator/locator.dart';
import 'package:http/http.dart' as http;

void main() {
  initLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationSearch(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellowAccent),
        fontFamily: "POP",
      ),
    );
  }
}

class LocationSearch extends StatefulWidget {
  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  String _startLocation = '';
  String _startLatitude = '';
  String _startLongitude = '';
  String _endLocation = '';
  String _endLatitude = '';
  String _endLongitude = '';
  String _distanceMessage = '';

  @override
  void initState() {
    super.initState();
  }

  bool _isButtonEnabled() {
    return _startLocation.isNotEmpty && _endLocation.isNotEmpty;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371; // 지구 반지름 (킬로미터)
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _getCurrentLocationAndAddress() async {
    try {
      // Google Geolocation API 요청
      final String apiKey = 'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y';
      final String geolocationUrl =
          'https://www.googleapis.com/geolocation/v1/geolocate?key=$apiKey';

      final locationResponse = await http.post(Uri.parse(geolocationUrl));

      if (locationResponse.statusCode == 200) {
        Map<String, dynamic> locationData = json.decode(locationResponse.body);
        double lat = locationData['location']['lat'];
        double lng = locationData['location']['lng'];

        // Google Geocoding API 요청 (위도, 경도 -> 도로명 주소)
        final String geocodeUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey&language=ko';

        final geocodeResponse = await http.get(Uri.parse(geocodeUrl));

        if (geocodeResponse.statusCode == 200) {
          Map<String, dynamic> geocodeData = json.decode(geocodeResponse.body);
          String address = geocodeData['results'][0]['formatted_address'];

          setState(() {
            _startController.text = address;
            _startLocation = address;
            _startLatitude = lat.toString();
            _startLongitude = lng.toString();
            _calculateDistance();
          });
        } else {
          print('Failed to get address.');
        }
      } else {
        print('Failed to get location.');
      }
    } catch (e) {
      print("Error occurred while getting location: $e");
    }
  }

  void _calculateDistance() {
    if (_startLatitude.isNotEmpty &&
        _startLongitude.isNotEmpty &&
        _endLatitude.isNotEmpty &&
        _endLongitude.isNotEmpty) {
      double startLat = double.parse(_startLatitude);
      double startLng = double.parse(_startLongitude);
      double endLat = double.parse(_endLatitude);
      double endLng = double.parse(_endLongitude);

      double distanceInKm =
          calculateDistance(startLat, startLng, endLat, endLng);

      setState(() {
        _distanceMessage =
            '두 지점 사이의 거리 : ${distanceInKm.toStringAsFixed(2)} km';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가다 뭐먹지?'),
        backgroundColor: Colors.yellowAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.center,
              child: Text("출발지 입력"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: _startController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: '출발지를 설정해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _getCurrentLocationAndAddress();
                  },
                  icon: Icon(Icons.my_location, size: 40),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: Colors.yellow, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: _endController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '목적지를 설정해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return KpostalView(callback: (Kpostal result) {
                            _endController.text = result.roadAddress;
                            setState(() {
                              _endLocation = result.roadAddress;
                              _endLatitude = result.latitude.toString();
                              _endLongitude = result.longitude.toString();
                              _calculateDistance();
                            });
                          });
                        },
                      ),
                    )
                  },
                  icon: Icon(Icons.search, size: 40),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            Text(_distanceMessage),
            ElevatedButton(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DirectionsAndRestaurantsScreen(
                    startAddress: _startController.text,
                    startLat: double.parse(_startLatitude),
                    startLng: double.parse(_startLongitude),
                    endLat: double.parse(_endLatitude),
                    endLng: double.parse(_endLongitude),
                    endAddress: _endController.text,
                  ),
                ))
              },
              child: Text(
                "음식점 찾기",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}
