import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kpostal/kpostal.dart';
import 'package:project/direction.dart';
import 'package:project/foodList.dart';
import 'package:project/locator/locator.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          fontFamily: "POP"),
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
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: _startController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '출발지를 설정해주세요.',
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
                            _startController.text = result.address;
                            setState(() {
                              _startLocation = result.roadAddress;
                              _startLatitude = result.latitude.toString();
                              _startLongitude = result.longitude.toString();
                              _calculateDistance();
                            });
                          });
                        },
                      ),
                    )
                  },
                  icon: Icon(Icons.search, size: 20),
                  style: IconButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('출발 위치: $_startLocation'),
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
                  icon: Icon(Icons.search, size: 20),
                  style: IconButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('도착 위치: $_endLocation'),
            SizedBox(height: 20),
            Text(_distanceMessage),
            TextButton(
              onPressed: _isButtonEnabled()
                  ? () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Foodlist(
                                startAddress: _startController.text,
                                startLat: double.parse(_startLatitude),
                                startLng: double.parse(_startLongitude),
                                endLat: double.parse(_endLatitude),
                                endLng: double.parse(_endLongitude),
                              )));
                    }
                  : null,
              child: Text(
                _isButtonEnabled()
                    ? "출발 지점과 도착 지점 사이에 있는 맛집 보러가기"
                    : "출발 지점과 도착 지점을 설정해주세요",
              ),
              style: TextButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
            ),
            ElevatedButton(onPressed: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DirectionsAndRestaurantsScreen(startAddress: _startController.text,startLat: double.parse(_startLatitude), startLng: double.parse(_startLongitude), endLat: double.parse(_endLatitude), endLng: double.parse(_endLongitude), endAddress: _endController.text)))
            }, child: Text("구글 경로 "))
          ],
        ),
      ),
    );
  }
}
