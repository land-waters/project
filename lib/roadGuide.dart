import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:math';

class RoadGuide extends StatelessWidget {
  final String startAddress;
  final String endAddress;
  final String startLat;
  final String startLng;
  final String endLat;
  final String endLng;

  RoadGuide({required this.startAddress,required this.endAddress,required this.startLat, required this.startLng, required this.endLat, required this.endLng});

  // WGS 84 좌표계를 EPSG:3857 좌표계로 변환하는 함수
  Map<String, double> wgs84ToEPSG3857(double lon, double lat) {
    double x = lon * 20037508.34 / 180;
    double y = log(tan((90 + lat) * pi / 360)) * 20037508.34 / pi;
    return {'x': x, 'y': y};
  }

  @override
  Widget build(BuildContext context) {
    // 시작 위치와 종료 위치의 좌표를 변환
    Map<String, double> startPoint = wgs84ToEPSG3857(double.parse(startLng), double.parse(startLat));
    Map<String, double> endPoint = wgs84ToEPSG3857(double.parse(endLng), double.parse(endLat));

    String url = 'https://map.naver.com/p/directions/${startPoint['x']!.toInt()},${startPoint['y']!.toInt()},${startAddress},ADDRESS_POI/${endPoint['x']!.toInt()},${endPoint['y']!.toInt()},${endAddress},ADDRESS_POI/-/car?';

    
        print(url);

    return Scaffold(
      appBar: AppBar(
        title: Text("길찾기"),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
