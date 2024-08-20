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
            Container(
  padding: EdgeInsets.all(16.0), // 내부 여백 추가
  decoration: BoxDecoration(
    color: Colors.white, // 배경색 설정
    borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
    boxShadow: [
      BoxShadow(
        color: Colors.black26, // 그림자 색상
        offset: Offset(0, 4), // 그림자 위치
        blurRadius: 8.0, // 그림자 흐림 정도
      ),
    ],
    border: Border.all(
      color: Colors.blueAccent, // 테두리 색상
      width: 2.0, // 테두리 두께
    ),
  ),
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.9,
    height: MediaQuery.of(context).size.height * 0.3,
    child: Text(
      "1. 출발지와 도착지를 입력합니다.\n"
      "2. '음식점 찾기' 버튼을 눌러 지도를 불러옵니다.\n"
      "3. 출발지와 도착지 사이의 음식점 핀을 클릭하여 간단한 정보를 볼 수 있습니다.\n"
      "4. '정보 보기' 버튼을 눌러 해당 식당의 상세정보를 볼 수 있습니다.\n"
      "5. 상세 정보에는 리뷰가 포함되어 있습니다.\n (최대 5개까지만 불러옵니다.)\n"
      "6. 더 많은 리뷰를 원하시면 '리뷰 더보기'를 이용하여 보실 수 있습니다.\n",
      style: TextStyle(
        fontSize: 16.0, // 글자 크기
        color: const Color.fromARGB(255, 49, 43, 43), // 글자 색상
      ),
    ),
  ),
)
,
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
                  icon: Icon(Icons.search, size: 40),
                  style: IconButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                          borderRadius: BorderRadius.circular(8))),
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
                              endAddress: _endController.text)))
                    },
                child: Text("음식점 찾기"))
          ],
        ),
      ),
    );
  }
}
