import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  // 여기에 API 키를 직접 입력합니다.
  final String apiKey = 'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y';

  Future<void> _searchLocation(String input, bool isStart) async {
    // Geocoding API 요청 URL
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

  List<double> distance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    double distanceLatitude = (endLatitude - startLatitude).abs();
    double distanceLongitude = (endLongitude - startLongitude).abs();

    return [distanceLatitude, distanceLongitude];
  }

  void _calculateDistance() {
    if (_startLatitude.isNotEmpty && _startLongitude.isNotEmpty && _endLatitude.isNotEmpty && _endLongitude.isNotEmpty) {
      double startLat = double.parse(_startLatitude);
      double startLng = double.parse(_startLongitude);
      double endLat = double.parse(_endLatitude);
      double endLng = double.parse(_endLongitude);

      List<double> distances = distance(startLat, startLng, endLat, endLng);

      setState(() {
        _distanceMessage = 'Latitude Distance: ${distances[0]}, Longitude Distance: ${distances[1]}';
      });
    }
  }
  
  bool _isButtonEnabled() {
    return _startLatitude.isNotEmpty && _startLongitude.isNotEmpty && _endLatitude.isNotEmpty && _endLongitude.isNotEmpty;
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
                Expanded(
                  child: TextField(
                    controller: _startController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[100],
                      hintText: '출발 지점을 입력해주세요.',
                    ),
                  ),
                ),
                Container(
                  color: Colors.blue[100],
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => _searchLocation(_startController.text, true),
                      icon: Icon(
                        Icons.search,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('출발 위치: $_startLocation'),
            Text('위도: $_startLatitude'),
            Text('경도: $_startLongitude'),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _endController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[100],
                      hintText: '도착 지점을 입력해주세요.',
                    ),
                  ),
                ),
                Container(
                  color: Colors.blue[100],
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => _searchLocation(_endController.text, false),
                      icon: Icon(
                        Icons.search,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('도착 위치: $_endLocation'),
            Text('위도: $_endLatitude'),
            Text('경도: $_endLongitude'),
            SizedBox(height: 20),
            Text(_distanceMessage),

      
            TextButton(onPressed: _isButtonEnabled() ? () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => Foodlist(
              startLat: double.parse(_startLatitude),
              startLng: double.parse(_startLongitude),
              endLat: double.parse(_endLatitude),
              endLng: double.parse(_endLongitude),
        ),))} : null , child: Text("화면 이동"), )
          ],
        ),
      ),
    );
  }
}
