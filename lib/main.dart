import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  final String apiKey = 'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y';

  bool _isButtonEnabled() {
    return _startLocation.isNotEmpty && _endLocation.isNotEmpty;
  }

  Future<void> _searchLocation(String input, bool isStart) async {
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$input&key=$apiKey';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        var location = data['results'][0]['geometry']['location'];
        setState(() {
          if (isStart) {
            _startLocation = input;
            _startLatitude = location['lat'].toString();
            _startLongitude = location['lng'].toString();
          } else {
            _endLocation = input;
            _endLatitude = location['lat'].toString();
            _endLongitude = location['lng'].toString();
          }
        });
        _calculateDistance();
      } else {
        setState(() {
          if (isStart) {
            _startLocation = 'No results found';
            _startLatitude = '';
            _startLongitude = '';
          } else {
            _endLocation = 'No results found';
            _endLatitude = '';
            _endLongitude = '';
          }
        });
      }
    } else {
      setState(() {
        if (isStart) {
          _startLocation = 'Error: ${response.statusCode}';
          _startLatitude = '';
          _startLongitude = '';
        } else {
          _endLocation = 'Error: ${response.statusCode}';
          _endLatitude = '';
          _endLongitude = '';
        }
      });
    }
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Haversine 공식

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
        title: Text('Location Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  height: 50,
                  child: TextField(
                    controller: _startController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[100],
                      hintText: '출발 지점을 입력해주세요.',
                       border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), // 모서리 둥글기 설정
                        borderSide: BorderSide(
                          color: Colors.blue, // 테두리 색상 설정
                          width: 2, // 테두리 두께 설정
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue, // 비활성 상태 테두리 색상 설정
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue, // 포커스 상태 테두리 색상 설정
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  color: Colors.blue[100],
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.1,
                    height: 50,
                    child: IconButton(
                      onPressed: () =>
                          _searchLocation(_startController.text, true),
                      icon: Icon(
                        Icons.search,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('출발 위치: $_startLocation'),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  height: 50,
                  child: TextField(
                    controller: _endController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '도착 지점을 입력해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), // 모서리 둥글기 설정
                        borderSide: BorderSide(
                          color: Colors.blue, // 테두리 색상 설정
                          width: 2, // 테두리 두께 설정
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue, // 비활성 상태 테두리 색상 설정
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue, // 포커스 상태 테두리 색상 설정
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.1,
                    height: 50,
                    child: IconButton(
                      onPressed: () =>
                          _searchLocation(_endController.text, false),
                      icon: Icon(
                        Icons.search,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('도착 위치: $_endLocation'),
            SizedBox(height: 20),
            Text(_distanceMessage),
            TextButton(
                onPressed: _isButtonEnabled()
                    ? () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Foodlist(
                                    startLat: double.parse(_startLatitude),
                                    startLng: double.parse(_startLongitude),
                                    endLat: double.parse(_endLatitude),
                                    endLng: double.parse(_endLongitude),
                                  )))
                        }
                    : null,
                child: Text(
                  _isButtonEnabled()
                      ? "${_startLocation} 에서 ${_endLocation} 사이에 있는 맛집 보러가기"
                      : "출발 지점과 도착 지점을 설정해주세요",
                ),
                style: TextButton.styleFrom(
                    side: BorderSide(
                        color: Colors.blue, width: 2), // 테두리 색상과 두께 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 모서리 둥글기 설정
                    ))),
          ],
        ),
      ),
    );
  }
}
